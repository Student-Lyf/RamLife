from csv import DictReader
from pathlib import Path

cd: Path = Path().cwd().parent / "data"

class CSVReader: 
	"""
	This is a convenience class that wraps csv files in an iterator
	To use it, use the following code: 

	for entry in CSVReader (filename): 
		pass  # parse entry here as normal

	Now, the file will close while still providing iterator access
	"""
	def __init__(self, filename): 
		self.filename = filename
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

