from lib.utils import logger
from lib.sections import reader as section_reader
from lib.faculty import reader as faculty_reader
from lib.sections import logic as section_logic
from lib import utils
import lib.services.firestore as firestore

if __name__ == "main":
  print("Indexing data...")

  course_names = logger.log_value("course names", section_reader.get_course_names())

  section_teachers = logger.log_value("section teachers", section_reader.get_section_faculty_ids())

  faculty_names = logger.log_value("faculty names", faculty_reader.get_faculty())

  zoom_links = logger.log_value("zoom links", section_reader.get_zoom_links())

  print(f"Found {len(zoom_links.keys())} zoom links")

  sections = logger.log_value("sections list", section_logic.get_sections(
    course_names = course_names,
    section_teachers = section_teachers,
    faculty_names = faculty_names,
    zoom_links = zoom_links,
    )
  )

  print("Finished data indexing.")

  if utils.args.should_upload:
    utils.logger.log_value(
      "data upload", firestore.upload_sections(sections)
    )
  
  utils.logger.info(f"Processed {len(sections)} faculty")

  
