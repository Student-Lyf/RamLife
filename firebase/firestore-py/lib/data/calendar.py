from datetime import date
import calendar as calendar_model
from datetime import datetime

from .. import utils

SPECIAL_NAMES = {
	"rosh chodesh": "Rosh Chodesh",
	"friday r.c.": "Friday Rosh Chodesh",
	"early dismissal": "Early Dismissal",
	"modified": "Modified",
}

current_year = date.today().year
current_month = date.today().month
cal = calendar_model.Calendar(firstweekday=6)

def get_default_calendar(month): 
	result = []
	year = get_year(month)
	for date in cal.itermonthdates(year, month): 
		if date.month != month: continue
		weekday = calendar_model.day_name[date.weekday()]
		if weekday in {"Saturday", "Sunday"}: 
			result.append(None)
		else: 
			result.append(Day(date=date, name=weekday, special="Weekday"))
	return result

def get_year(month): 
	if current_month > 7:
		return current_year if month > 7 else current_year + 1
	else: 
		return current_year - 1 if month > 7 else current_year

def get_empty_calendar(month): return [None] * 31

class Day: 
	def get_list(date_line, name_line, special_line, month): return [
		Day.raw(date=date, name=name, special=special, month=month)
		for date, name, special in zip(date_line, name_line, special_line)
		if date
	]

	def verify_calendar(month, calendar): 
		_, days_in_month = calendar_model.monthrange(current_year, month)
		days = set(range(1, days_in_month + 1))
		is_valid = len(calendar) == days_in_month
		if not is_valid: utils.logger.warning(f"Calendar for {month} is invalid. Missing entries for {days}.")
		return is_valid

	def raw(date, name, special, month): 
		year = get_year(month)
		day = int(date)
		date = datetime(year, month, day)
		name = name.split() [0]
		special = special.lower()
		if special.endswith(" Schedule"): 
			special = special[:special.find(" Schedule")]
		if special.startswith("modified"):
			special = "Modified" 
		elif not special or special not in SPECIAL_NAMES: 
			special = None
		else: special = SPECIAL_NAMES[special]
		return Day(date = date, name = name, special = special)

	def __init__(self, date, name, special): 
		self.date = date
		self.name = name
		self.special = special
		assert name is not None or special is None, f"Cannot have a special without a name: {date}"

	def __str__(self): 
		if self.name is None: return f"{self.date}: No school"
		else: return f"{self.date}: {self.name} {self.special}"

	def __repr__(self): return str(self)

	def to_json(self): return {
		"name": self.name,
		"schedule": self.special
	}

