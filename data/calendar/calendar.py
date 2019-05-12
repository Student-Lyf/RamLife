from pathlib import Path
from csv import DictReader as Reader
from datetime import datetime

from my_stuff.misc import init

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

def parse_calendar(path): 
	path = Path (path)
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

entries = parse_calendar(r"C:\users\levi\coding\flutter\ramaz\data\calendar\calendar.csv")
print (entries)
