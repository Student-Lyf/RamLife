from main import init
data_dir = init().parent / "data"

from datetime import datetime

from utils import CSVReader, DefaultDict
from data.calendar import Day
from database.calendar import upload_calendar

from birdseye import eye

CURRENT_YEAR = datetime.today().year
VALID_YEARS = [CURRENT_YEAR, CURRENT_YEAR - 1, CURRENT_YEAR + 1]

DAYS_IN_MONTHS = [
	31,  # Jan
	29,  # Feb
	31,  # Mar
	30,  # Apr
	31,  # May
	30,  # June
	31,  # July
	31,  # Aug
	30,  # Sep
	31,  # Oct
	30,  # Nov
	31,  # Dec
]
# This tells it which year to look for as a placeholder
MONTH_KEYS = {
	1: 0,
	2: 0,
	3: 0,
	4: 0,
	5: 0,
	6: 0,
	7: 0,
	8: 0,
	9: 1,
	10: 1,
	11: 1,
	12: 1,
}
# These correspond to the above indices
PLACEHOLDER_YEARS = [None, None]

def parse_calendar(): 
	result = DefaultDict (lambda month: [None] * DAYS_IN_MONTHS [month - 1])
	for entry in CSVReader (data_dir / "calendar.csv"): 
		if entry ["SCHOOL_ID"] != "Upper": continue
		month, day, year = map (int, entry ["CALENDAR_DATE"].split("/"))
		if year not in VALID_YEARS: continue
		# Make sure we know what year we're in
		PLACEHOLDER_YEARS [MONTH_KEYS [month]] = year
		date = datetime (year, month, day)
		letter = entry ["DAY_NAME"]
		result [date.month] [date.day - 1] = Day (date, letter)
	return result

@eye
def fill (calendar):  # Fill in no school days with letter: null
	for year in range (1, 13): 
		if year not in calendar: calendar [year]
	calendar = dict(calendar)
	for month_index, month in calendar.items():
		for index, day in enumerate (month): 
			if day is None: 
				year = PLACEHOLDER_YEARS [MONTH_KEYS [month_index]]
				# skip Feb. 29th if not a leap year
				if month_index == 2 and index == 28 and year % 4: month.pop()
				else: 
					date = datetime (
						year, 
						month_index, 
						index + 1
					)
					month [index] = Day (date, None)

result = parse_calendar()
fill (result)
upload_calendar (result)