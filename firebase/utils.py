from csv import DictReader
from pathlib import Path

from my_stuff.misc import init

cd: Path = Path().cwd().parent / "data"

class CSVReader: 
	"""
	This is a convenience class that wraps csv files in an iterator
	To use it, use the following code: 

	for entry in CSVReader (filename): 
		pass  # parse entry here as normal

	Now, the file will close while still providing iterator access
	"""
	@init
	def __init__(self, filename): 
		self.file = None
		self.reader = None

	def __iter__(self): 
		self.file = open (cd / (self.filename + ".csv"))
		self.reader = DictReader(self.file)
		return self

	def __next__(self): 
		try: return next (self.reader)
		except StopIteration: 
			self.file.close()
			raise StopIteration from None

class DefaultDict (dict):
	"""
	The standard defaultdict is not enough in our case. 
	We have to initialize the schedule to a list of periods in the day,
	so we need to be able to access the	key in the factory (as an argument)
	Usage: same as defaultdict except this time you can access the key as an arg
	"""
	@init
	def __init__(self, factory): super().__init__(self)
	def __missing__(self, key): 
		"""
		Provides the missing value using self.factory
		For some reason this is different than __setitem__. 
		"""
		return self.factory (key)
	def __getitem__(self, key): 
		"""
		By setting a value if it doesn't already exist, we can simplify code 
		that depends on keys existing by reading and writing at the same time 
		"""
		if key not in self:  # set it's default value and return
			value = self.factory (key)
			self [key] = value
			return value
		else: return super().__getitem__(key)
