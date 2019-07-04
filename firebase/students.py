# TODO: integrate Student classes seamlessly
# TODO: Log properly

from main import init
data_dir = init().parent / "data"
from utils import CSVReader, DefaultDict
import auth as FirebaseAuth
from data.student import Student as StudentRecord, Period as PeriodRecord
from database.students import upload_students, add_credentials

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

def get_email(first: str, last: str) -> str: return last + first [0]

def get_students() -> {"student_id": Student}:
	result = {}
	for entry in CSVReader (data_dir / "students.csv"): 
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

def get_periods() -> (dict): 
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
				homerooms [class_id] = room
			continue
		period = Period (day = day, period = period, room = room)
		result [class_id].append (period)
	return dict (result), homerooms

def get_schedule(
	students:    {"student-id": Student     },
	periods:     {"class_id"  : [Period]    },
	# homerooms:   {"section_id": "room"      },
) -> ({Student: {"letter": ["json"]}}, {Student: "homeroom location"}): 
	homerooms = {}
	result = DefaultDict(lambda key: DefaultDict (lambda key: [None] * DAYS [key]))
	for entry in CSVReader (data_dir / "schedule.csv"):
		# Filter out lower/middle school (for now) and empty entries
		if entry ["SCHOOL_ID_SORT"] != "3" or entry ["STUDENT_ID"] in EXPELLED: continue
		student = students [entry ["STUDENT_ID"]]
		section_id = entry ["SECTION_ID"]
		if section_id.startswith("11") or section_id.startswith("12"): JUNIORS.add(student)
		broken = False  # workaround for classes not in section_schedule.csv
		try: times = periods [section_id]
		except KeyError: 
			course_id = section_id
			if "-" in course_id: course_id = course_id [:course_id.find ("-")]
			if section_id.startswith("UADV") and not section_id.startswith("UADV11"): 
				# homerooms [student] = homerooms [section_id]
				homerooms [student] = section_id
				continue
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
				homeroom = homerooms [student] if student not in JUNIORS else None,
				homeroom_location = homeroom_locations [homerooms [student]] if student not in JUNIORS else None,
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
		students = {
			student.username.lower() + "@ramaz.org": student
			for student in students
		}
		records = []
		if create: 
			for student in students.values(): 
				try: user = FirebaseAuth.create_user(student)
				except FirebaseAuth.Firebase.AuthError: pass 
		for user in FirebaseAuth.get_users(): 
			student = students [user.email]
			student.uid = user.uid
			record = FirebaseAuth.get_record(user)
			records.append (record)
		print ("Adding Google as a provider...")
		FirebaseAuth.add_provider(records) 
		if create: 
			print ("Saving credentials to the database...")
			add_credentials(students.values())
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
		help = "Whether or not to authenticate everyone"
	)
	parser.add_argument(
		"--create", 
		action = "store_true",
		help = "Whether or not to recreate student FirebaseAuth accounts. This takes time"
	)
	args = parser.parse_args()

	students = get_students()
	periods, homeroom_locations = get_periods()
	# schedules, student_homerooms = get_schedule(students, periods, homeroom_locations)
	schedules, homerooms = get_schedule (students, periods)
	if MISSING_ROOMS:
		print ("Missing room #'s for courses:")
		print (MISSING_ROOMS)
	students = setup(schedules, homerooms, homeroom_locations)
	print ("Setting up Firebase...")
	main(students, upload = args.upload, auth = args.auth, create = args.create)
	print ("Finished!")
