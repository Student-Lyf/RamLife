from .reader import getFaculty
from ..utils import logger
from logging import warning
from ..data.schedule import Period
from ..constants import get_day_names

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

def get_faculty_sections(faculty,secion_teachers):
  result = {}
  missing_emails = set()
  for key, value in secion_teachers.items():
    section_id = key
    faculty_id = value

    #Teaches a class but doesn't have basic faculty data
    if faculty_id not in faculty:
      missing_emails.add(faculty_id)
      continue
    result[faculty[faculty_id]] = section_id

  if missing_emails:
    warning(f"Missing emails for {missing_emails}")
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

  # Faculty with homerooms to set.
  #
  # This cannot happen while looping over them since it would modify the
  # iterable being looped over, causing several errors. Instead, they are
  # saved to this map and processed later.
  replace_homerooms = {}
  
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
        for period in section_periods[section_id]:
          periods.append(period)
      elif section_id.startswith("UADV"):
        # Will be overwritten in another loop
        replace_homerooms[key] = key.addHomerooms(
          homeroom = section_id,
          homeroom_location = "Unavailable"
        ) 
      else:
        missing_periods.add(section_id)
    schedules[key] = periods
  
  # Create and save faculty homerooms
  # 
  # This cannot happen in the loop above since it would change the iterable
  # while looping over it, causing several errors. Instead, the old [User]
  # object and the new one are saved to 'repaceHomerooms'.
  for faculty in schedules.keys():
    if faculty not in replace_homerooms:
      missing_homerooms.add(faculty)
    
    schedule = schedules.remove(faculty)
    assert schedule, f"Error adding homerooms to {faculty}"

    newFaculty = replace_homerooms[faculty] if faculty in replace_homerooms else faculty.addHomeroom(
                  homeroom = "SENIOR_HOMEROOM",
                  homeroom_location = "Unavailable"
                )
    schedules[newFaculty] = schedule

  # Some logging
  if not missing_periods:
    logger.debug("Missing homerooms", missing_homerooms)
  
  # Compiles a list of periods into a full schedule
  result = []
  for key, value in schedules.items():
    schedule = [0 for i in range(Period.PERIODS_IN_DAY["Monday"])]

    for period in value:
      schedule[period.day][period.period-1] = period
    
    schedule.set_default_for_all(get_day_names())
    result.append(key.add_schedule(schedule))
  
  return result