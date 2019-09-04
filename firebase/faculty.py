from main import init
from classes import get_teachers
from students import get_periods, Period
from data.student import Student as TeacherRecord, Period as PeriodRecord
from utils import DefaultDict

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

class Teacher:
	def __init__(self, code: str): 
		self.code = code
		self.homeroom = None
	def __str__(self): return self.code
	def __repr__(self): return str(self)
	def __hash__(self): return hash(self.code)

def simplify_teachers(teachers) -> {Teacher: ["section_id"]}:
	result = {}
	teacher_codes = {}
	for section_id, teacher_code in teachers.items(): 
		if teacher_code in teacher_codes: 
			teacher = teacher_codes[teacher_code]
			list_of_periods = result [teacher]
		else: 
			teacher = Teacher(code = teacher_code)
			teacher_codes[teacher_code] = teacher
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
				username = teacher.code,
				first = teacher.code,
				last = teacher.code,
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
	init()
	teachers: {"section_id": "teacher"} = get_teachers(codes = True)
	teachers = simplify_teachers(teachers)
	# periods is a dict: {section_id: [Period]}
	# homeroom_locations is also a dict: {section_id: room}
	periods, homerooms = get_periods()
	teachers_schedule = get_teacher_schedule(teachers, periods, homerooms)
	if MISSING_ROOMS: 
		print ("Missing some room locations: ")
		print (MISSING_ROOMS)
	teacher_records = get_teacher_records(teachers_schedule)
	print (teacher_records [0])
