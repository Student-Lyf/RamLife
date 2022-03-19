from lib import utils
from lib.faculty import reader as faculty_reader
from lib.sections import reader as section_reader
from lib.students import reader as student_reader
from lib.faculty import logic as faculty_logic
from lib.data.student import User
from lib import services


if __name__ == "__main__":
  utils.logger.info("Indexing data...")

  faculty = utils.logger.log_value(
    "faculty objects", faculty_reader.get_faculty
    )

  section_teachers = utils.logger.log_value(
    "section teachers", section_reader.get_section_faculty_ids
    )
 
  faculty_sections = utils.logger.log_value(
    "faculty sections", lambda: faculty_logic.get_faculty_sections(
      faculty = faculty,
      section_teachers = section_teachers
    ) 
  )
  
  periods = utils.logger.log_value(
    "periods", student_reader.read_periods
  )

  faculty_with_schedule = utils.logger.log_value(
    "faculty with schedule", lambda: faculty_logic.get_faculty_with_schedule(
      faculty_sections = faculty_sections,
      section_periods = periods
    )
  )

  User.verify_schedule(faculty_with_schedule)

  utils.logger.info("Finished data indexing.")

  if utils.args.should_upload:
    utils.logger.log_progress(
      "data upload", lambda: services.upload_users(faculty_with_schedule)
    )
  else:
    utils.logger.warning("Did not upload faculty. Use the --upload flag.")
  
  utils.logger.info(f"Processed {len(faculty_with_schedule)} faculty")

  

