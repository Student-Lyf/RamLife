from pathlib import Path
from csv import DictReader as Reader
from datetime import datetime
from data.calendar import Day
from firebase_admin import firestore

db = firestore.client()
calendar = db.collection("calendar")

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

def upload_calendar(entries): 
	batch = db.batch()
	for month in range (1, 13): 
		batch.set(
			calendar.document(str (month)),
			{}
		)
	for entry in entries: 
		doc = calendar.document(str (entry.date.month))
		batch.update(doc, entry.output())
	batch.commit()

