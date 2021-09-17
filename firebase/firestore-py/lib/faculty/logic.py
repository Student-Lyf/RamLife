from .reader import getFaculty
from ..utils import logger
from logging import warning
from ..data.schedule import Period
from ..constants import getDayNames

'''
A collection of functions o index faculty data.

No function in this class reads data from the data files, just works logic
on them. This helps keep the program modular, by separating the data sources
from the data indexing
'''

'''
Maps faculty to the sections they teach.

This function works by taking several arguments: 

- faculty, from [FacultyReader.getFaculty] 
- sectionTeachers, from [SectionReader.getSectionFacultyIds]

These are kept as parameters instead of calling the functions by itself
in order to keep the data and logic layers separate. 
'''

def getFacultySections(faculty,secionTeachers):
  result = {}
  missingEmails = set()
  for key, value in secionTeachers.items():
    sectionId = key
    facultyId = value

    #Teaches a class but doesn't have basic faculty data
    if facultyId not in faculty:
      missingEmails.add(facultyId)
      continue
    result[faculty[facultyId]] = sectionId

  if missingEmails:
    warning(f"Missing emails for {missingEmails}")
  return result

'''
Returns complete [User] objects.

This function returns [User] objects with more properties than before.
See [User.addSchedule] for which properties are added.

This function works by taking several arguments:

 - facultySections from [getFacultySections]
 - sectionPeriods from [StudentReader.getPeriods]

These are kept as parameters instead of calling the functions by itself
in order to keep the data and logic layers separate. 
'''

def getFacultyWithSchedule(facultySections, sectionPeriods):
  # The schedule for each teacher
  schedules = {}

  # Faculty with homerooms to set.
  #
  # This cannot happen while looping over them since it would modify the
  # iterable being looped over, causing several errors. Instead, they are
  # saved to this map and processed later.
  replaceHomerooms = {}
  
  # Sections IDs which are taught but never meet.
  missingPeriods = set()

  # Faculty missing a homerooms.
  #
  # This will be logged at the debug level.
  missingHomerooms = set()
  
  # Loop over teacher sections and get their periods.
  for key, value in facultySections.items():
    periods = []
    for sectionId in value:
      if sectionId in sectionPeriods:
        for period in sectionPeriods[sectionId]:
          periods.append(period)
      elif sectionId.startswith("UADV"):
        # Will be overwritten in another loop
        replaceHomerooms[key] = key.addHomerooms(
          homeroom = sectionId,
          homeroomLocation = "Unavailable"
        ) 
      else:
        missingPeriods.add(sectionId)
    schedules[key] = periods
  
  # Create and save faculty homerooms
  # 
  # This cannot happen in the loop above since it would change the iterable
  # while looping over it, causing several errors. Instead, the old [User]
  # object and the new one are saved to 'repaceHomerooms'.
  for faculty in schedules.keys():
    if faculty not in replaceHomerooms:
      missingHomerooms.add(faculty)
    
    schedule = schedules.remove(faculty)
    assert schedule, f"Error adding homerooms to {faculty}"

    newFaculty = replaceHomerooms[faculty] if faculty in replaceHomerooms else faculty.addHomeroom(
                  homeroom = "SENIOR_HOMEROOM",
                  homeroomLocation = "Unavailable"
                )
    schedules[newFaculty] = schedule

  # Some logging
  if not missingPeriods:
    logger.debug("Missing homerooms", missingHomerooms)
  
  # Compiles a list of periods into a full schedule
  result = []
  for key, value in schedules.items():
    schedule = [0 for i in range(Period.periodsInDay["Monday"])]

    for period in value:
      schedule[period.day][period.period-1] = period
    
    schedule.setDefaultForAll(getDayNames())
    result.append(key.addSchedule(schedule))
  
  return result