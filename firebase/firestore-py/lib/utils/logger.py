import logging
from .args import args
from colorama import init
from colorama import Fore, Back, Style

init(autoreset=True)
logging.VERBOSE = 15
reset = u"\x1b[0m"
def get_ansi(code): return f"\u001b[38;5;{code}m"

class ColorFormatter(logging.Formatter):
	FORMATS = {
		logging.DEBUG: Fore.WHITE,
		logging.VERBOSE: Style.BRIGHT + Fore.BLACK,
		logging.INFO: Fore.BLUE,
		logging.WARNING: Fore.YELLOW,
		logging.ERROR: Fore.RED,
	}

	def format(self, record):
		color = self.FORMATS[record.levelno]
		formatter = logging.Formatter(f"{color}[{record.levelname[0]}]{reset} %(message)s")
		# return f"{color} [{record.levelname[0]}] {record.message}"
		return formatter.format(record)
		# return formatter.format(record)


def verbose(self, message, *args, **kwargs): 
	if self.isEnabledFor(logging.VERBOSE):
		self._log(logging.VERBOSE, message, args, **kwargs) 

def debug(self, label, value, *args, **kwargs): 
	if self.isEnabledFor(logging.DEBUG): 
		self._log(logging.DEBUG, f"{label}: {value}", args, **kwargs)

if args.debug: level = logging.DEBUG
elif args.verbose: level = logging.VERBOSE
else: level = logging.INFO
logging.addLevelName(logging.VERBOSE, "VERBOSE")  # between INFO and DEBUG
logging.Logger.verbose = verbose
logging.Logger.debug = debug
logger = logging.getLogger("ramlife")
logger.setLevel(level)
handler = logging.StreamHandler()
handler.setFormatter(ColorFormatter())
logger.addHandler(handler)

def log_value(label, function): 
	"""
	Emits logs before and after returning a value.
	
	Emits a [verbose] log before calling [func], then a [debug] log with the 
	result, and finally returns the result. 
	
	The [label] should be all lower case, since it will appear in the middle
	of the logged messages. 
	"""

	logger.verbose(f"Getting {label}")
	value = function();
	logger.debug(f"Value of {label}", value)
	return value

def log_progress(label, function): 
	logger.info(f"Starting {label}")
	function()
	logger.info(f"Finished {label}")

logger.log_progress = log_progress
logger.log_value = log_value