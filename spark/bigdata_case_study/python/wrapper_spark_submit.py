import os
import re
import sys
import time
import json
import argparse
from datetime import datetime
sys.path.append('/hadoopData/bdipoc/poc/python/beepz/bigdata_case_study')
from utilities import (
    ExecuteCmd,
    logging,
    initialize_logger
) 

##customized exception class
class CaseStudyException(Exception):
    '''This is a customized exception for this case study'''


def purge_log_file(dir, pattern):
    '''Purge Old Files Created by this process.

    :param: 
        dir - Provide the Directoy name where the logfile is places
        pattern - Provide the pattern of the file name to be removed.
    :return: None - it removes the log files of the matched pattern after 7 days.
    '''
    print(f"looking for log files with the pattern '{pattern}' older than 7 days in the dir '{dir}' for purging.")
    cnt = 0
    now = time.time()
    for f in os.listdir(dir):
        f = os.path.join(dir, f)
        if re.search(pattern, f) and os.stat(f).st_mtime < now - 7 * 86400:
            cnt += 1
            print(f"Housekeeping of old log files - Removing : {f}")
            os.remove(f)
    if cnt == 0:
        print('No log files found for purging. Ignoring purging.')


def get_logger(proc: str):
    '''This function initializes the logger module for this session.
    :param:
        - proc : process name which will be an unique identifier for a log file.
    :return: logging
    '''
    if not os.path.isdir(LOG_FOLDER):
        os.mkdir(LOG_FOLDER)
    file_name = LOG_FILE + proc + '_'
    log_file = datetime.now().strftime(file_name+'%d%m%Y_%H%M%S')
    initialize_logger(LOG_FOLDER,LOG_LEVEL,log_file,WRITE_MODE)
    print(f'The spark logger for this session is initiated at: {LOG_FOLDER}/{log_file}.log')
    global LOG_FULL_PATH
    LOG_FULL_PATH = f'{LOG_FOLDER}/{log_file}.log'
    os.chmod(f'{LOG_FOLDER}/{log_file}.log', 0o666)
    purge_log_file(LOG_FOLDER,file_name)
    return logging


def extract_yarn_log(cmdout: str) -> bool:
    '''This function extracts the yarn log from cluster after spark-submit initialization for a particular session. 
    :param : cmdout - collected command ouput after a spark-submit
    :return: True or False
    '''
    try:
        yarn_application_ids = re.findall(r'application_\d{13}_\d{4}', cmdout)
        if len(yarn_application_ids):
            yarn_application_id = yarn_application_ids[0]
            log.info(f'The yarn application id for this session: {yarn_application_id}')
            yarn_command = 'yarn logs -applicationId ' + yarn_application_id + " -log_files stdout"
            log.info('Yarn log extraction command - ' + yarn_command)
            command_exec = ExecuteCmd(yarn_command)
            if command_exec.execute():
                log.info('Yarn log extraction completed for - ' + yarn_application_id )
                log.info('=========================================adding the yarn log - stdout here.=====================================')
                if command_exec.getcommandoutput():
                    log_out = command_exec.getcommandoutput()
                    log.info(f"yarn log out: {log_out}")
                else:
                    log_out = command_exec.getcommanderror()
                    log.info(f"yarn log out: {log_out}")
                return True
            else:
                log.error('Yarn log extraction failed for  - ' + yarn_application_id )
                return False
        else:
            log.warning("Unable to locate Yarn log extraction ")
            return False
    except Exception as e:
        log.error(f'Yarn log extraction failed with the error {e}')
        return False


