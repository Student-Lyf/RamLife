from students import get_periods, Period, main
from classes import get_teachers as get_faculty_classes
from data.student import Student as TeacherRecord, Period as PeriodRecord
from utils import DefaultDict, CSVReader

MISSING_ROOMS = set()
DAYS = {
	"A": 11, 
	"B": 11, 
	"C": 11, 
	"M": 11, 
	"R": 11, 
	"E": 7, 
	"F": 7, 
}

MISSING_EMAIL = set()

class Teacher:
	def __init__(self, code: str, first, last, email: str): 
		self.code = code
		self.first = first
		self.last = last
		self.email = email
		self.homeroom = None
	def __str__(self): return self.code
	def __repr__(self): return str(self)
	def __hash__(self): return hash(self.code)

def get_teachers(path): return {
	entry ["ID"]: Teacher (
		code = entry ["Email"],
		first = entry ["FirstName"],
		last = entry ["LastName"],
		email = entry ["Email"].lower()
	)
	for entry in CSVReader(path / "faculty.csv")
}

def simplify_teachers(teachers, classes) -> {Teacher: ["section_id"]}:
	result = {}
	for section_id, teacher_code in classes.items(): 
		if teacher_code not in teachers: 
			MISSING_EMAIL.add(teacher_code)
			continue

		teacher = teachers [teacher_code]
		if teacher in result: 
			list_of_periods = result [teacher]
		else: 
			list_of_periods = []
			result [teacher] = list_of_periods

		list_of_periods.append(section_id)
	return result

def get_teacher_schedule(
	teachers: {Teacher: ["section_id"]},
	periods: {"section_id": [Period]},
	homerooms: {"section_id": "room"},
) -> {Teacher: [Period]}:
	result = {}
	for teacher, section_id_list in teachers.items(): 
		teacher_entry = []
		for section_id in section_id_list: 
			try: 
				for period in periods [section_id]:
					assert type(period) is Period, f"Period for {teacher.code} is not a Period, it's {period}"
					teacher_entry.append(period)
			except KeyError: 
				if section_id in homerooms: 
					teacher.homeroom = homerooms[section_id]
					continue

				course_id = section_id
				if "-" in section_id:
					course_id = section_id.split("-") [0]
				MISSING_ROOMS.add(course_id)
		result [teacher] = teacher_entry

	return result

def get_teacher_records(schedules: {Teacher: [Period]}) -> [TeacherRecord]:
	result = []
	for teacher, schedule in schedules.items():
		full_schedule = DefaultDict(lambda key: [None] * DAYS [key])
		homeroom_location = None
		for index, period in enumerate (schedule): 
			
			assert type(period) is Period, f"Element {index} of {teacher.code} is not a period, it's {period}"
			full_schedule [period.day] [int(period.period) - 1] = {
				"id": period.id,
				"room": period.room
			}

		# generate the schedules
		for day in DAYS: 
			full_schedule [day]

		result.append(
			TeacherRecord(
				username = teacher.email,
				first = teacher.first,
				last = teacher.last,
				homeroom = teacher.homeroom,
				homeroom_location = None,
				**{
					day: [
						(None if period is None else 
							PeriodRecord(
								room = period ["room"],
								id = period ["id"]
							).output()
						)
						for period in day_schedule
					]
					for day, day_schedule in full_schedule.items()
				}
			)
		)

	return result

if __name__ == '__main__':
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

	from main import init, get_path
	# init()
	data_dir = get_path().parent / "data"
	teachers = get_teachers(data_dir)
	classes: {"section_id": "teacher"} = get_faculty_classes(codes = True)
	teachers = simplify_teachers(teachers, classes)
	# periods is a dict: {section_id: [Period]}
	# homeroom_locations is also a dict: {section_id: room}
	periods, homerooms = get_periods()
	teachers_schedule = get_teacher_schedule(teachers, periods, homerooms)
	if MISSING_ROOMS: 
		print ("Missing some room locations: ")
		print (MISSING_ROOMS)
		print()
	if MISSING_EMAIL: 
		print ("Couldn't resolve some faculty IDs:")
		print (MISSING_EMAIL)
		print()
	teacher_records = get_teacher_records(teachers_schedule)
	print()
	main(
		teacher_records, 
		upload = args.upload, 
		auth = args.auth, 
		create = args.create
	)


