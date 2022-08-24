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


print(f"INFO - The hdfs input units : {attr_job['ip_unit']}")
#print(f"INFO - The hdfs input charges : {attr_job['ip_charges']}")
print(f"INFO - The hdfs input person : {attr_job['ip_primary_person']}")

try:
    df_unit = spark.read.csv(attr_job['ip_unit'], header = True)
except Exception as e:
    print(f'ERROR - Spark read for the unit file failed with the error : {e}')
    raise SparkProcessException('Spark process failed.') from e

# try:
#     df_charge = spark.read.csv(attr_job['ip_charges'], header = True)
# except Exception as e:
#     print(f'ERROR - Spark read for the charges file failed with the error : {e}')
#     raise SparkProcessException('Spark process failed.') from e

try:
    df_person = spark.read.csv(attr_job['ip_primary_person'], header = True)
except Exception as e:
    print(f'ERROR - Spark read for the person file failed with the error : {e}')
    raise SparkProcessException('Spark process failed.') from e

#business logic
# df_alcoholic_charges = df_charge\
#     .filter(F.lower(df_charge['CHARGE']).contains('alcohol'))\
#     .select('CRASH_ID','UNIT_NBR').distinct()

# df_crashed_car_units = df_unit\
#     .filter((F.lower(df_unit['VEH_BODY_STYL_ID']).contains('car')) | (df_unit['VEH_BODY_STYL_ID'] == 'NEV-NEIGHBORHOOD ELECTRIC VEHICLE'))

# df_charged_cars = df_crashed_car_units.alias('unit')\
#     .join(df_alcoholic_charges.alias('charge'), \
#     (F.col('unit.CRASH_ID') == F.col('charge.CRASH_ID')) & \
#     (F.col('unit.UNIT_NBR') == F.col('charge.UNIT_NBR')), \
#     'inner')\
#     .select(F.col('unit.CRASH_ID'),F.col('unit.UNIT_NBR')).distinct().alias('cars')\
#     .join(df_person.alias('person'), \
#     (F.col('cars.CRASH_ID') == F.col('person.CRASH_ID')) & \
#     (F.col('cars.UNIT_NBR') == F.col('person.UNIT_NBR')), \
#     'inner')\
#     .select(F.col('person.CRASH_ID'),F.col('person.UNIT_NBR'),F.col('person.DRVR_ZIP'))\
#     .groupBy('DRVR_ZIP').agg(F.count('*').alias('crashes_count'))\
#     .orderBy(F.col('crashes_count').desc()).limit(5)


df_crashed_car_units = df_unit\
    .filter((F.lower(df_unit['VEH_BODY_STYL_ID']).contains('car')) | (df_unit['VEH_BODY_STYL_ID'] == 'NEV-NEIGHBORHOOD ELECTRIC VEHICLE'))\
    .filter((F.lower(df_unit['CONTRIB_FACTR_1_ID']).contains('alcohol')) | (F.lower(df_unit['CONTRIB_FACTR_2_ID']).contains('alcohol')) | (F.lower(df_unit['CONTRIB_FACTR_P1_ID']).contains('alcohol')) \
    | (F.lower(df_unit['CONTRIB_FACTR_1_ID']).contains('drinking')) | (F.lower(df_unit['CONTRIB_FACTR_2_ID']).contains('drinking')) | (F.lower(df_unit['CONTRIB_FACTR_P1_ID']).contains('drinking')))

df_crashed_car_zip = df_crashed_car_units\
    .select(F.col('CRASH_ID'),F.col('UNIT_NBR')).distinct().alias('cars')\
    .join(df_person.alias('person'), \
    (F.col('cars.CRASH_ID') == F.col('person.CRASH_ID')) & \
    (F.col('cars.UNIT_NBR') == F.col('person.UNIT_NBR')), \
    'inner')\
    .select(F.col('person.CRASH_ID'),F.col('person.UNIT_NBR'),F.col('person.DRVR_ZIP'))\
    .groupBy('DRVR_ZIP').agg(F.count('*').alias('crashes_count')).cache()


df_top_crashes_null = df_crashed_car_zip\
    .orderBy(F.col('crashes_count').desc()).limit(5)\
    .select(F.col('DRVR_ZIP').alias('driver_zip_code'), 'crashes_count')\
    .fillna(value='null', subset=['driver_zip_code'])

df_top_crashes = df_crashed_car_zip\
    .filter(F.col('DRVR_ZIP').isNotNull())\
    .orderBy(F.col('crashes_count').desc()).limit(5)\
    .select(F.col('DRVR_ZIP').alias('driver_zip_code'), 'crashes_count')


if str(attr_job['op_header']).strip().lower() == 'true':
    op_header = True
else:
    op_header = False


try:
    df_top_crashes_null.coalesce(1).write.save(attr_job['analysis_op_hdfs_null'], format = 'csv', sep = attr_job['op_delimiter'], mode='overwrite', header=op_header, escape='', quote='')
    print('INFO - Spark write Successful for zip code with null.')
    print(f"INFO - hdfs output with null: {attr_job['analysis_op_hdfs_null']}")    
except Exception as e:
    print(f'ERROR - spark write into hdfs failed with the error : {e}')
    raise SparkProcessException('spark write into hdfs failed.') from e

try:
    df_top_crashes.coalesce(1).write.save(attr_job['analysis_op_hdfs'], format = 'csv', sep = attr_job['op_delimiter'], mode='overwrite', header=op_header, escape='', quote='')
    print('INFO - Spark write Successful for zip code without null.')
    print(f"INFO - hdfs output without null: {attr_job['analysis_op_hdfs']}")    
except Exception as e:
    print(f'ERROR - spark write into hdfs failed with the error : {e}')
    raise SparkProcessException('spark write into hdfs failed.') from e


