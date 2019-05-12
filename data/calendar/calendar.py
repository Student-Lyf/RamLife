from pathlib import Path
from csv import DictReader as Reader
from datetime import datetime

def parse_entry(entry): 
	month, day, year = entry ["date"].split("/")
	# print (entry["date"].split("/"))
	date = datetime(int (year), int (month), int (day))
	letter = entry["letter"]
	return date, letter

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
print (len (entries))
