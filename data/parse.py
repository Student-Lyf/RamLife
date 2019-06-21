from pathlib import Path
from csv import DictReader

from my_stuff.misc import init

# I think these are Atara, Daniella Symonds, and one other senior
EXPELLED = ["721110", "721958", "719951", "5"]  # last should be a typo
# Periods in each day
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
	"""
	This class models a student. Contains: 
		- first: first name
		- last: last name
		- email: email address (w/o @ramaz.org)
		- id: student id
	""" 
	@init
	def __init__(self, first, last, email, id): pass
	def __repr__(self): return f"{self.first} {self.last} ({self.id})"

class Period: 
	"""
	This class models a time/location for a class to meet. Attributes: 
		- day: letter/weekday of the period
		- period: period that the class meets on the given day
		- room: where the class meets
	"""
	@init
	def __init__(self, day, period, room): pass
	def __repr__(self): return f"{self.day}{self.period} ({self.room})"

class DefaultDict (dict):
	"""
	The standard defaultdict is not enough in our case. 
	We have two uses for it: 
		1) To initialize a value to an empty list
		2) To initialize the schedule to a list of periods in the day
	Reasons we need to make our own DefaultDict: 
		1) We cannot initialize anything in a defaultdict (it is read-only)
		2) We cannot access the key in the default factory
	Usage: same as defaultdict except this time you can access the key as an arg
	"""
	@init
	def __init__(self, factory): super().__init__(self)
	def __missing__(self, key): 
		"""
		Provides the missing value using self.factory
		For some reason this is different than __setitem__. 
		"""
		return self.factory (key)
	def __getitem__(self, key): 
		"""
		By setting a value if it doesn't already exist, we can simplify code 
		that depends on keys existing by reading and writing at the same time 
		"""
		if key not in self:  # set it's default value and return
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

def get_periods() -> {"class id": [Period]}: 
	result = DefaultDict(lambda key: [])
	for entry in csv ("section_schedule"): 
		class_id = entry ["SECTION_ID"]
		day = entry ["WEEKDAY_NAME"]
		period = entry ["BLOCK_NAME"]
		try: int (period)  # "Mincha" will fail
		except: continue
		room = entry ["ROOM"]
		period = Period (day = day, period = period, room = room)
		result [class_id].append (period)
	return result

def get_schedule(
	students:    {"student-id": Student     },
	class_names: {"class_id"  : "class name"},
	periods:     {"class_id"  : [Period]    },
) -> {Student: {"letter": ["json"]}}: 

	result = DefaultDict(lambda key: DefaultDict (lambda key: [None] * DAYS [key]))
	for entry in csv ("schedule"):
		# Filter out lower/middle school (for now) and empty entries
		if entry ["SCHOOL_ID_SORT"] != "3" or entry ["STUDENT_ID"] in EXPELLED: continue
		student = students [entry ["STUDENT_ID"]]
		section_id = entry ["SECTION_ID"]
		course_id = (
			section_id[:section_id.find ("-")] 
			if "-" in section_id else section_id
		)
		try: course_id = str (int (course_id))  # 09... -> 9...
		except: pass
		times = periods [section_id]
		name = class_names [course_id]  # skip section (eg, -20, -10)
		for period in times: 
			result [student] [period.day] [int (period.period) - 1] = {
				"id": section_id,
				"room": period.room
			}

	return result


if __name__ == '__main__':
	students = get_students()
	teachers: {"class_id": "teacher"} = get_teachers()
	class_names: {"class_id": "class name"} = get_class_names()
	periods = get_periods()
	schedule = get_schedule(students, class_names, periods)
	print (schedule)
