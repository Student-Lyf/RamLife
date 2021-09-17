from data.serializable import Serializable
from serializable import Serializable

# Tracks if a section meets in a semester.
class Semesters():
  def __init__(self, semester1, semester2,sectionId):
    # Whether this section meets in the first semester.
    self.semester1 = semester1
    # Whether this section meets in the second semester.
    self.semester2 = semester2

    self.sectionId = sectionId

    assert semester1 and semester2, f"Could not read semester data for{sectionId}"

  def __str__(self):
    return f"Semesters({self.semester1}, {self.semester2}"
  
# A class section
#
# Classes are split into courses which hold descriptive data about
# the course itself. Courses are split into one or more sections, which
# hold data specific to that section, such as the teacher or roster list.
class Section():
  def __init__(self,name,id,teacher,zoomlink=""):
    # The name of this section.
    self.name = name

    # The section ID for this class.
    self.id = id

    # The full name of the teacher for this section.
    self.teacher = teacher

    self.zoomLink = zoomlink

    assert name and id and teacher, f"Could not read section data for {id}" 

  def __str__(self):
    return f"{self.name} ({self.id})"

  '''
  I dont understand serializable.dart
  I dont get what 'Map<String, String> get json' does
  '''

# A period in the day
class Period():
  def __init__(self, room, id, day, period):
  # Maps a [Day.name] to the number of periods in that day.
  #
  # Not all periods will be shown in the app. 'Special.periods.length' will
  # dictate that, and 'Special.periods.skips' dictates which periods will be
  # skipped
    self.periodsInDay = {
      "Monday": 11,
      "Tuesday": 11,
      "Wednesday": 11,
      "Thursday": 11,
      "Friday": 11 
      }

    # The room the period is located in.
    self.room = room

    # The section ID for this period.
    self.id = id

    # The day this period takes place.
    self.day = day

    # The period number.
    self.period = period

    assert day and period, f"Could not read period data for {id}"

    # Should be the same as (id == null) == (room==null) but wouldnt
    # the error be raised if ID is null and room isn't (and vice versa)
    # not if both ID and room are null?
    assert (not id) == (not room), f"If ID is null, room must be (and vice versa) {day}, {period}, {id}"

  def __str__(self):
    return f"{self.day}_{self.period}({id})"

  '''
  I dont understand serializable.dart
  I dont get what 'Map<String, String> get json' does
  '''