from my_stuff.misc import init

class Day: 
	@init
	def __init__(self, date, letter): pass
	def __repr__(self): 
		if (self.letter): return f"{self.date}: {self.letter}"
		else: return f"{self.date}: No School"
	def output(self): 
		letter = self.letter
		if not letter: letter = None
		return {
			str (self.date.day): {
				"letter": letter
			}
		}
