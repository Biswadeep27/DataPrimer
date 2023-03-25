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


print(f"INFO - The hdfs input : {attr_job['ip_primary_person']}")

try:
    person_df = spark.read.csv(attr_job['ip_primary_person'], header = True)
except Exception as e:
    print(f'ERROR - Spark read failed with the error : {e}')
    raise SparkProcessException('Spark process failed.') from e

#business logic
non_male = person_df.filter(person_df.PRSN_GNDR_ID.isin(['FEMALE','UNKNOWN','NA']))\
    .groupBy('CRASH_ID').count()\
    .select('CRASH_ID')


male_killed = person_df[(person_df.DEATH_CNT == '1') & (person_df.PRSN_GNDR_ID == 'MALE')]\
    .groupBy('CRASH_ID').count()\
    .select('CRASH_ID').subtract(non_male)\
    .selectExpr("count(CRASH_ID) as crash_count")\
    .withColumn('description',F.lit("Number of crashes where male were killed"))\
    .select('description','crash_count')

try:
    if str(attr_job['op_header']).strip().lower() == 'true':
        op_header = True
    else:
        op_header = False
    male_killed.write.save(attr_job['analysis_op_hdfs'], format = 'csv', sep = attr_job['op_delimiter'], mode='overwrite', header=op_header, escape='', quote='')
    print('INFO - Spark write Successful.')
    print(f"INFO - hdfs output : {attr_job['analysis_op_hdfs']}")    
except Exception as e:
    print(f'ERROR - spark write into hdfs failed with the error : {e}')
    raise SparkProcessException('spark write into hdfs failed.') from e



