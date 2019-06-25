from main import init
init()
from utils import CSVReader
from data.subjects import Subject
from database.classes import batch_upload

SPECIAL_CASES = ["126000-0-00"]  # see notes

def get_class_names() -> {"course_id": "course_name"}: return {
	entry ["ID"]: entry ["FULL_NAME"]
	for entry in CSVReader ("courses")
	if entry ["SCHOOL_ID"] == "Upper"
}
	
def get_teachers() -> {"section_id": "teacher"}: 
	result = {}
	last = None
	for entry in CSVReader ("section"):
		if entry ["SCHOOL_ID"] != "Upper": continue
		section_id = entry ["SECTION_ID"]
		teacher = entry ["FACULTY_FULL_NAME"]
		if not teacher: 
			if not last: 
				raise ValueError (f"Cannot infer teacher of {section_id}")
			teacher = last
		else: last = teacher
		result [section_id] = teacher
	return result

def get_subjects(names, teachers): 
	error = set()
	subjects = []
	for section_id, teacher in teachers.items():
		if section_id in SPECIAL_CASES: continue
		course_id = section_id
		if "-" in course_id: course_id = course_id [:course_id.find ("-")]
		try: course_id = str (int (course_id))
		except ValueError: pass
		try: name = class_names [course_id]
		except KeyError: 
			error.add (course_id)
			continue
		subjects.append (
			Subject (
				id = section_id, 
				name = name,
				teacher = teacher,
			)
		)
	return subjects, error

		
if __name__ == '__main__':
	print ("Gathering data...")
	class_names = get_class_names()
	teachers = get_teachers()
	subjects, errors = get_subjects(names = class_names, teachers = teachers)

	if errors: 
		print ("Missing names for ")
		print (errors)

	print ("Uploading to Firebase...")
	batch_upload (subjects)