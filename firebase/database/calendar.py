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
					"letter": day.letter
				}
			 for day in days
			}
		)
	batch.commit()
