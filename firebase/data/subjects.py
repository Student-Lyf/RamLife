from my_stuff.misc import init

class Subject: 
	@init 
	def __init__(self, name: str, id: str, teacher: str): self.verify()
	def __repr__(self): return f"Class ({self.name})"
	def verify(self): 
		assert type (self.name) is str
		assert type (self.id) is str
		assert type (self.teacher) is str		

	def output(self): return {
		"name": self.name,
		"teacher": self.teacher
	}
	