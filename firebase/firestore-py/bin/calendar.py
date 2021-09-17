from lib.utils.logger import logger
import lib.services.firestore as firestore

logger.debug("Debug", 5)
logger.verbose("Verbose")
logger.info("INFO")
logger.warning("Warning")
logger.error("Error")

def get_value(): return firestore.get_month(1)

# logger.log_value("value", get_value)
logger.log_progress("waiting", get_value)