def spark_submit(config: str, script: str) -> bool:
    '''This function creates the spark submit command and submits the applcaition to the cluster. 
    :param : 
        - config : input paramter config file of type json.
        - script : base python filemame of the pyspark script which also happens to be the jobname. 
    :return: True or False
    '''
    pyspark_script = f"/{str(PROJECT_FOLDER).strip('/')}/python/{script}.py"
    log.info(f'The pyspark script: {pyspark_script}')

    cmd_spark_submit = f'''spark-submit  --master yarn --deploy-mode cluster --conf "spark.yarn.maxAppAttempts=1"  --conf "spark.pyspark.python=/usr/bin/python3" --conf "spark.pyspark.driver=/usr/bin/python3" --files {config}#{os.path.basename(config)} --executor-memory {EXECUTOR_MEMORY} --driver-memory {DRIVER_MEMORY} --num-executors {NUM_EXECUTORS} --executor-cores {EXECUTOR_CORES} {pyspark_script} {os.path.basename(config)} {script}'''
    
    log.info(f'The prepared spark-submit command: {cmd_spark_submit}')
    log.info('Triggering the spark-submit.')

    command_exec = ExecuteCmd(cmd_spark_submit)
    if command_exec.execute():
        if command_exec.getcommandoutput():
            log_out = command_exec.getcommandoutput()
            log.info(f"yarn log out from the successful completion of spark submit: {log_out}")
        else:
            log_out = command_exec.getcommanderror()
            log.info(f"yarn error out from the successful completion of spark submit: {log_out}")
        if extract_yarn_log(log_out):
            log.info('Yarn log extraction completed with SUCCESS.')
        return True
    else:
        if command_exec.getcommandoutput():
            log_out = command_exec.getcommandoutput()
            log.info(f"yarn log out from the failed spark submit: {log_out}")
        else:
            log_out = command_exec.getcommanderror()
            log.info(f"error out from the failed spark submit: {log_out}")
        if extract_yarn_log(log_out):
            log.info('Yarn log extraction completed with SUCCESS.')
        return False



def main():
    '''The main function whhich will get executed when this wrapper will be triggered from cli'''
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--config",
        help="full path of parameter config json file"
    )
    parser.add_argument(
        "--job",
        help="spark job name"
    )
    args = parser.parse_args()


    if args.config:
        v_param_config = str(args.config).strip()
    else:
        raise CaseStudyException('Mandatory argument --config is missing')

    if args.job:
        v_job_indicator = str(args.job).strip()
    else:
        raise CaseStudyException('Mandatory argument --job is missing')




    try:
        with open(v_param_config,'r') as attr_conf:
            attr_all = json.load(attr_conf)
        print('The config file read is successful.')
        attr_global = [x for x in attr_all if str(x['job_indicator']).strip() == 'global'][0]
        attr_job = [x for x in attr_all if str(x['job_indicator']).strip() == v_job_indicator.strip()][0]
        print('Global and Job specific config read is successful.')
    except Exception as e:
        raise CaseStudyException(f'the case_study {v_job_indicator} failed due to error while parsing config Json file: {v_param_config}') from e

    global PROJECT_FOLDER, LOG_FOLDER, LOG_LEVEL, WRITE_MODE, LOG_FILE, log
    PROJECT_FOLDER = attr_global['project_dir']
    LOG_FOLDER = attr_global['log_dir']
    LOG_LEVEL = getattr(logging,attr_global['log_level'])
    WRITE_MODE = attr_global['log_write_mode']
    LOG_FILE = 'case_study_'

    log = get_logger(v_job_indicator)
    log.info(f'Welcome to spark case study job : {v_job_indicator}.')

    global EXECUTOR_MEMORY, DRIVER_MEMORY, NUM_EXECUTORS, EXECUTOR_CORES
    EXECUTOR_MEMORY = attr_job['executor-memory']
    DRIVER_MEMORY = attr_job['driver-memory']
    NUM_EXECUTORS = attr_job['num-executors']
    EXECUTOR_CORES = attr_job['executor-cores']

    try:
        cmd = ExecuteCmd('echo hello world')
        cmd.execute()
        log.info('exec_cmd is working.')
    except Exception as e:
        raise CaseStudyException('exec_cmd failed.') from e

    if spark_submit(v_param_config,v_job_indicator):
        log.info('Spark Process: SUCCESS')
        log.info(f'Please check the log file {LOG_FULL_PATH} for details.')
    else:
        log.error('Spark Process: FAILED')
        raise CaseStudyException(f'spark submit failed. Please check the log file {LOG_FULL_PATH} for details.')
    

if __name__ == '__main__':
    #customizing print statement
    old_print = print
    def timestamped_print(*args, **kwargs):
        logTime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        printheader = logTime + " " + "wrapper SPARK - "
        old_print(printheader, *args, **kwargs)
    print = timestamped_print

    print('The wrapper script for spark-submit started.')
    main()