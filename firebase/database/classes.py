from firebase_admin import firestore

db = firestore.client()
classes = db.collection("classes")

def batch_upload(subjects):
	batch = db.batch()
	for subject in subjects: 
		doc = classes.document(subject.id)
		batch.set(doc, subject.output())
	batch.commit()
