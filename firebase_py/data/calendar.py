from datetime import datetime

from my_stuff.misc import init

class Day: 
	"""
	Simple dataclass to store the calendar
	Does not include a .output() method because we need to chain dictionaries
	for Firebase to upload but we can't do that with individual outputs
	"""
	@init
	def __init__(self, date, letter, special): 
		self.verify()

	def verify(self): 
		assert type (self.date) is datetime
		assert self.letter is None or (type (self.letter) is str and self.letter)
		assert self.special is None or (type (self.special) is str and self.special)

	def __repr__(self): 
		special = "" if self.special is None else self.special
		if (self.letter): return f"{self.date}: {self.letter} {special}"
		else: return f"{self.date}: No School"
