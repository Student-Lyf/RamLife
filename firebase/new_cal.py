from pathlib import Path
from datetime import datetime
from data.calendar import Day

from birdseye import eye

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


@eye
def get_calendar(month): 
	# filename = data_dir / f"{MONTHS [month]}.csv"
	filename = data_dir / f"{month}.csv"

	with open(filename) as file: 
		file_contents = file.readlines()

	@eye
	def get_days(file, lines): 
		line_contents = tuple(file [line].split(",") for line in lines)
		for index, (letter, special, date) in enumerate(zip(*line_contents)):
			if not date.strip(): continue
			letter = letter.strip()
			if letter.endswith(" Day"):
				letter = letter [:letter.find(" Day")]
			date = datetime(CURRENT_YEAR, month, int (date))
			if index not in SCHOOL_DAYS or not letter or letter not in LETTERS: 
				yield Day(date, None, None)
				continue
			if special.endswith(" Schedule"): 
				special = special [:special.find(" Schedule")]
			if special.lower().startswith("modified"): special = "Modified"
			elif not special or special not in SPECIALS: special = None
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
	calendar = get_calendar (10)
	upload_month(10, calendar)
	days = set(range(1, 32))
	for entry in calendar:
		days.remove(entry.date.day)
	assert not days, f"Could not parse dates: {days}"
