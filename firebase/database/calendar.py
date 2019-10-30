from firebase_admin import firestore
db = firestore.client()
collection = db.collection("calendar")

ROTATE = "A, B, or C day"
REGULAR = "M or R day"
FRIDAY = "Friday"

def upload_calendar(calendar): 
	batch = db.batch()
	for month, days in calendar.items(): 
		batch.set(
			collection.document(str (month)),
			{
				str (day.date.day): {
					"letter": day.letter,
					"special": "A, B, or C day" if day.letter in ['A', 'B', 'C'] else ("M or R day" if day.letter in ["M", "R"] else None)
				}
			 for day in days
			}
		)
	batch.commit()

def get_default_special(letter): 
	if letter in {'A', 'B', 'C'}:
		return ROTATE
	elif letter in {"M", "R"}: 
		return REGULAR
	elif letter in {"E", "F"}: 
		return FRIDAY 
	else: return None

def upload_month(month, calendar): 
	batch = db.batch()
	batch.set(
		collection.document(str (month)),
		{
			str (day.date.day): {
				"letter": day.letter,
				"special": day.special if day.special != None else get_default_special(day.letter)
			}
			for day in calendar
		}
	)
	batch.commit()
