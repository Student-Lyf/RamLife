from random import choice, randrange
from my_stuff.misc import init

ALPHABET = list ("abcdefghijklmnopqrstuvwxyz")
classId = 0

def get_random_string(): return "".join (
	[choice (ALPHABET) for _ in range (randrange (1, 7))]
)

class Class: 
	@init 
	def __init__(self, name: str, id: str, teacher: str): self.verify()
	def __repr__(self): return f"Class ({self.name})"
	def verify(self): 
		assert type (self.name) is str
		assert type (self.id) is str
		assert type (self.teacher) is str		
	def random(): 
		global classId
		classId += 1

		id_ = str (classId)
		name = get_random_string()
		teacher = get_random_string()

		return Class (
			name = name,
			id = id_,
			teacher = teacher
		)

	def output(self): return {
		"name": self.name,
		"teacher": self.teacher
	}

if __name__ == '__main__': print (Class.random())
