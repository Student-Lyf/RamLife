from lib.utils.logger import logger
from lib.sections.reader import reader as SectionReader
from lib.faculty.reader import reader as FacultyReader
print("Indexing data...")

courseNames = logger.log_value("course names", SectionReader.get_course_names())

sectionTeachers = logger.log_value("section teachers", SectionReader.getSectionFacultyIds())

facultyNames = logger.log_value("faculty names", FacultyReader.getFaculty())

zoomLinks = logger.log_value("zoom links", SectionReader.getZoomLinks())

print(f"Found {len(zoomLinks.keys())} zoom links")

sections = logger.log_value("sections list", SectionLogic.getSections(
  courseNames = courseNames,
  sectionTeachers = sectionTeachers,
  facultyNames = facultyNames,
  zoomLinks = zoomLinks,
  )
)

print("Finished data indexing.")

###
# Rest ?
###
