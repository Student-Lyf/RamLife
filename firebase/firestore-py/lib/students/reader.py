import csv
from collections import defaultdict

import lib.data as data
import lib.utils as utils

def read_students(): 
	with open(utils.dir.students) as file: 
		return_dict = {}
		for row in csv.DictReader(file):
			if row["ID"] == '': print(f"No ID for {row['Email']}")
			if row ["ID"] in utils.constants.corrupted_students: continue

			return_dict[row["ID"]] = data.User(
				first = row ["First Name"],
				last = row ["Last Name"],
				email = row ["Email"].lower(),
				id = str(row ["ID"]),
			)
		return return_dict


def read_periods():
	homeroom_locations = {}
	periods = defaultdict(list)
	with open(utils.dir.section_schedule) as file: 
		for row in csv.DictReader(file):
			if row ["SCHOOL_ID"] != "Upper": continue
			section_id = row ["SECTION_ID"]
			day = row ["WEEKDAY_NAME"]
			period_str = row ["BLOCK_NAME"]
			room = row ["ROOM"]
			# Handle homerooms
			try: 
				period_num = int(float(period_str))
				 
			except ValueError:
				if period_str == "HOMEROOM": 
					homeroom_locations [section_id] = room
				continue
			periods [section_id].append(data.Period(
				day = day,
				room = room,
				id = section_id,
				period = period_num
			))
	return periods

def read_student_courses():
	courses = defaultdict(list)
	with open(utils.dir.schedule) as file:
		for row in csv.DictReader(file):
			if row ["SCHOOL_ID"] != "Upper": continue
			student = row ["STUDENT_ID"]
			if student in utils.constants.corrupted_students: continue
			courses [student].append(row ["SECTION_ID"])
	return courses

def read_semesters():
	with open(utils.dir.section) as file: return {
		row ["SECTION_ID"]: data.Semesters(
			semester1 = row ["TERM1"] == "Y",
			semester2 = row ["TERM2"] == "Y",
			section_id = row ["SECTION_ID"],
		)
		for row in csv.DictReader(file)
		if row ["SCHOOL_ID"] == "Upper"
	}

def get_schedules(students, periods, student_courses, semesters): 
	homerooms = {}
	seniors = set()
	result = defaultdict(data.DayDefaultDict)
	ignored = set()

	for student, courses in student_courses.items():
		student = students [student]
		for section_id in courses:
			if "UADV" in section_id:
				homerooms [student] = section_id
				continue
			# if section_id in utils.constants.ignored_sections: continue

			try: semester = semesters [section_id]
			except KeyError as error:
				utils.logger.error(f"Section {section_id} was in schedule.csv but not in sections.csv")
				raise error from None

			if (semester is not None and not (semester.semester1 if utils.constants.is_semester1 else semester.semester2)):
				continue
			elif section_id.startswith("12"): seniors.add(student)

			# in schedule.csv but not section_schedule.csv
			if section_id not in periods:
				ignored.add(section_id)
				continue

			for period in periods [section_id]:
				result [student] [period.day] [period.period - 1] = period

	for schedule in result.values(): schedule.populate(utils.constants.day_names)
	if ignored:
		utils.logger.warning(f"Ignored {len(ignored)} classes")
		utils.logger.verbose(f"Ignored classes {ignored}")
		utils.logger.debug(f"Ignored classes", ignored)
	return result, homerooms, seniors

def set_students_schedules(schedules, homerooms, homeroom_locations):
	for student, schedule in schedules.items():
		if student.id in utils.constants.ignored_students: continue
		student.homeroom = "SENIOR_HOMEROOM" if student not in homerooms else homerooms [student]
		student.homeroom_location = "Unavailable" if student not in homerooms else homeroom_locations [homerooms [student]]
		student.schedule = schedule
