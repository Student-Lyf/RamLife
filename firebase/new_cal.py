from pathlib import Path
from datetime import datetime
from data.calendar import Day

SCHOOL_DAYS = (1, 2, 3, 4, 5)
MONTHS = {9: "sept"}
CURRENT_YEAR = 2019
LETTERS = {"A", "B", "C", "M", "R", "E", "F"}
SPECIALS = {
	"Rosh Chodesh": "Rosh Chodesh",
	"Friday R.C.": "Friday Rosh Chodesh",
}


def get_lines(lines): return zip(
	range(4, 4 * 7 + 5, 7), 
	range(5, 5 * 7 + 6, 7),
	range(2, 2 * 7 * 3, 7), 
)


def get_calendar(month): 
	filename = data_dir / f"{MONTHS [month]}.csv"
	with open(filename) as file: 
		file_contents = file.readlines()

	def get_days(file, lines): 
		line_contents = tuple(file [line].split(",") for line in lines)
		for index, (letter, special, date) in enumerate(zip(*line_contents)):
			if not date.strip(): continue
			date = datetime(CURRENT_YEAR, month, int (date))
			if index not in SCHOOL_DAYS or not letter: 
				yield Day(date, None, None)
			if letter.endswith(" Day"):
				letter = letter [:letter.find(" Day")]
			if special.endswith(" Schedule"): 
				special = special [:special.find(" Schedule")]
			if letter not in LETTERS: continue
			if not special: special = None
			elif special.lower().startswith("modified"): special = "Modified"
			else: special = SPECIALS [special]
			yield Day (date, letter, special)

	return [
		day
		for lines in get_lines(file_contents)
		for day in get_days(file_contents, lines)
	]

if __name__ == "__main__":
	from main import init, get_path
	init()
	from database.calendar import upload_month
	
	data_dir = get_path().parent / "data" / "calendar"
	calendar = get_calendar (9)
	upload_month(9, calendar)
