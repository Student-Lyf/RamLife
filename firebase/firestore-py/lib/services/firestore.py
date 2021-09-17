from firebase_admin import firestore
from .firebase import app
from .. import data

_firestore = firestore.client()

students = _firestore.collection("students")
calendar = _firestore.collection("calendar")
courses = _firestore.collection("classses")
feedback = _firestore.collection("feedback")

def upload_users(users): 
	batch = _firestore.batch()
	for user in users:
		batch.create(students.document(user.email), user.json)
	batch.commit()

def upload_month(month, data): 
	calendar.document(str(month)).update({
		"month": month,
		"calendar": [day.to_json() for day in data]
	})

def upload_sections(sections): 
	batch = _firestore.bulk_writer()
	for section in sections:
		batch.create(courses.document(section.id), section.json)
	batch.commit()

def get_month(month): 
	return calendar.document(str(month)).get().to_dict()

def get_feedback(): return [
	data.Feedback.from_json(document.to_dict())
	for document in feedback.get()
]
