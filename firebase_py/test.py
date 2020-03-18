from random import shuffle

from data.student import Student, Period
from data.subjects import Subject
from main import init
init()
from database.students import upload_students
from database.classes import batch_upload as upload_classes

TEST_HOMEROOM = "TEST_HOMEROOM"

SUBJECTS = [
	"Art",
	"English",
	"Spanish",
	"French",
	"Physics",

	"Chemistry",
	"Biology",
	"Calculus",
	"Physical Education",
	"Tech",

	"History",
]

ROOMS = [
	"307",
	"206",
	"504",
	"603",
	"205",

	"704",
	"605",
	"305",
	"401",
	"406",

	"701",
]

def get_subjects(): 
	result = [
		Subject(
			name = subject_name, 
			id = f"TEST_{subject_name.upper()}",
			teacher = f"Ms. {subject_name}"
		)
		for subject_name in SUBJECTS
	]
	result.append(Subject(
		name = "Homeroom",
		id = TEST_HOMEROOM,
		teacher = "Mr. Advisor"
	))
	result.append(Subject(
		name = "Lunch",
		id = "TEST_LUNCH",
		teacher = "Grade dean",
	))
	return result

def get_day(): 
	temp_subjects = SUBJECTS.copy()
	shuffle(temp_subjects)

	temp_rooms = ROOMS.copy()
	shuffle(temp_rooms)

	result = [
		Period(room = room, id = f"TEST_{subject.upper()}").output()
		for subject, room in zip(temp_subjects, temp_rooms)
	]
	result.insert(7, Period(room = "AUD", id = "TEST_LUNCH").output())

	return result

def upload(classes, student): 
	upload_classes(classes)
	upload_students([student])

if __name__ == "__main__":
	username = "ramazapptest@gmail.com"
	first = "Apple"
	last = "Test"
	homeroom = TEST_HOMEROOM
	homeroom_location = "507"
	subjects = get_subjects()
	letters = ["A", "B", "C", "M", "R", "E", "F"]
	days = {
		letter: get_day()
		for letter in letters
	}
	student = Student(
		username = username,
		first = first,
		last = last,
		homeroom = homeroom,
		homeroom_location = homeroom_location,
		**days,
	)
	print ([subject.id for subject in subjects])
	upload(subjects, student)

