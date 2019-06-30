from datetime import datetime

from my_stuff.misc import init

class Day: 
	"""
	Simple dataclass to store the calendar
	Does not include a .output() method because we need to chain dictionaries
	for Firebase to upload but we can't do that with individual outputs
	"""
	@init
	def __init__(self, date, letter): 
		if not letter: self.letter = None
		self.verify()

	def verify(self): 
		assert type (self.date) is datetime
		assert self.letter is None or (type (self.letter) is str and self.letter)

	def __repr__(self): 
		if (self.letter): return f"{self.date}: {self.letter}"
		else: return f"{self.date}: No School"
