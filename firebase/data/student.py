from my_stuff.misc import init

class Period:  # convenience for entering student data
	@init
	def __init__(
		self, 
		room: str,
		id: str
	): pass

	def output(self): return {
		"room": self.room,
		"id": self.id
	}

class Student: 
	@init
	def __init__(
		self, 
		username: str,  # key
		first: str, 
		last: str,
		homeroom: str,
		homeroom_location: str,
		# mincha_rooms: {str: str},
		# password: str,
		A: ["JSON"],
		B: ["JSON"],
		C: ["JSON"],
		E: ["JSON"],
		F: ["JSON"],
		M: ["JSON"],
		R: ["JSON"],
	): self.verify()

	def __repr__(self): return f"Student({self.first} {self.last})"

	def verify(self): 
		# assert type (self.password) is str
		# assert type (self.mincha_rooms) is dict
		assert (
			self.homeroom_location is None or 
			type (self.homeroom_location) is str
		)
		assert (self.homeroom is None or type (self.homeroom) is str)
		assert type (self.username) is str
		assert type (self.first) is str
		assert type (self.last) is str
		assert type (self.A) is list
		assert type (self.B) is list
		assert type (self.C) is list
		assert type (self.E) is list
		assert type (self.F) is list
		assert type (self.R) is list
		assert type (self.M) is list
		first = self.A [0]
		assert type (first) is dict
		assert "id" in first
		assert "room" in first
		assert type (first ["id"]) is str
		assert type (first ["room"]) is str

	def output(self): return {
		"A": self.A,
		"B": self.B,
		"C": self.C,
		"E": self.E,
		"F": self.F,
		"M": self.M,
		"R": self.R,
		"first": self.first,
		"last": self.last,
		# "mincha rooms": self.mincha_rooms,
		"homeroom meeting room": self.homeroom_location,
		"homeroom": self.homeroom
	}
