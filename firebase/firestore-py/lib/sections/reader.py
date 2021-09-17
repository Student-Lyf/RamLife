import csv
import dir

'''
A collection of functions to read course data.

No function in this class actually performs logic on data, just returns it.
his helps keep the program modular, by separating the data sources from
the data indexing.
'''

def get_course_names():
  with open(dir.courses) as file:
    return {
      row["Course ID"]:row["Course Name"]
      for row in csv.DictReader(file) 
      if row["School ID"] == "Upper"}
  
def getSectionFacultyIds():
  with open(dir.section) as file: 
    return {
      row["SECTION_ID"]: row["FACULTY_ID"]
      for row in csv.DictReader(file)
      if row["SCHOOL_ID"] == "Upper" and row["FACULTY_ID"]}
      
def getZoomLinks():
  with open(dir.zoomLinks) as file:
    return {
      row["ID"]: row["LINK"]
      for row in csv.DictReader(file)
      if row["LINK"]
    }