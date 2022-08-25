from airflow import DAG
from airflow.operators.http_operator import SimpleHttpOperator
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.operators.python import BranchPythonOperator
from airflow.models import TaskInstance, DagBag, DagModel, DagRun
from airflow.contrib.operators.ssh_operator import SSHOperator
from airflow.contrib.hooks.ssh_hook import SSHHook
from datetime import datetime, timedelta
import pendulum
import json
import requests
from airflow.models import Variable
from airflow.models.baseoperator import chain
from airflow.sensors.external_task_sensor import ExternalTaskSensor
import airflow, os, logging 
import airflow.settings
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.operators.dummy import DummyOperator

local_tz = pendulum.timezone("US/Eastern")

default_args = {
  'owner': 'airflow',
  'depends_on_past': False,
  'start_date': datetime(2022, 2, 8, tzinfo=local_tz),
  'email': ['biswadeep.upadhyay@gmail.com'],
  'email_on_failure': True,
  'email_on_retry': False,
  'retries': 0,
  'retry_delay': timedelta(minutes=5),
  'provide_context': True
}

dag = DAG(  os.path.basename(__file__).replace(".py",""),
        schedule_interval='0 */6 * * *' ,
        default_args=default_args,
        catchup=False,
        description = 'big data case study - hdp'
    )



#The commnads to trigger from airflow
cmd_sp_analysis_1 = "python3 /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/python/wrapper_spark_submit.py --config /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/properties/param_config.json --job sp_analysis_1"
cmd_sp_analysis_2 = "python3 /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/python/wrapper_spark_submit.py --config /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/properties/param_config.json --job sp_analysis_2"
cmd_sp_analysis_3 = "python3 /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/python/wrapper_spark_submit.py --config /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/properties/param_config.json --job sp_analysis_3"
cmd_sp_analysis_4 = "python3 /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/python/wrapper_spark_submit.py --config /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/properties/param_config.json --job sp_analysis_4"
cmd_sp_analysis_5 = "python3 /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/python/wrapper_spark_submit.py --config /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/properties/param_config.json --job sp_analysis_5"
cmd_sp_analysis_6 = "python3 /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/python/wrapper_spark_submit.py --config /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/properties/param_config.json --job sp_analysis_6"
cmd_sp_analysis_7 = "python3 /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/python/wrapper_spark_submit.py --config /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/properties/param_config.json --job sp_analysis_7"
cmd_sp_analysis_8 = "python3 /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/python/wrapper_spark_submit.py --config /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/properties/param_config.json --job sp_analysis_8"

cmd_hdfs_get_nas_1 = "sh /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/bin/hdfs_get_nas_global.sh -s /hdfsData/bdipoc/poc/outbound/casestudy_op/analysis_1/ -t /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/analysis_op/analysis_1.csv -m gh"
cmd_hdfs_get_nas_2 = "sh /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/bin/hdfs_get_nas_global.sh -s /hdfsData/bdipoc/poc/outbound/casestudy_op/analysis_2/ -t /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/analysis_op/analysis_2.csv -m gh"
cmd_hdfs_get_nas_3 = "sh /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/bin/hdfs_get_nas_global.sh -s /hdfsData/bdipoc/poc/outbound/casestudy_op/analysis_3/ -t /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/analysis_op/analysis_3.csv -m gh"
cmd_hdfs_get_nas_4 = "sh /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/bin/hdfs_get_nas_global.sh -s /hdfsData/bdipoc/poc/outbound/casestudy_op/analysis_4/ -t /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/analysis_op/analysis_4.csv -m gh"
cmd_hdfs_get_nas_5 = "sh /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/bin/hdfs_get_nas_global.sh -s /hdfsData/bdipoc/poc/outbound/casestudy_op/analysis_5/ -t /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/analysis_op/analysis_5.csv -m gh"
cmd_hdfs_get_nas_6 = "sh /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/bin/hdfs_get_nas_global.sh -s /hdfsData/bdipoc/poc/outbound/casestudy_op/analysis_6/ -t /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/analysis_op/analysis_6.csv -m gh"
cmd_hdfs_get_nas_7 = "sh /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/bin/hdfs_get_nas_global.sh -s /hdfsData/bdipoc/poc/outbound/casestudy_op/analysis_7/ -t /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/analysis_op/analysis_7.csv -m gh"
cmd_hdfs_get_nas_8 = "sh /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/bin/hdfs_get_nas_global.sh -s /hdfsData/bdipoc/poc/outbound/casestudy_op/analysis_8/ -t /hadoopData/bdipoc/poc/python/beepz/bigdata_case_study/analysis_op/analysis_8.csv -m gh"

start_op = DummyOperator(task_id='start_hdp_case_study',dag=dag)
end_op = DummyOperator(task_id='end_hdp_case_study', dag=dag)

et_sensor = ExternalTaskSensor(
    task_id='self_dag_dependency_case_study',
    external_dag_id='dag_ETLXXXXH_HDP_Spark_Case_Study',
    external_task_id=None, 
    allowed_states=['success'],
    execution_delta=timedelta(hours=6),
    queue=Variable.get("HDPEDGE"),
    dag=dag
)

