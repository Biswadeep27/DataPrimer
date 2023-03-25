from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.window import Window
from pyspark.sql.types import *
import sys
import json
import time
from datetime import datetime


class SparkProcessException(Exception):
    '''User customized spark exception class'''

#reading command line arguments
param_conf = sys.argv[1]
job_name = sys.argv[2]

spark = SparkSession.builder\
    .appName(job_name)\
    .config("spark.debug.maxToStringFields", "10000")\
    .config('spark.sql.shuffle.partition', 4)\
    .getOrCreate()

app_id = spark.sparkContext.applicationId

old_print = print
def timestamped_print(*args, **kwargs):
    logTime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    printheader = logTime + " " + job_name + " SPARK - "
    old_print(printheader, *args, **kwargs)
print = timestamped_print

print('INFO - The spark job started.')
print(f'INFO - Spark Application ID for this job : {app_id}')


try:
    with open(param_conf,'r') as attr_conf:
        attr_all = json.load(attr_conf)
    print('INFO - The config file read is successful.')
    attr_global = [x for x in attr_all if str(x['job_indicator']).strip() == 'global'][0]
    attr_job = [x for x in attr_all if str(x['job_indicator']).strip() == job_name.strip()][0]
    print('INFO - Global and Job specific config read is successful.')
except Exception as e:
        print(f'ERROR - the case_study {job_name} failed due to error while parsing config Json file: {param_conf} : {e}')
        raise SparkProcessException(f'ERROR - the case_study {job_name} failed due to error while parsing config Json file: {param_conf}') from e


print(f"INFO - The hdfs input units : {attr_job['ip_unit']}")
print(f"INFO - The hdfs input charges : {attr_job['ip_charges']}")
print(f"INFO - The hdfs input person : {attr_job['ip_primary_person']}")

try:
    df_unit = spark.read.csv(attr_job['ip_unit'], header = True)
except Exception as e:
    print(f'ERROR - Spark read for the unit file failed with the error : {e}')
    raise SparkProcessException('Spark process failed.') from e

try:
    df_charge = spark.read.csv(attr_job['ip_charges'], header = True)
except Exception as e:
    print(f'ERROR - Spark read for the charges file failed with the error : {e}')
    raise SparkProcessException('Spark process failed.') from e

try:
    df_person = spark.read.csv(attr_job['ip_primary_person'], header = True)
except Exception as e:
    print(f'ERROR - Spark read for the person file failed with the error : {e}')
    raise SparkProcessException('Spark process failed.') from e



df_top_states = df_person\
    .filter(~df_person.DRVR_LIC_STATE_ID.isin(['NA','Unknown']))\
    .select('CRASH_ID','DRVR_LIC_STATE_ID').distinct()\
    .groupBy('DRVR_LIC_STATE_ID').agg(F.count('CRASH_ID').alias('crash_count'))\
    .orderBy(F.col('crash_count').desc()).limit(25)\
    .select('DRVR_LIC_STATE_ID')

top_states = [row.DRVR_LIC_STATE_ID for row in df_top_states.collect()]

df_top_veh_col = df_unit\
    .filter(df_unit.VEH_COLOR_ID != 'NA')\
    .groupBy('VEH_COLOR_ID').agg(F.count('*').alias('color_count'))\
    .orderBy(F.col('color_count').desc()).limit(10)\
    .select('VEH_COLOR_ID')

top_colors = [row.VEH_COLOR_ID for row in df_top_veh_col.collect()]


df_speeding_charge = df_charge.distinct()\
    .filter(F.col('charge').contains('SPEED'))

df_lic_driver = df_person\
    .filter((F.col('PRSN_TYPE_ID') == 'DRIVER') & (~F.col('DRVR_LIC_TYPE_ID').isin(['NA','UNKNOWN','UNLICENSED'])))

df_charged_driver = df_lic_driver.alias('person')\
    .join(df_speeding_charge.alias('charge'), \
    (F.col('person.CRASH_ID') == F.col('charge.CRASH_ID')) & \
    (F.col('person.UNIT_NBR') == F.col('charge.UNIT_NBR')), \
    'inner')\
    .select(F.col('person.CRASH_ID'),F.col('person.UNIT_NBR'),F.col('person.DRVR_LIC_STATE_ID'))\
    .filter(F.col('DRVR_LIC_STATE_ID').isin(top_states))
    
df_top_maker = df_charged_driver.alias('driver')\
    .join(df_unit.alias('unit'), \
    (F.col('driver.CRASH_ID') == F.col('unit.CRASH_ID')) & \
    (F.col('driver.UNIT_NBR') == F.col('unit.UNIT_NBR')), \
    'inner')\
    .select(F.col('unit.CRASH_ID'),F.col('unit.UNIT_NBR'),F.col('unit.VEH_COLOR_ID'), F.col('unit.VEH_MAKE_ID')).distinct()\
    .filter(F.col('VEH_COLOR_ID').isin(top_colors))\
    .groupBy('VEH_MAKE_ID').agg(F.count('*').alias('maker_count'))\
    .orderBy(F.col('maker_count').desc()).limit(5)\
    .select(F.col('VEH_MAKE_ID').alias('top_vehicle_maker'))
    


try:
    if str(attr_job['op_header']).strip().lower() == 'true':
        op_header = True
    else:
        op_header = False
    df_top_maker.coalesce(1).write.save(attr_job['analysis_op_hdfs'], format = 'csv', sep = attr_job['op_delimiter'], mode='overwrite', header=op_header, escape='', quote='')
    print('INFO - Spark write Successful.')
    print(f"INFO - hdfs output : {attr_job['analysis_op_hdfs']}")    
except Exception as e:
    print(f'ERROR - spark write into hdfs failed with the error : {e}')
    raise SparkProcessException('spark write into hdfs failed.') from e


