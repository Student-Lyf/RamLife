from firebase_admin import firestore

db = firestore.client()
classes = db.collection("classes")

def batch_upload(subjects):
	batches = []
	count = 0
	for subject in subjects: 
		if not count % 500: 
			batches.append (db.batch())
		doc = classes.document(subject.id)
		batches [-1].set(doc, subject.output())
		count += 1
	for batch in batches: batch.commit()
