from lib.utils.logger import logger

logger.debug("Debug", 5)
logger.verbose("Verbose")
logger.info("INFO")
logger.warning("Warning")
logger.error("Error")

def get_value(): return 42

logger.log_value("value", get_value)
logger.log_progress("waiting", get_value)