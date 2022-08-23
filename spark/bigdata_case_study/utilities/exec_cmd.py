from asyncio.log import logger
import sys
import logging
import time
import re
import logging
from subprocess import Popen, PIPE

log = logging.getLogger(__name__)

class ExecuteCmd(object):
    def __init__(self, cmd, cmd_desc=''):
        self.cmd = cmd
        self.error = ''
        self.output = ''
        self.returncode = 0
        self.cmd_desc = cmd_desc

    def execute(self):
        log.debug("")
        executing_command_str = "Executing the Command Argument \n" + "*" * 150 + "\n" + self.cmd + "\n" + "*" * 150
        if "-password" in executing_command_str:
            executing_command_str = self.remove_password_from_log(executing_command_str)
        log.debug(executing_command_str)
        output_string_header = "_" * 100 + "\nStandard Output:\n" + self.cmd + "\n" + "_" * 100
        error_string_header = "_" * 100 + "\nStandard Error:\n" + self.cmd + "\n" + "_" * 100
        start_time = time.time()
        try:
            subprocess = Popen(self.cmd, shell=True, stdout=PIPE, stderr=PIPE)
            output, error = subprocess.communicate()
        except Exception as err:
            self.error = str(err)
            end_time = time.time()
            exec_tm = "Command Failed after {0} Seconds".format(str(end_time - start_time))
            log.debug(exec_tm)
            log_txt = error_string_header + self.error + "\n" + "_" * 100
            log.error(log_txt)

            return False

        self.error = error.decode('utf-8').strip()
        self.output = output.decode('utf-8').strip()

        log_txt = "\n Exit Code: " + str(subprocess.returncode) + "\n" + output_string_header + "\n" + \
                  str(self.output) + "\n" + error_string_header + "\n" + str(self.error) + "\n" + "_" * 100
        log.debug(log_txt)
        end_time = time.time()
        exec_tm = "Command Succeeded after {0} Seconds".format(str(end_time - start_time))
        log.debug(exec_tm)
        self.returncode = subprocess.returncode
        if subprocess.returncode == 0:
            return True
        else:
            return False

    def getcommandoutput(self):
        return self.output.strip(' ').strip('\n')

    def getcommanderror(self):
        return self.error.strip(' ').strip('\n')
    
    def getreturncode(self):
        return self.returncode





