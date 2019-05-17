from pathlib import Path
from csv import DictReader as Reader
from datetime import datetime

from my_stuff.misc import init

DATA_ROWS = [6, 13, 20, 27, 34]

class Day: 
	@init
	def __init__(self, date, letter): pass
	def __repr__(self): 
		if (self.letter): return f"{self.date}: {self.letter}"
		else: return f"{self.date}: No School"

def parse_entry(entry) -> Day: 
	month, day, year = entry ["date"].split("/")
	date = datetime(int (year), int (month), int (day))
	letter = entry["letter"]
	return Day (date, letter)

def parse_letter_calendar(): 
	path = Path (r"C:\users\levi\coding\flutter\ramaz\data\calendar\calendar.csv")
	with path.open(newline = "") as file: 
		reader = Reader (
			file, 
			fieldnames = [
				"id", 
				"year",
				"date",
				"semester",
				"day_number",
				"letter",
				"school_open"
			]
		)
		next(reader)  # skip first line
		return [
			parse_entry(row)
			for row in reader
		]

def parse_full_calendar(): 
	folder = Path(r"C:\users\levi\coding\flutter\ramaz\data\calendar")
	for month in range (1, 13):  # months of the year
		if month == 7 or month == 1: continue  # they skip July
		file = folder / f"{month}.csv"
		text = file.read_text().split("\n")
		for row in DATA_ROWS: 
			print (text [row - 1])

		return


print (parse_full_calendar())