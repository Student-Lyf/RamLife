import logging
from .args import args
from colorama import init
from colorama import Fore, Back, Style

init(autoreset=True)
logging.VERBOSE = 15
reset = Style.RESET_ALL
def get_ansi(code): return f"\u001b[38;5;{code}m"

class ColorFormatter(logging.Formatter):
	def __init__(self, use_color = True):
		self.use_color = use_color

	FORMATS = {
		logging.DEBUG: Fore.WHITE,
		logging.VERBOSE: Style.BRIGHT + Fore.BLACK,
		logging.INFO: Fore.BLUE,
		logging.WARNING: Fore.YELLOW,
		logging.ERROR: Fore.RED,
	}

	def format(self, record):
		color = self.FORMATS[record.levelno]
		if self.use_color: 
			formatter = logging.Formatter(f"{color}[{record.levelname[0]}]{reset} %(message)s")
		else: 
			formatter = logging.Formatter(f"[{record.levelname[0]}] %(message)s")
		return formatter.format(record)

def verbose(self, message, *args, **kwargs): 
	if self.isEnabledFor(logging.VERBOSE):
		self._log(logging.VERBOSE, message, args, **kwargs) 

def debug(self, label, value, *args, **kwargs): 
	if self.isEnabledFor(logging.DEBUG): 
		self._log(logging.DEBUG, f"{label}: {value}", args, **kwargs)

logging.addLevelName(logging.VERBOSE, "VERBOSE")  # between INFO and DEBUG
logging.Logger.verbose = verbose
logging.Logger.debug = debug

logger = logging.getLogger("ramlife")
console_handler = logging.StreamHandler()
console_handler.setFormatter(ColorFormatter())
if args.verbose: 
	logger.setLevel(logging.VERBOSE)
	console_handler.setLevel(logging.VERBOSE)
elif args.debug:
	logger.setLevel(logging.DEBUG)
	console_handler.setLevel(logging.VERBOSE)
else: 
	logger.setLevel(logging.INFO)
	console_handler.setLevel(logging.INFO)
logger.addHandler(console_handler)

if args.debug: 
	file_handler = logging.FileHandler("debug.log")
	file_handler.setFormatter(ColorFormatter(False))
	file_handler.setLevel(logging.DEBUG)
	logger.addHandler(file_handler)

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