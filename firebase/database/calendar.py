from firebase_admin import firestore
db = firestore.client()
collection = db.collection("calendar")

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
