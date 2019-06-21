from pathlib import Path
from csv import DictReader
from collections import defaultdict

from my_stuff.misc import init

# I think these are Atara, Daniella Symonds, and one other senior
EXPELLED = ["721110", "721958", "719951", "5"]
MISSING_CLASSES = [  # I don't even know any more
	"093041", 
	"093034",
	"099001",
	"099014", 
	"099013", 
	"094011", 
	"093031",
	"090170", 
	"096411", 
	"090080", 
	"095001", 
	"097002", 
	"090370", 
	"094013", 
	"096413", 
	"090270", 
	"093044", 
	"090070", 
	"099002", 
	"091000", 
	"098013", 
	"097013", 
	"094012", 
	"097001", 
	"096001", 
	"095003", 
	"093042",
	"093042",
	"099003",
	"095011",
	"095400",
	"094010",
	"092000",
	"096513",
	"094048",
	"096003",
	"095002",
	"094014",
	"096002"
]

cd: Path = Path().cwd()

class Student: 
	@init
	def __init__(self, first, last, email, id): 
		self.classes: [int] = []
		self.subjects: [Subject] = []
	def __repr__(self): return f"{self.first} {self.last} ({self.id})"

class Period: 
	@init
	def __init__(self, day, period, room): pass
	def __repr__(self): return f"{self.day}{self.period} ({self.room})"

class Subject: 
	@init
	def __init__(self, id, name, teacher, times: [Period]): pass
	def __repr__(self): return f"{self.name} ({self.teacher})"


def csv(filename: str) -> DictReader: 
	return DictReader (open (cd / (filename + ".csv")))

def get_email(first: str, last: str) -> str: return last + first [0]

def get_students() -> {"student_id": Student}:
	result = {}
	for entry in csv ("students"): 
		first = entry ["First Name"]
		last = entry ["Last Name"]
		email = get_email (first, last)
		student_id = entry ["ID"]
		student = Student (
			first = first, 
			last = last,
			email = email,
			id = student_id
		)
		result [student_id] = student
	return result

def get_class_names() -> {"course_id": "course_name"}: return {
	entry ["ID"]: entry ["FULL_NAME"]
	for entry in csv ("courses")
}

def get_teachers() -> {"course id": "teacher"}: return {
	entry ["SECTION_ID"]: entry ["FACULTY_FULL_NAME"]
	for entry in csv ("section")
}

def get_periods(): 
	periods: {"class_id": [Period]} = defaultdict(lambda: [])
	for entry in csv ("section_schedule"): 
		class_id = entry ["SECTION_ID"]
		day = entry ["WEEKDAY_NAME"]
		period = entry ["BLOCK_NO"]
		room = entry ["ROOM"]
		period = Period (day = day, period = period, room = room)
		periods [class_id].append (period)
	return periods

def get_student_classes(
	students:    {"student-id": Student    },
	teachers:    {"class_id"  : "teacher"   },
	class_names: {"class_id"  : "class name"},
	periods:     {"class_id"  : [Period]    }
) -> {Student: [Subject]}: 
	
	result = defaultdict(lambda: [])
	for entry in csv ("schedule"):
		if entry ["SCHOOL_ID_SORT"] != "3" or entry ["STUDENT_ID"] in EXPELLED: continue
		student = students [entry ["STUDENT_ID"]]
		class_id = entry ["SECTION_ID"]
		course_id = class_id[:class_id.find ("-")] if "-" in class_id else class_id
		if course_id in MISSING_CLASSES: continue
		times = periods [class_id]
		teacher = teachers [class_id]
		name = class_names [course_id]  # skip section (eg, -20, -10)
		subject = Subject (
			id = class_id, 
			name = name, 
			teacher = teacher,
			times = times
		)
		result [student].append (subject)

	if MISSING_CLASSES: 
		print ("Could not find names for classes:")
		print (", ".join (MISSING_CLASSES))
		print()
	return result


if __name__ == '__main__':
	students = get_students()
	teachers: {"class_id": "teacher"} = get_teachers()
	class_names: {"class_id": "class name"} = get_class_names()
	periods = get_periods()
	classes = get_student_classes(
		students = students,
		teachers = teachers,
		class_names = class_names,
		periods = periods
	)
	print (classes)
