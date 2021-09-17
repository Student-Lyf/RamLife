from firebase_admin import delete_app
# import lib.services.firebase as firebase
# import lib.services.firestore as firestore
import lib.services as firebase
# from lib.data.calendar import Day

import lib.utils as utils

def is_date_line(index): (index - 2) % 7 == 0
def is_letter_line(index): (index - 4) % 7 == 0
def is_special_line(index): (index - 5) % 7 == 0

SUMMER_MONTHS = {7, 8}

if __name__ == '__main__':
	utils.logger.info("Processing calendar...")
	for month in range(1, 13): 
		# Handle summer months
		if month in SUMMER_MONTHS: 
			utils.logger.verbose(f"Setting a blank calendar for {month} in the summer")
			if utils.args.should_upload: 
				firebase.upload_month(month, Day.get_empty_calendar(month))
			continue

		month_calendar = utils.logger.log_value(
			f"calendar for {month}", lambda: getCalendar(month)
		)
		verified = Day.verify_calendar(month, month_calendar)
		assert verified, f"Could not properly parse calendar for {month}"
		if (utils.args.should_upload): 
			firebase.upload_month(month, month_calendar)
	if not utils.args.should_upload: 
		utils.logger.warning("Did not upload the calendar. Use the --upload flag.")
	delete_app(firebase.app)
	utils.logger.info("Calendar processed")

