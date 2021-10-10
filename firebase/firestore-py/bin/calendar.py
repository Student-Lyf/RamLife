from firebase_admin import delete_app
import csv

import lib.services as firebase
import lib.utils as utils

import lib.data as data
def is_date_line(index): (index - 2) % 7 == 0
def is_letter_line(index): (index - 4) % 7 == 0
def is_special_line(index): (index - 5) % 7 == 0

SUMMER_MONTHS = {7, 8}

def get_calendar(month): 
	with open(utils.dir.get_month(month)) as file: 
		lines = list(csv.reader(file))

	calendar = []
	for index, line in enumerate(lines):
		if is_date_line(index): date_line = line
		elif is_letter_line(index): letter_line = line
		elif is_special_line(index): 
			special_line = line
			calendar.extend(Day.get_list(
				date_line = date_line,
				name_line = name_line,
				special_line = special_line,
				month = month,
			))
	return calendar


if __name__ == '__main__':
	utils.logger.info("Processing calendar...")
	for month in range(1, 13): 
		# Handle summer months
		if month in SUMMER_MONTHS: 
			utils.logger.verbose(f"Setting a blank calendar for {month} in the summer")
			if utils.args.should_upload: 
				firebase.upload_month(month, data.get_empty_calendar(month))
			continue

		# Parse, verify, and upload {month}.csv
		month_calendar = utils.logger.log_value(
			f"calendar for {month}", lambda: data.get_default_calendar(month)
		)
		verified = data.Day.verify_calendar(month, month_calendar)
		assert verified, f"Could not properly parse calendar for {month}"
		if (utils.args.should_upload): 
			firebase.upload_month(month, month_calendar)

	# Cleanup
	if not utils.args.should_upload: 
		utils.logger.warning("Did not upload the calendar. Use the --upload flag.")
	delete_app(firebase.app)
	utils.logger.info("Calendar processed")

