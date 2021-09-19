from lib import utils
from lib.faculty import reader as faculty_reader
from lib.sections import reader as section_reader
from lib.students import reader as student_reader
from lib.faculty import logic as faculty_logic
from lib.data.student import User
import lib.services.firestore as firestore


if __name__ == "main":
	utils.logger.info("Indexing data...")

	faculty = utils.logger.log_value(
		"faculty objects", faculty_reader.getFaculty()
		)

	section_teachers = utils.logger.log_value(
		"section teachers", section_reader.getSectionFacultyIds()
		)
	
	faculty_sections = utils.logger.log_value(
		"faculty sections", faculty_logic.getFacultySections(
			faculty = faculty,
			sectionTeachers = section_teachers
		) 
	)

	periods = utils.logger.log_value(
		"periods", student_reader.read_periods()
	)

	faculty_with_schedule = utils.logger.log_value(
		"faculty with schedule", faculty_logic.get_faculty_with_schedule(
			faculty_sections = faculty_sections,
			section_periods = periods
		)
	)

	User.verify_schedule(faculty_with_schedule)

	utils.logger.info("Finished data indexing.")

	if utils.args.should_upload:
		utils.logger.log_value(
			"data upload", firestore.upload_users(faculty_with_schedule)
		)
	
	utils.logger.info(f"Processed {faculty_with_schedule} faculty")

	

