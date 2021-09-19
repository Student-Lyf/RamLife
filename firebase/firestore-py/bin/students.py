from lib import data
from lib import utils
from lib.readers import students as student_reader
from lib import services

from collections import defaultdict
from firebase_admin import delete_app

if __name__ == '__main__':
	utils.logger.info("Indexing students...")

	student_courses = utils.logger.log_value("student courses", student_reader.read_student_courses)
	students = utils.logger.log_value("students", student_reader.read_students)
	periods = utils.logger.log_value("section periods", student_reader.read_periods)
	homeroom_locations = defaultdict(lambda: "Unavailable")
	utils.logger.debug("Homeroom locations", homeroom_locations)
	semesters = utils.logger.log_value("semesters", student_reader.read_semesters)

	schedules, homerooms, seniors = utils.logger.log_value(
		"schedules", lambda: student_reader.get_schedules(
			students = students,
			periods = periods, 
			student_courses = student_courses,
			semesters = semesters,
		)
	)

	student_reader.set_students_schedules(
		schedules = schedules,
		homerooms = homerooms, 
		homeroom_locations = homeroom_locations,
	)
	students_with_schedules = list(schedules.keys())
	utils.logger.debug("Student schedules", students_with_schedules)
	data.User.verify_schedule(students_with_schedules)

	test_users = [
		data.User.empty(
			email = tester ["email"],
			first = tester ["first"], 
			last = tester ["last"], 
		)
		for tester in utils.constants.testers
	]
	utils.logger.verbose(f"Found {len(test_users)} testers")
	utils.logger.debug("Testers", test_users)
	students_with_schedules.extend(test_users)

	utils.logger.info("Finished processing students")

	if utils.args.should_upload:
		utils.logger.log_progress(
			"data upload", 
			lambda: services.upload_users(students_with_schedules)
		)
	else: utils.logger.warning("Did not upload student data. Use the --upload flag.")

	utils.logger.info(f"Processed {len(students_with_schedules)} users.")


