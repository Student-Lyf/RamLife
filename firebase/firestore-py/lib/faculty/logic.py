from collections import defaultdict
from typing import DefaultDict
from .. import utils
from .. import data

'''
A collection of functions o index faculty data.

No function in this class reads data from the data files, just works logic
on them. This helps keep the program modular, by separating the data sources
from the data indexing
'''

'''
Maps faculty to the sections they teach.

This function works by taking several arguments: 

- faculty, from [FacultyReader.get_faculty] 
- sectionTeachers, from [SectionReader.get_section_faculty_ids]

These are kept as parameters instead of calling the functions by itself
in order to keep the data and logic layers separate. 
'''

def get_faculty_sections(faculty,section_teachers):
  result = defaultdict(set)
  missing_emails = set()
  for section_id, faculty_id in section_teachers.items():
    # Teaches a class but doesn't have basic faculty data
    if faculty_id not in faculty:
      missing_emails.add(faculty_id)
      continue
    result[faculty[faculty_id]].add(section_id)

  if missing_emails:
    utils.logger.warning(f"Missing emails for {missing_emails}")
  return result

'''
Returns complete [User] objects.

This function returns [User] objects with more properties than before.
See [User.addSchedule] for which properties are added.

This function works by taking several arguments:

 - faculty_sections from [get_faculty_sections]
 - section_periods from [student_reader.get_periods]

These are kept as parameters instead of calling the functions by itself
in order to keep the data and logic layers separate. 
'''

def get_faculty_with_schedule(faculty_sections, section_periods):
  # The schedule for each teacher
  schedules = {}
  
  # Sections IDs which are taught but never meet.
  missing_periods = set()

  # Faculty missing a homerooms.
  #
  # This will be logged at the debug level.
  missing_homerooms = set()
  
  # Loop over teacher sections and get their periods.
  for key, value in faculty_sections.items():
    periods = []
    for section_id in value:
      if section_id in section_periods:
        periods.extend(section_periods[section_id])
      elif section_id.startswith("UADV"):
        key.homeroom = section_id
        key.homeroom_location = "Unavailable"
      else:
        missing_periods.add(section_id)

    # Still couldn'y find any homeroom
    if key.homeroom is None:
      missing_homerooms.add(key)
      key.homeroom = "SENIOR_HOMEROOM"
      key.homeroom_location = "Unavailable"
    
    schedules[key] = periods

  # Some logging
  if not missing_periods:
    utils.logger.debug("Missing homerooms", missing_homerooms)
  
  # Compiles a list of periods into a full schedule
  result = []
  for key, value in schedules.items():
    schedule = data.DayDefaultDict()

    for period in value:

      schedule[period.day][period.period-1] = period
    
    schedule.populate(utils.constants.day_names)
    key.schedule = schedule
    result.append(key)

  
  return result
