from data.default_map import DefaultMap
import schedule
from serializable import Serializable
import default_map
import logging

'''
A user object.

At first, users need to be tracked by their IDs and personal data.
After their schedules are compiled, those need to be added to the object.
'''
class User(Serializable):
  # Warns for any users with no classes in their schedule.
  def verifySchedules(users):
    #(double check this line)
    missingSchedules = {user.hasNoClasses for user in users}

    if missingSchedules:
      # Warning since it may be a sign of data corruption.
      logging.warn(f"Missing schedules for {missingSchedules}")
  
  # Converts a list of [Period] objects to JSON
  def scheduleToJson(schedule):
    #(double check this line)
    return [period.json for period in schedule]

  def emptySchedule():
    #will come back to this later
    ...

  # dayNames is from constants.dart, will fix later
  dayNamesList = list(dayNames) 

  def __init__(self,first,last,email,id,homeroom="",homeroomlocation="",schedule={}):
    self.first = first
    self.last = last
    self.email = email
    self.name = f"{first} {last}"
    self.id = id
    self.homeroom = homeroom
    self.homeroomlocation = homeroomlocation
    self.schedule = schedule

    assert id, "Could not find ID for user"
    assert first and last and email, f"Could not find name for user: {id}"

    if schedule == None:
      return

    assert homeroom, f"Could not find homeroom for user {self}"
    assert homeroomlocation, f"Could not find homerom location ofor user: {self}"

    #See above about dayNames
    for dayname in dayNames:
      assert dayname in schedule, f"{self.name} does not have a schedule for {dayname} days"

  '''
  what does this do?:

  User.empty({
  @required this.email,
  @required this.first, 
  @required this.last, 
}) : 
  homeroom = "SENIOR_HOMEROOM",
  homeroomLocation = "Unavailable",
  id = null,
  schedule = emptySchedule;
  '''

  # Check if this user has no classes.
  # If all of the periods are None or empty, return True
  def hasNoClasses(self):
    if all(not period for period in self.schedule.valuse()):
      return True
    else:
      return False

  # Returns a new [User] with added [homeroom] and [homeroomLocation] data.
  def addHomeroom(self,homeroom, homeroomLocation):
    return User(
      self.first,
      self.last,
      self.email,
      self.id,
      homeroom,
      homeroomLocation)

  # Returns a new [User] with added [schedule] data.
  # To fill in the homeroom as well, call this function on the return value
  # of [addHomeroom].
  def addSchedule(self,schedule):
    return User(
      self.first,
      self.last,
      self.email,
      self.homeroom,
      self.homeroomlocation,
      schedule
    )
  
  #Will have to come back to this one:
  def get_json(dayNames):
    for dayName in dayNames:
      #How to do dayName: 'scheduleToJson(schedule [dayName])...' ?
      ...
      
