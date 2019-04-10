from my_stuff.lists import ALPHABET

from random import choice, randrange 

classId = 0
studentId = 0
WEEKDAYS = ("A", "B", "C", "M", "R")
FRIDAYS = ("E", "F")
ROOMS = []
for hundred in range (300, 800, 100): 
	for room in range (hundred, hundred + 8): 
		ROOMS.append (room)
# ROOMS = tuple (range (300, 308)) + tuple (range (400, 408))


def get_random_string(): return "".join (
	[choice (ALPHABET) for _ in range (randrange (1, 7))]
)

def get_class():
	global classId
	classId += 1

	id_ = classId
	name = get_random_string()
	teacher = get_random_string()

	return {
		"name": name, 
		"id": id_, 
		"teacher": teacher
	}

def get_student(): 
	global studentId
	studentId += 1

	id_ = studentId
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

	return {
		"first": first,
		"last": last,
		"id": id_,
		**days
	}

for _ in range (11): get_class()
print (get_student())