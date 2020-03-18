from my_stuff.misc import init

class Feedback: 
	@init
	def __init__(self, message, user, timestamp): pass
	def __str__(self): return f"({self.timestamp}) {self.user}: {self.message}"

	