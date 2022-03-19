from .. import utils
from .schedule import Period

class DayDefaultDict(dict):
	def __missing__(self, letter):
		self[letter] = [None] * Period.PERIODS_IN_DAY[letter]
		return self[letter]
	def populate(self, keys): 
		for key in keys: 
			if key not in self: self.__missing__(key)

class User:
	def verify_schedule(users): 
		missing_schedules = {user for user in users if user.has_no_classes()}
		if (missing_schedules): 
			utils.logger.warning(f"Misisng schedules for {missing_schedules}")

	def schedule_to_json(schedule): return [
		period.to_json() if period is not None else None
		for period in schedule
	]

	def __init__(self, first, last, email, id, homeroom=None, homeroom_location=None, schedule=None):
		if not id:
			print(f"Could not find id for user: {first} {last}, {email}")
			print("Moving on")

		# assert first and last and email, f"Could not find contact info for {self}"
		self.first = first
		self.last = last
		self.name = f"{first} {last}"
		self.email = email
		self.id = id
		self.homeroom = homeroom
		self.homeroom_location = homeroom_location
		self.schedule = schedule
		if not schedule: return
		assert homeroom and homeroom_location, f"Could not find homeroom for {self}"
		for day_name in utils.constants.day_names: 
			assert day_name in schedule, f"{self} does not have a schedule for {day_name}"

	def empty(email, first, last): 
		user = User(
			first = first,
			last = last,
			email = email,
			id = "TEST",
			homeroom = "SENIOR_HOMEROOM",
			homeroom_location = "Unavailable",
			schedule = DayDefaultDict(),
		)
		user.schedule.populate(utils.constants.day_names)
		return user

	def __repr__(self):
		return f"{self.first} {self.last} ({self.id})"

	def has_no_classes(self):
		return all(
		all(period is None for period in day)
		for day in self.schedule
	)

	def to_json(self): return {
		**{
			day_name: User.schedule_to_json(self.schedule [day_name])
			for day_name in utils.constants.day_names
		},
		"advisory": None if not self.homeroom else {
			"id": self.homeroom, 
			"room": self.homeroom_location,
		},
		"email": self.email,
		"dayNames": utils.constants.day_names,
		"contactInfo": {
			"name": f"{self.first} {self.last}",
			"email": self.email
		}
	}
