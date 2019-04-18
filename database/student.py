from random import choice, randrange 
from itertools import count
from my_stuff.misc import init

ALPHABET = list ("abcdefghijklmnopqrstuvwxyz")
WEEKDAYS = ("A", "B", "C", "M", "R")
FRIDAYS = ("E", "F")
ROOMS = [
	room 
	for hundred in range (300, 800, 100)
	for room in range (hundred, hundred + 8)
]

classId = 11
studentId = count (1)

def get_random_string(): return "".join (
	[choice (ALPHABET) for _ in range (randrange (1, 7))]
)

class Student: 
	@init
	def __init__(
		self, 
		username: str,  # key
		first: str, 
		last: str,
		id: int, 
		A: {int: {str}},
		B: {int: {str}},
		C: {int: {str}},
		E: {int: {str}},
		F: {int: {str}},
		M: {int: {str}},
		R: {int: {str}},
	): self.verify()

	def __repr__(self): return f"Student({self.first} {self.last})"

	def get_username(first: str, last: str) -> str: 
		assert type (first) is str
		assert type (last) is str
		return last + first [0]

	def random(): 
		id_ = next (studentId)
		first = get_random_string()
		last = get_random_string()
		days = {}
		for day in WEEKDAYS: days [day] = {
			index: {
				"id": randrange (1, classId),
				"room": str (choice (ROOMS))
			}
			for index in range (1, 12)
		}

		for day in FRIDAYS: days [day] = {
			index: {
				"id": randrange (1, classId),
				"room": str (choice (ROOMS))
			}
			for index in range (1, 8)
		}

		return Student (
			username = Student.get_username(first, last),
			first = first, 
			last = last,
			id = id_,
			**days
		)

	def verify(self): 
		assert type (self.username) is str
		assert type (self.first) is str
		assert type (self.last) is str
		assert type (self.id) is int
		assert type (self.A) is dict
		assert type (self.B) is dict
		assert type (self.C) is dict
		assert type (self.E) is dict
		assert type (self.F) is dict
		assert type (self.R) is dict
		assert type (self.M) is dict
		assert 1 in self.A
		first = self.A [1]
		assert type (first) is dict
		assert "id" in first
		assert "room" in first
		assert type (first ["id"]) is int
		assert type (first ["room"]) is str

if __name__ == '__main__': print (Student.random())
