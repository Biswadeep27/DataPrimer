from pyspark.sql import SparkSession
from pyspark.sql import functions as F
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

try:
    unit_df = spark.read.csv(attr_job['ip_unit'], header = True)
except Exception as e:
    print(f'ERROR - Spark read for unit file failed with the error : {e}')
    raise SparkProcessException('Spark process failed.') from e

try:
    charge_df = spark.read.csv(attr_job['ip_charges'], header = True)
except Exception as e:
    print(f'ERROR - Spark read for unit file failed with the error : {e}')
    raise SparkProcessException('Spark process failed.') from e

#business logic
two_wheeler_df = unit_df[F.col('VEH_BODY_STYL_ID') == 'MOTORCYCLE'].alias('unit')\
    .join(charge_df.alias('charge'), \
    (F.col('unit.CRASH_ID') == F.col('charge.CRASH_ID')) & \
    (F.col('unit.UNIT_NBR') == F.col('charge.UNIT_NBR')), \
    'inner')\
    .select(F.col('unit.CRASH_ID'),F.col('unit.UNIT_NBR'))\
    .groupBy('CRASH_ID','UNIT_NBR').count()\
    .selectExpr("count(*) as booked_count")\
    .withColumn('description',F.lit("Number of two wheelers booked"))\
    .select('description','booked_count')


try:
    if str(attr_job['op_header']).strip().lower() == 'true':
        op_header = True
    else:
        op_header = False
    two_wheeler_df.write.save(attr_job['analysis_op_hdfs'], format = 'csv', sep = attr_job['op_delimiter'], mode='overwrite', header=op_header, escape='', quote='')
    print('INFO - Spark write Successful.')
    print(f"INFO - hdfs output : {attr_job['analysis_op_hdfs']}")    
except Exception as e:
    print(f'ERROR - spark write into hdfs failed with the error : {e}')
    raise SparkProcessException('spark write into hdfs failed.') from e


