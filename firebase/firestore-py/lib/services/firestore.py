from turtle import update
from firebase_admin import _DEFAULT_APP_NAME, firestore
from .firebase import app
from .. import data
from itertools import islice

_firestore = firestore.client()

students = _firestore.collection("students")
calendar = _firestore.collection("calendar")
courses = _firestore.collection("classes")
feedback = _firestore.collection("feedback")
dataRefresh = _firestore.collection("dataRefresh")

def upload_users(users): 
	batch = _firestore.batch()
	for user in users:
		batch.set(students.document(user.email), user.to_json())
	batch.commit()

def upload_month(month, data): 
	calendar.document(str(month)).update({
		"month": month,
		"calendar": [(day.to_json() if day is not None else None) for day in data]
	})

def upload_sections(sections):
	if len(sections) > 500:
		upload_sections(sections[:500])
		upload_sections(sections[500:])
		return
	batch = _firestore.batch()
	for section in sections:
		batch.set(courses.document(section.id), section.to_json())
	batch.commit()

def get_month(month): 
	return calendar.document(str(month)).get().to_dict()

def get_feedback(): return [
	data.Feedback.from_json(document.to_dict())
	for document in feedback.get()
]

def upload_userdate(date):
	dataRefresh.document("dataRefresh").update({
		"user": date
	}) 

def upload_caldate(date):
	dataRefresh.document("dataRefresh").update({
		"calendar": date
	})

# Note: users is a list of emails (str) not User objects
def update_user(users, section_id, meetings):
	query = students.where("email", "in", users).stream()
	batch = _firestore.batch()
	for user in query:
		user_dict = user.to_dict()
		for day, period, room in meetings:
			user_dict[day][int(period)-1] = {
				"id": section_id,
				"name": period,
				"room": room,
				"dayName": day
			}
		batch.set(students.document(user_dict["email"]), user_dict)
	
	batch.commit()

