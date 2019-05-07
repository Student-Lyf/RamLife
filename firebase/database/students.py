from firebase_admin import firestore

db = firestore.client()
STUDENTS = "students"

def upload_students (students): 
	batch = db.batch()
	for student in students: 
		doc = db.collection (STUDENTS).document (student.username)
		batch.set (doc, student.output())
	batch.commit()

def add_credentials(student):
	students = db.collection ("credentials")
	doc = students.document(student.username)
	doc.set({"uid": student.uid})
