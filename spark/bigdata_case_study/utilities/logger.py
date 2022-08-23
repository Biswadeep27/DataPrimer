# The logger function will create console handler with info and the debug file handler with level debug
import logging
import os.path
import datetime
import sys
try:
    from StringIO import StringIO ## for Python 2
except ImportError:
    from io import StringIO ## for Python 3

from sparkway.configuration import conf

log_capture_string = ""
logger = None

def get_log_string():
    global log_capture_string
    return log_capture_string.getvalue()


def initialize_logger(log_dir, logLevel, proc, write_mode):
    global logger
    if logger:
        for handler in logger.handlers[:]:
            logger.removeHandler(handler)
    else:
        logger = logging.getLogger()

    logger.setLevel(logLevel)
    # Console handler
    handler = logging.StreamHandler(sys.stdout)
    handler.setLevel(logging.INFO)
    formatter = logging.Formatter("%(asctime)s.%(msecs)03d - %(levelname)s  - Task(%(processName)s) - %(message)s", '%Y-%m-%d %H:%M:%S')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    # Debug handler
    logfile = proc + '.log'
    handler = logging.FileHandler(os.path.join(log_dir, logfile), write_mode)
    handler.setLevel(logging.DEBUG)
    formatter = logging.Formatter("%(asctime)s.%(msecs)03d - %(filename)s - %(levelname)s %(module)s - %(funcName)s: %(message)s",'%Y-%m-%d %H:%M:%S')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    global log_capture_string
    log_capture_string = StringIO()
    handler = logging.StreamHandler(log_capture_string)
    handler.setLevel(logging.DEBUG)
    formatter = logging.Formatter("%(asctime)s.%(msecs)03d - %(filename)s - %(levelname)s %(module)s - %(funcName)s: %(message)s",'%Y-%m-%d %H:%M:%S')
    handler.setFormatter(formatter)
    logger.addHandler(handler)