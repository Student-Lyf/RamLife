/// All the letters in a rotation
enum Letter {
	/// M day
	/// 
	/// Happens on Mondays
	M, 

	/// R day
	/// 
	/// Happens on Thursdays.
	R, 

	/// A day.
	A, 

	/// B day.
	B, 

	/// C day.
	C, 

	/// E day.
	/// 
	/// Happens every other Friday, alternating with [F].
	E, 

	/// F day.
	/// 
	/// Happens every other Friday, alternating with [E].
	F
}

/// Converts Strings from the database to [Letter]s.
const Map<String, Letter> stringToLetter = {
	"M": Letter.M,
	"R": Letter.R,
	"A": Letter.A,
	"B": Letter.B,
	"C": Letter.C,
	"E": Letter.E,
	"F": Letter.F
};

/// Converts [Letter]s to Strings so they can be used as JSON.
const Map<Letter, String> letterToString = {
	Letter.M: "M",
	Letter.R: "R",
	Letter.A: "A",
	Letter.B: "B",
	Letter.C: "C",
	Letter.E: "E",
	Letter.F: "F"
};
