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
    .config('spark.sql.shuffle.partition', 2)\
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


print(f"INFO - The hdfs input unit : {attr_job['ip_unit']}")
print(f"INFO - The hdfs input person : {attr_job['ip_primary_person']}")

try:
    df_unit = spark.read.csv(attr_job['ip_unit'], header = True)
except Exception as e:
    print(f'ERROR - Spark read for the unit file failed with the error : {e}')
    raise SparkProcessException('Spark process failed.') from e


try:
    df_person = spark.read.csv(attr_job['ip_primary_person'], header = True)
except Exception as e:
    print(f'ERROR - Spark read for the person file failed with the error : {e}')
    raise SparkProcessException('Spark process failed.') from e

#business logic
df_vehicle_maker = df_unit.alias('unit').join(df_person.alias('person'), \
    (F.col('unit.CRASH_ID') == F.col('person.CRASH_ID')) & \
    (F.col('unit.UNIT_NBR') == F.col('person.UNIT_NBR')), \
    'inner')\
    .select(F.col('unit.CRASH_ID'),F.col('unit.UNIT_NBR'),F.col('unit.VEH_MAKE_ID'),F.col('person.PRSN_INJRY_SEV_ID'))\
    .distinct()\
    .filter(F.col('PRSN_INJRY_SEV_ID').isin(['KILLED','NON-INCAPACITATING INJURY','POSSIBLE INJURY','INCAPACITATING INJURY']))\
    .groupBy('VEH_MAKE_ID').agg(F.count('CRASH_ID').alias('veh_count'))\
    .select('VEH_MAKE_ID','veh_count')\
    .withColumn('veh_rank', F.dense_rank().over(Window.orderBy(F.col('veh_count').desc())))\
    .where((F.col('veh_rank') >= 5) & (F.col('veh_rank') <= 15 ))\
    .withColumnRenamed('VEH_MAKE_ID', 'veh_make_id')


try:
    if str(attr_job['op_header']).strip().lower() == 'true':
        op_header = True
    else:
        op_header = False
    df_vehicle_maker.coalesce(1).write.save(attr_job['analysis_op_hdfs'], format = 'csv', sep = attr_job['op_delimiter'], mode='overwrite', header=op_header, escape='', quote='')
    print('INFO - Spark write Successful.')
    print(f"INFO - hdfs output : {attr_job['analysis_op_hdfs']}")    
except Exception as e:
    print(f'ERROR - spark write into hdfs failed with the error : {e}')
    raise SparkProcessException('spark write into hdfs failed.') from e


