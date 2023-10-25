from lib.utils import logger
from lib.sections import reader as section_reader
from lib.faculty import reader as faculty_reader
from lib.sections import logic as section_logic
from lib import utils
from lib import services

if __name__ == "__main__":
  print("Indexing data...")

  course_names = logger.log_value("course names", section_reader.get_course_names)

  section_teachers = logger.log_value("section teachers", section_reader.get_section_faculty_ids)

  faculty_names = logger.log_value("faculty names", faculty_reader.get_faculty)

  zoom_links = logger.log_value("zoom links", section_reader.get_zoom_links)

  print(f"Found {len(zoom_links.keys())} zoom links")

  sections = logger.log_value("sections list", lambda: section_logic.get_sections(
    course_names = course_names,
    section_teachers = section_teachers,
    faculty_names = faculty_names,
    zoom_links = zoom_links,
    )
  )

  print("Finished data indexing.")

  if utils.args.should_upload:
    utils.logger.log_progress(
      "data upload", lambda: services.upload_sections(sections)
    )
  else:
    print("Did not upload sections data. Use the --upload flag.")
  
  utils.logger.info(f"Processed {len(sections)} sections")

  
