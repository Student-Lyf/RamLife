from random import choice, randrange
from my_stuff.misc import init

ALPHABET = list ("abcdefghijklmnopqrstuvwxyz")
classId = 0

def get_random_string(): return "".join (
	[choice (ALPHABET) for _ in range (randrange (1, 7))]
)

class Class: 
	@init 
	def __init__(self, name: str, id: int, teacher: str): pass
	def __repr__(self): return f"Class ({self.name})"
	def random(): 
		global classId
		classId += 1

		id_ = classId
		name = get_random_string()
		teacher = get_random_string()

		return Class (
			name = name,
			id = id_,
			teacher = teacher
		)

if __name__ == '__main__':
	print (Class.random())