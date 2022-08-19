from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql.types import *

spark = SparkSession.builder\
    .appName('File Stream 1')\
    .config('spark.sql.shuffle.partition', 3)\
    .config('')
