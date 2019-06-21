from pathlib import Path
from csv import DictReader

from my_stuff.misc import init

cd: Path = Path().cwd()

class Student: 
	@init
	def __init__(self, first, last, email, id): pass
	def __repr__(self): return f"{self.first} {self.last} ({self.id})"


def get_csv_reader(filename: str) -> DictReader: 
	return DictReader (open (cd / (filename + ".csv")))

def get_email(first: str, last: str) -> str: return last + first [0]

def get_students() -> [Student]:
	result = []
	for entry in get_csv_reader ("students"): 
		first = entry ["First Name"]
		last = entry ["Last Name"]
		email = get_email (first, last)
		student_id = entry ["ID"]
		student = Student (
			first = first, 
			last = last,
			email = email,
			id = student_id
		)
		result.append (student)
	return result



if __name__ == '__main__':
	students = get_students()