from pathlib import Path
from datetime import datetime
from data.calendar import Day

from main import init, cd

data_dir = cd.parent / "data" / "calendar"
SCHOOL_DAYS = (1, 2, 3, 4, 5)
CURRENT_YEAR = 2019
LETTERS = {"A", "B", "C", "M", "R", "E", "F"}
SPECIALS = {
	"Rosh Chodesh": "Rosh Chodesh",
	"Friday R.C.": "Friday Rosh Chodesh",
	"Early Dismissal": "Early Dismissal",
	"Modified": "Modified",
}
MONTHS = [
	31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
]

def get_lines(): return zip(
	range(4, 5 * 7 + 5, 7), 
	range(5, 5 * 7 + 6, 7),
	range(2, 2 * 7 * 3, 7), 
)

def get_calendar(month): 
	filename = data_dir / f"{month}.csv"

	with open(filename) as file: 
		file_contents = file.readlines()

	def get_days(file, lines): 
		line_contents = tuple(file [line].split(",") for line in lines)
		for index, (letter, special, date) in enumerate(zip(*line_contents)):
			if not date.strip(): continue
			letter = letter.strip()
			if letter.endswith(" Day"):
				letter = letter [:letter.find(" Day")].strip()
			year = CURRENT_YEAR if month > 7 else CURRENT_YEAR + 1
			date = datetime(year, month, int (date))
			if index not in SCHOOL_DAYS or not letter or letter not in LETTERS: 
				yield Day(date, None, None)
				continue
			if special.endswith(" Schedule"): 
				special = special [:special.find(" Schedule")]
			if special.lower().startswith("modified"): 
				special = "Modified"
			elif not special or special not in SPECIALS: special = None
			else: special = SPECIALS [special]
			yield Day (date, letter, special)

	return [
		day
		for lines in get_lines()
		for day in get_days(file_contents, lines)
	]

def get_empty(month): return [
	Day(datetime(CURRENT_YEAR if month > 7 else CURRENT_YEAR + 1, month, date), None, None)
	for date in range(1, 32)
]

if __name__ == "__main__":
	init()
	from database.calendar import upload_month
	from argparse import ArgumentParser
	parser = ArgumentParser()
	parser.add_argument(
		"--upload", 
		action = "store_true", 
		help = "Whether or not to upload everyone's schedules"
	)
	args = parser.parse_args()

	for month in range(1, 13): 
		if month in (7, 8): 
			if args.upload: 
				print(f"Uploading empty summer month {month}")
				upload_month(month, get_empty(month))
			continue

		print(f"Parsing month {month}")
		calendar = get_calendar (month)
		days = set(range(1, MONTHS [month - 1] + 1))
		for entry in calendar:
			days.remove(entry.date.day)
		assert not days, f"Month: {month}, days not found: {days}"
		if args.upload: 
			upload_month(month, calendar)
