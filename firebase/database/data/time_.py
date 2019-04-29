from my_stuff.misc import init

class Time: 
	@init
	def __init__(self, hour: int, minutes: int): pass

class Range: 
	@init
	def __init__(self, start: Time, end: Time): pass