sp_t1 = BashOperator(
    task_id='spark_hdp_case_study_1',
    bash_command=cmd_sp_analysis_1,
    execution_timeout=None,
    pool='default_pool',
    pool_slots=1,
    queue = Variable.get("HDPEDGE"),
    dag=dag)

sp_t2 = BashOperator(
    task_id='spark_hdp_case_study_2',
    bash_command=cmd_sp_analysis_2,
    execution_timeout=None,
    pool='default_pool',
    pool_slots=1,
    queue = Variable.get("HDPEDGE"),
    dag=dag)

sp_t3 = BashOperator(
    task_id='spark_hdp_case_study_3',
    bash_command=cmd_sp_analysis_3,
    execution_timeout=None,
    pool='default_pool',
    pool_slots=1,
    queue = Variable.get("HDPEDGE"),
    dag=dag)

sp_t4 = BashOperator(
    task_id='spark_hdp_case_study_4',
    bash_command=cmd_sp_analysis_4,
    execution_timeout=None,
    pool='default_pool',
    pool_slots=1,
    queue = Variable.get("HDPEDGE"),
    dag=dag)

sp_t5 = BashOperator(
    task_id='spark_hdp_case_study_5',
    bash_command=cmd_sp_analysis_5,
    execution_timeout=None,
    pool='default_pool',
    pool_slots=1,
    queue = Variable.get("HDPEDGE"),
    dag=dag)

sp_t6 = BashOperator(
    task_id='spark_hdp_case_study_6',
    bash_command=cmd_sp_analysis_6,
    execution_timeout=None,
    pool='default_pool',
    pool_slots=1,
    queue = Variable.get("HDPEDGE"),
    dag=dag)

sp_t7 = BashOperator(
    task_id='spark_hdp_case_study_7',
    bash_command=cmd_sp_analysis_7,
    execution_timeout=None,
    pool='default_pool',
    pool_slots=1,
    queue = Variable.get("HDPEDGE"),
    dag=dag)

sp_t8 = BashOperator(
    task_id='spark_hdp_case_study_8',
    bash_command=cmd_sp_analysis_8,
    execution_timeout=None,
    pool='default_pool',
    pool_slots=1,
    queue = Variable.get("HDPEDGE"),
    dag=dag)

get_t1 = BashOperator(
    task_id='hdfs_gen_nas_case_study_1',
    bash_command=cmd_hdfs_get_nas_1,
    execution_timeout=None,
    pool='default_pool',
    pool_slots=1,
    queue = Variable.get("HDPEDGE"),
    dag=dag)

get_t2 = BashOperator(
    task_id='hdfs_gen_nas_case_study_2',
    bash_command=cmd_hdfs_get_nas_2,
    execution_timeout=None,
    pool='default_pool',
    pool_slots=1,
    queue = Variable.get("HDPEDGE"),
    dag=dag)

get_t3 = BashOperator(
    task_id='hdfs_gen_nas_case_study_3',
    bash_command=cmd_hdfs_get_nas_3,
    execution_timeout=None,
    pool='default_pool',
    pool_slots=1,
    queue = Variable.get("HDPEDGE"),
    dag=dag)

get_t4 = BashOperator(
    task_id='hdfs_gen_nas_case_study_4',
    bash_command=cmd_hdfs_get_nas_4,
    execution_timeout=None,
    pool='default_pool',
    pool_slots=1,
    queue = Variable.get("HDPEDGE"),
    dag=dag)

get_t5 = BashOperator(
    task_id='hdfs_gen_nas_case_study_5',
    bash_command=cmd_hdfs_get_nas_5,
    execution_timeout=None,
    pool='default_pool',
    pool_slots=1,
    queue = Variable.get("HDPEDGE"),
    dag=dag)

get_t6 = BashOperator(
    task_id='hdfs_gen_nas_case_study_6',
    bash_command=cmd_hdfs_get_nas_6,
    execution_timeout=None,
    pool='default_pool',
    pool_slots=1,
    queue = Variable.get("HDPEDGE"),
    dag=dag)

get_t7 = BashOperator(
    task_id='hdfs_gen_nas_case_study_7',
    bash_command=cmd_hdfs_get_nas_7,
    execution_timeout=None,
    pool='default_pool',
    pool_slots=1,
    queue = Variable.get("HDPEDGE"),
    dag=dag)


get_t8 = BashOperator(
    task_id='hdfs_gen_nas_case_study_8',
    bash_command=cmd_hdfs_get_nas_8,
    execution_timeout=None,
    pool='default_pool',
    pool_slots=1,
    queue = Variable.get("HDPEDGE"),
    dag=dag)

chain(et_sensor, start_op,
    [sp_t1, sp_t2, sp_t3, sp_t4, sp_t5, sp_t6, sp_t7, sp_t8],
    [get_t1, get_t2, get_t3, get_t4, get_t5, get_t6, get_t7, get_t8], end_op)

