from firebase_admin import firestore

db = firestore.client()
STUDENTS = "students"

def upload_students (students: ["Student obj"]):
	batch = db.batch()
	for student in students: 
		doc = db.collection (STUDENTS).document (student.username)
		batch.set (doc, student.output())
	batch.commit()

def add_credentials(students):
	collection = db.collection ("credentials")
	batch = db.batch()
	for student in students:
		doc = collection.document(student.username)
		doc.set({"uid": student.uid})
	batch.commit()
