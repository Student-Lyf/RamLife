import reader

'''
A collection of functions to index course data.

No function in this class reads data from the data files, just works on them. 
This helps keep the program modular by seperating the data from 
the data indexing
'''

# Converts a section ID to a course ID.
def getCourseId(sectionId):
  result = sectionId[0:sectionId.index("-")]
  if result.startswith("0"):
    return result[1:]
  else:
    return result

#Do data and faculty first
#
#def getSections(courseNames, sectionTeachers, facultyNames, zoomlinks):
#  for sect_id, fac_id  in sectionTeachers.items():
#    Section(
#      id = sect_id,
#      name = courseNames[getCourseId(sect_id)],
#      teacher = facultyNames[fac_id].name)
