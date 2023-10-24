from lib.sports import reader as sports_reader
from lib import services
from lib import utils
from datetime import date

if __name__ == "__main__":

    sports_schedule = utils.logger.log_value("sports schedule", sports_reader.read_sports)
    utils.logger.verbose(f"Found {len(sports_schedule)} sports games")

    utils.logger.info("Finished processing sports games")

    if utils.args.should_upload:
        utils.logger.log_progress(
            "data upload", 
            lambda: services.upload_sports(sports_schedule)
        )
    else: 
      utils.logger.warning("Did not upload student data. Use the --upload flag.")
      print(sports_schedule)
    utils.logger.info(f"Processed {len(sports_schedule)} sports games.")




