from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql.types import *


spark =  SparkSession.builder\
    .appName('kafka streaming demo')\
    .config('spark.streaming.stopGracefullyOnShutdown','true')\
    .getOrCreate()

sc = spark.sparkContext


