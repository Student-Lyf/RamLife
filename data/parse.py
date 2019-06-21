from pathlib import Path
from csv import DictReader
from collections import defaultdict

from my_stuff.misc import init

# I think these are Atara, Daniella Symonds, and one other senior
EXPELLED = ["721110", "721958", "719951", "5"]  # last should be a typo
DAYS = {
	"A": 11, 
	"B": 11, 
	"C": 11, 
	"M": 11, 
	"R": 11, 
	"E": 7, 
	"F": 7, 
}
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

class DefaultDict (dict):  # can make an empty list of DAYS length
	@init
	def __init__(self, factory): super().__init__(self)
	def __missing__(self, key): 
		return self.factory (key)
	def __getitem__(self, key): 
		if key not in self: 
			value = self.factory (key)
			self [key] = value
			return value
		else: return super().__getitem__(key)

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
	periods: {"class_id": [Period]} = defaultdict(list)
	for entry in csv ("section_schedule"): 
		class_id = entry ["SECTION_ID"]
		day = entry ["WEEKDAY_NAME"]
		period = entry ["BLOCK_NAME"]
		try: int (period)  # "Mincha" will fail
		except: continue
		room = entry ["ROOM"]
		period = Period (day = day, period = period, room = room)
		periods [class_id].append (period)
	return periods

def get_schedule() -> {Student: {"letter": ["json"]}}: 
	students:    {"student-id": Student     } = get_students()
	class_names: {"class_id"  : "class name"} = get_class_names()
	periods:     {"class_id"  : [Period]    } = get_periods()

	result = DefaultDict(lambda key: DefaultDict (lambda key: [None] * DAYS [key]))
	for entry in csv ("schedule"):
		if entry ["SCHOOL_ID_SORT"] != "3" or entry ["STUDENT_ID"] in EXPELLED: continue
		student = students [entry ["STUDENT_ID"]]
		class_id = entry ["SECTION_ID"]
		course_id = class_id[:class_id.find ("-")] if "-" in class_id else class_id
		try: course_id = str (int (course_id))  # 09... -> 9...
		except: pass
		# if course_id in MISSING_CLASSES: continue
		times = periods [class_id]
		name = class_names [course_id]  # skip section (eg, -20, -10)
		# subject = Subject (
		# 	id = class_id, 
		# 	name = name, 
		# 	times = times
		# )
		for period in times: 
			result [student] [period.day] [int (period.period) - 1] = {
				"id": class_id,
				"room": period.room
			}

	return result


if __name__ == '__main__':
	# students = get_students()
	# teachers: {"class_id": "teacher"} = get_teachers()
	# class_names: {"class_id": "class name"} = get_class_names()
	# periods = get_periods()
	schedule = get_schedule()
	print (schedule)
