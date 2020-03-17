# TODO: integrate Student classes seamlessly
# TODO: Log properly

from main import init as initFirebase, cd
initFirebase()
import auth as FirebaseAuth
from database.students import upload_students

data_dir = cd.parent / "data"
from utils import CSVReader, DefaultDict  # uses key
from data.student import Student as StudentRecord, Period as PeriodRecord
from collections import defaultdict  # does not use key
from itertools import combinations

from my_stuff.misc import init

# I think these are Atara, Daniella Symonds, and one other senior
EXPELLED = ["721110", "721958", "719951", "5"]  # last should be a typo
MISSING_ROOMS = set()
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
JUNIORS = set()

class Student: 
	"""
	This class models a student. Contains: 
		- first: first name
		- last: last name
		- email: email address (w/ @ramaz.org)
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
	def __init__(self, day, period, room, id = None): pass
	def __repr__(self): return f"{self.day}{self.period} ({self.room})"

def get_students() -> {"student_id": Student}:
	result = {}
	for entry in CSVReader (data_dir / "students.csv"): 
		first = entry ["First Name"]
		last = entry ["Last Name"]
		student_id = entry ["ID"]
		email = entry ["Student E-mail"]
		student = Student (
			first = first, 
			last = last,
			email = email,
			id = student_id
		)
		result [student_id] = student
	return result

def get_periods(bundle = False) -> (dict, dict): 
	result = DefaultDict(lambda key: [])
	homerooms: {"class id": "room"} = {}
	for entry in CSVReader (data_dir / "section_schedule.csv"): 
		class_id = entry ["SECTION_ID"]
		day = entry ["WEEKDAY_NAME"]
		period = entry ["BLOCK_NAME"]
		room = entry ["ROOM"]
		try: int (period)  # "Mincha" will fail
		except: 
			if period == "HOMEROOM": 
				if bundle: 
					period = Period(day = day, period = period, room = room, id = class_id)
				else: 
					homerooms [class_id] = room
					continue
			else: continue
		else: period = Period (day = day, period = period, room = room, id = class_id)
		assert type(period) is Period, f"Expected Period, got {period}"
		result [class_id].append (period)
	return dict (result), homerooms

class MeetingPeriod: 
	def __init__(self, letter, period): 
		self.letter = letter
		self.period = period

	def __eq__(self, other): return (
		self.letter == other.letter and 
		self.period == other.period
	)

	def from_entry(entry: dict): return MeetingPeriod(
		letter = entry ["WEEKDAY_NAME"],
		period = entry ["BLOCK_NAME"]
	)

def get_student_classes(): 
	result = defaultdict(list)
	for entry in CSVReader(data_dir / "schedule.csv"): 
		result [entry ["STUDENT_ID"]].append(entry ["SECTION_ID"])
	return result

def get_period_meetings(): 
	result = defaultdict(list)
	for entry in CSVReader(data_dir / "section_schedule.csv"):
		result [entry ["SECTION_ID"]].append(MeetingPeriod.from_entry(entry))
	return result

def get_terms(): return {
	entry ["SECTION_ID"]: [
		entry ["TERM1"] == "Y", entry ["TERM2"] == "Y", 
	]
	for entry in CSVReader(data_dir / "section.csv")
}

def get_schedule(
	students:    {"student-id": Student     },
	periods:     {"class_id"  : [Period]    },
	terms:  {"section_id": [bool("term1"), bool("term2")]},	
	# homerooms:   {"section_id": "room"      },
) -> ({Student: {"letter": ["json"]}}, {Student: "homeroom location"}): 
	homerooms = {}
	result = DefaultDict(lambda key: DefaultDict (lambda key: [None] * DAYS [key]))
	for entry in CSVReader (data_dir / "schedule.csv"):
		# Filter out lower/middle school (for now) and empty entries
		if entry ["SCHOOL_ID"] != "Upper" or entry ["STUDENT_ID"] in EXPELLED: continue
		student = students [entry ["STUDENT_ID"]]
		section_id = entry ["SECTION_ID"]
		if "UADV" in section_id: 
			# homerooms [student] = homerooms [section_id]
			homerooms [student] = section_id
			continue
		
		if not terms [section_id] [1]: continue
		if section_id.startswith("12"): JUNIORS.add(student)
		broken = False  # workaround for classes not in section_schedule.csv
		try: times = periods [section_id]
		except KeyError: 
			course_id = section_id
			if "-" in course_id: course_id = course_id [:course_id.find ("-")]
			# if section_id.startswith("UADV") and not section_id.startswith("UADV11"): 
			MISSING_ROOMS.add(course_id)
			broken = True
			continue
		for period in times: 
			result [student] [period.day] [int (period.period) - 1] = {
				"id": section_id,
				"room": period.room if not broken else None
			}
	return result, homerooms

def setup(
	schedules: {Student: {"letter": ["JSON"]}},
	homerooms: {Student: "section_id"},
	homeroom_locations: {"section_id": "room"}
) -> [StudentRecord]: 
	result = []
	for student, schedule in schedules.items():
		result.append (
			StudentRecord (
				username = student.email.lower(),
				first = student.first,
				last = student.last,
				homeroom = homerooms [student] if student not in JUNIORS else "SENIOR_HOMEROOM",
				# homeroom = ""
				homeroom_location = "Unavailable",
				# homeroom_location = (
				# 	homeroom_locations [homerooms [student]] 
				# 	if student not in JUNIORS else 
				# 	None
				# ),
				**{  # A, B, C, M, R, E, F
					day: [
						(None if period is None else 
							PeriodRecord (room = period ["room"], id = period ["id"]).output()
						)
						for period in day_schedule
					]
					for day, day_schedule in schedule.items()
				}
			)
		)
	return result

def main(students, upload, auth, create): 
	if upload: 
		print ("Uploading student data...")
		upload_students(students)
	if auth: 
		print ("Authenticating students...")
		print ("Indexing students...")
		records = []
		if create: 
			for student in students: 
				try: FirebaseAuth.create_user(student)
				except FirebaseAuth.Firebase.AuthError: pass 
		for student in students:
			user = FirebaseAuth.get_user(student.username)
			student.uid = user.uid
			record = FirebaseAuth.get_record(user)
			records.append (record)
		print ("Adding Google as a provider...")
		FirebaseAuth.add_provider(records) 
	if upload or auth: 
		print (f"Successfully configured {len (students)} students.")

if __name__ == '__main__':
	print ("Gathering data...")
	from argparse import ArgumentParser
	parser = ArgumentParser()
	parser.add_argument(
		"--upload", 
		action = "store_true", 
		help = "Whether or not to upload everyone's schedules"
	)
	parser.add_argument(
		"--auth", 
		action = "store_true",
		help = (
			"Whether or not to authenticate everyone "
			"(eg, save credentials to the database)"
		)
	)
	parser.add_argument(
		"--create", 
		action = "store_true",
		help = "Whether or not to recreate student FirebaseAuth accounts. This takes time"
	)
	args = parser.parse_args()

	student_classes = get_student_classes()
	period_meetings = get_period_meetings()
	students = get_students()
	levi = students ["721604"]
	periods, homeroom_locations = get_periods()
	terms = get_terms()
	schedules, homerooms = get_schedule (students, periods, terms)
	if MISSING_ROOMS:
		print ("Missing room #'s for courses:")
		print (MISSING_ROOMS)
	students = setup(schedules, homerooms, homeroom_locations)
	print ("Setting up Firebase...")
	main(students, upload = args.upload, auth = args.auth, create = args.create)

	if False:
		print("Testing")
		from classes import *
		class_names = get_class_names()
		teachers = get_teachers()
		subjects, errors = get_subjects(names = class_names, teachers = teachers)
		for student in students: 
			for schedule in [student.A, student.B, student.C, student.M ,student.R, student.E, student.F]:
				for json in schedule: 
					if json is None: continue
					section_id = json ["id"]
					# print(section_id)
					assert section_id.split("-") [0].lstrip("0") in class_names.keys(), section_id
					assert section_id in teachers.keys(), section_id
					# break
				# break
			# break

	print ("Finished!")