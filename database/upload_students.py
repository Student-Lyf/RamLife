from data.student import Student
from data.schedule import PeriodData
from db import get_db

db = get_db()
student = Student.random()
STUDENTS = "students"

def to_dict(list): return {
	str (index + 1): value
	for index, value in enumerate (list)
}

def upload_student (student): 
	doc = db.collection(STUDENTS).document(student.username)
	doc.set (student.output())

def upload_students (students: [Student]): 
	batch = db.batch()
	for student in students: 
		doc = db.collection (STUDENTS).document (student.username)
		batch.set (doc, student.output())
	batch.commit()

if __name__ == '__main__':
	first = "Levi"
	last = "Lesches"
	username = Student.get_username (first, last)
	id_ = 770
	A = to_dict ([
		PeriodData (room = "Beit Knesset", id = 12).output(),
		PeriodData (room = "503", id = 1).output(),
		PeriodData (room = "304", id = 2).output(),
		PeriodData (room = "303", id = 3).output(),
		PeriodData (room = "GYM", id = 4).output(),
		PeriodData (room = "604", id = 5).output(),
		PeriodData (room = "AUD", id = 6).output(),
		PeriodData (room = "506", id = 3).output(),
		PeriodData (room = "506", id = 7).output(),
		PeriodData (room = "601", id = 8).output(),
		PeriodData (room = "304", id = 9).output()
	])
	B = to_dict ([
		PeriodData (room = "Beit Knesset", id = 12).output(),
		PeriodData (room = "503", id = 1).output(),
		PeriodData (room = "507", id = 2).output(),
		None,
		PeriodData (room = "304", id = 8).output(),
		PeriodData (room = "303", id = 11).output(),
		PeriodData (room = "GYM", id = 4).output(),
		PeriodData (room = "AUD", id = 6).output(),
		PeriodData (room = "304", id = 9).output(),
		None,
		PeriodData (room = "501", id = 3).output(),
	])
	C = to_dict ([
		PeriodData (room = "Beit Knesset", id = 12).output(),
		PeriodData (room = "303", id = 11).output(),
		PeriodData (room = "604", id = 5).output(),
		PeriodData (room = "506", id = 3).output(),
		PeriodData (room = "304", id = 2).output(),
		PeriodData (room = "704", id = 13).output(),
		PeriodData (room = "AUD", id = 6).output(),
		PeriodData (room = "503", id = 1).output(),
		PeriodData (room = "301", id = 8).output(),
		PeriodData (room = "506", id = 3).output(),
		PeriodData (room = "501", id = 14).output(),
	])
	M = to_dict ([
		PeriodData (room = "Beit Knesset", id = 12).output(),
		PeriodData (room = "GYM", id = 4).output(),
		PeriodData (room = "506", id = 3).output(),
		PeriodData (room = "503", id = 1).output(),
		PeriodData (room = "604", id = 5).output(),
		PeriodData (room = "703", id = 10).output(),
		PeriodData (room = "AUD", id = 6).output(),
		PeriodData (room = "401", id = 8).output(),
		PeriodData (room = "301", id = 7).output(),
		PeriodData (room = "506", id = 2).output(),
		PeriodData (room = "301", id = 11).output()
	])
	R = to_dict ([
		PeriodData (room = "Beit Knesset", id = 12).output(),
		PeriodData (room = "704", id = 13).output(),
		PeriodData (room = "305", id = 2).output(),
		PeriodData (room = "306", id = 7).output(),
		PeriodData (room = "506", id = 3).output(),
		PeriodData (room = "406", id = 8).output(),
		PeriodData (room = "304", id = 11).output(),
		PeriodData (room = "AUD", id = 6).output(),
		PeriodData (room = "304", id = 9).output(),
		PeriodData (room = "604", id = 5).output(),
		PeriodData (room = "503", id = 1).output(),
	])
	E = to_dict ([
		PeriodData (room = "Beit Knesset", id = 12).output(),
		PeriodData (room = "506", id = 3).output(),
		PeriodData (room = "704", id = 13).output(),
		PeriodData (room = "201", id = 7).output(),
		PeriodData (room = "604", id = 5).output(),
		PeriodData (room = "302", id = 2).output(),
		PeriodData (room = "503", id = 1).output(),
	])
	F = to_dict ([
		PeriodData (room = "Beit Knesset", id = 12).output(),
		PeriodData (room = "201", id = 11).output(),
		PeriodData (room = "301", id = 3).output(),
		PeriodData (room = "507", id = 8).output(),
		PeriodData (room = "304", id = 9).output(),
		PeriodData (room = "703", id = 10).output(),
		PeriodData (room = "604", id = 5).output(),
	])

	levi = Student (
		username = username,
		first = first,
		last = last,
		id = id_,
		A = A, 
		B = B, 
		C = C,
		M = M, 
		R = R,
		E = E, 
		F = F
	)

	upload_students([levi])
