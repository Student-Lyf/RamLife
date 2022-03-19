import csv
from ..utils import dir, logger

'''
A collection of functions to read course data.

No function in this class actually performs logic on data, just returns it.
his helps keep the program modular, by separating the data sources from
the data indexing.
'''
# fixes ids of form "90070.0" to look like "90070"
# but allows ids of CADV
def fix_id(id):
  try:
    return str(int(float(id)))
  except ValueError:
    return id
    
def get_course_names():
  with open(dir.courses) as file:
    return {
      fix_id(row["Course ID"]): row["Course Name"]
      for row in csv.DictReader(file) 
      if row["School ID"] == "Upper"}
  
def get_section_faculty_ids():
  with open(dir.section) as file: 
    return {
      row["SECTION_ID"]: row["FACULTY_ID"]
      for row in csv.DictReader(file)
      if row["SCHOOL_ID"] == "Upper" and row["FACULTY_ID"]}
  

def get_zoom_links():
  Links = {}
  try:
    with open(dir.zoom_links) as file:
      for row in csv.DictReader(file):
        if row["LINK"]:
          Links[row["EMAIL"]] = row["LINK"]

  except FileNotFoundError:
    logger.warning("zoom_links.csv doesn't exist. Cannot grab data. Using an empty dictionary instead")

  try:
    with open(dir.special_zoom_links) as file:
      for row in csv.DictReader(file):
        Links[row["ID"]] = row["LINK"]

  except FileNotFoundError:
    logger.warning("No special zoom links")
  
  return Links

