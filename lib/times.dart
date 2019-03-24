import "dataclasses.dart";
export "mock.dart";  // for WINTER_FRIDAY dates

const Special roshChodesh = Special (
	"Rosh Chodesh", 
	[
		Range (Time (8, 00), Time (9, 05)),
		Range (Time (9, 10), Time (9, 50)),
		Range (Time (9, 55), Time (10, 35)),
		Range (Time (10, 35), Time (10, 50)),
		Range (Time (10, 50), Time (11, 30)), 
		Range (Time (11, 35), Time (12, 15)),
		Range (Time (12, 20), Time (12, 55)),
		Range (Time (1, 00), Time (1, 35)),
		Range (Time (1, 40), Time (2, 15)),
		Range (Time (2, 30), Time (4, 00)),
		Range (Time (3, 00), Time (3, 20)),
		Range (Time (3, 20), Time (4, 00)),
		Range (Time (4, 05), Time (4, 45))
	],
	homeroom: 3,
	mincha: 10,
);

const Special fastDay = Special (
	"Tzom",
	[
		Range (Time (8, 00), Time (8, 55)),
		Range (Time (9, 00), Time (9, 35)),
		Range (Time (9, 40), Time (10, 15)),
		Range (Time (10, 20), Time (10, 55)), 
		Range (Time (11, 00), Time (11, 35)), 
		Range (Time (11, 40), Time (12, 15)),
		Range (Time (12, 20), Time (12, 55)), 
		Range (Time (1, 00), Time (1, 35)), 
		Range (Time (1, 35), Time (2, 05))
	],
	mincha: 8,
);

const Special friday = Special (
	"Friday",
	[
		Range (Time (8, 00), Time (8, 45)),
		Range (Time (8, 50), Time (9, 30)),
		Range (Time (9, 35), Time (10, 15)),
		Range (Time (10, 20), Time (11, 00)),
		Range (Time (11, 00), Time (11, 20)),
		Range (Time (11, 20), Time (12, 00)),
		Range (Time (12, 05), Time (12, 45)),
		Range (Time (12, 50), Time (1, 30))
	],
	homeroom: 4
);

final Special fridayRoshChodesh = Special (
	"Friday Rosh Chodesh",
	[
		Range.nums(8, 00, 9, 05),
		Range.nums(9, 10, 9, 45),
		Range.nums(9, 50, 10, 25),
		Range.nums(10, 30, 11, 05),
		Range.nums(11, 05, 11, 25),
		Range.nums(11, 25, 12, 00),
		Range.nums(12, 05, 12, 40),
		Range.nums(12, 45, 1, 20)
	],
	homeroom: 4
);

final Special winterFriday = Special (
	"Winter Friday",
	[
		Range.nums(8, 00, 9, 45),
		Range.nums(8, 50, 9, 25), 
		Range.nums(9, 30, 10, 05), 
		Range.nums(10, 10, 10, 45),
		Range.nums(10, 45, 11, 05), 
		Range.nums(11, 05, 11, 40),
		Range.nums(11, 45, 12, 20),
		Range.nums(12, 25, 1, 00)
	],
	homeroom: 4
);

final Special winterFridayRoshChodesh = Special (
	"Winter Friday Rosh Chodesh",
	[
		Range.nums(8, 00, 9, 05),
		Range.nums(9, 10, 9, 40),
		Range.nums(9, 45, 10, 15),
		Range.nums(10, 20, 10, 50), 
		Range.nums(10, 50, 11, 10),
		Range.nums(11, 10, 11, 40),
		Range.nums(11, 45, 12, 15),
		Range.nums(12, 20, 12, 50)
	],
	homeroom: 4
);

final Special amAssembly = Special (
	"AM Assembly",
	[
		Range.nums(8, 00, 8, 50),
		Range.nums(8, 55, 9, 30),
		Range.nums(9, 35, 10, 10),
		Range.nums(10, 10, 11, 10),
		Range.nums(11, 10, 11, 45), 
		Range.nums(11, 50, 12, 25),
		Range.nums(12, 30, 1, 05),
		Range.nums(1, 10, 1, 45),
		Range.nums(1, 50, 2, 25),
		Range.nums(2, 30, 3, 05),
		Range.nums(3, 05, 3, 25), 
		Range.nums(3, 25, 4, 00),
		Range.nums(4, 05, 4, 45)
	],
	homeroom: 3,
	mincha: 10
);

final Special pmAssembly = Special (
	"PM Assembly",
	[
		Range.nums(8, 00, 8, 50), 
		Range.nums(8, 55, 9, 30),
		Range.nums(9, 35, 10, 10),
		Range.nums(10, 15, 10, 50),
		Range.nums(10, 55, 11, 30),
		Range.nums(11, 35, 12, 10),
		Range.nums(12, 15, 12, 50),
		Range.nums(12, 55, 1, 30),
		Range.nums(1, 35, 2, 10), 
		Range.nums(2, 10, 3, 30),
		Range.nums(3, 30, 4, 05),
		Range.nums(4, 10, 4, 45)
	],
	mincha: 9
);

final Special regular = Special (
	"M or R day",
	[
		Range.nums(8, 00, 8, 50),
		Range.nums(8, 55, 9, 35),
		Range.nums(9, 40, 10, 20),
		Range.nums(10, 20, 10, 35),
		Range.nums(10, 35, 11, 15), 
		Range.nums(11, 20, 12, 00),
		Range.nums(12, 05, 12, 45),
		Range.nums(12, 50, 1, 30),
		Range.nums(1, 35, 2, 15), 
		Range.nums(2, 20, 3, 00),
		Range.nums(3, 00, 3, 20), 
		Range.nums(3, 20, 4, 00),
		Range.nums(4, 05, 4, 45)
	],
	homeroom: 3,
	mincha: 10
);

final Special rotate = Special (
	"A, B, or C day",
	[
		Range.nums(8, 00, 8, 45), 
		Range.nums(8, 50, 9, 30),
		Range.nums(9, 35, 10, 15),
		Range.nums(10, 15, 10, 35),
		Range.nums(10, 35, 11, 15),
		Range.nums(11, 20, 12, 00),
		Range.nums(12, 05, 12, 45),
		Range.nums(12, 50, 1, 30),
		Range.nums(1, 35, 2, 15),
		Range.nums(2, 20, 3, 00),
		Range.nums(3, 00, 3, 20),
		Range.nums(3, 20, 4, 00),
		Range.nums(4, 05, 4, 45)
	],
	homeroom: 3,
	mincha: 10
);

final Special early = Special (
	"Early Dismissal",
	[
		Range.nums(8, 00, 8, 45),
		Range.nums(8, 50, 9, 25), 
		Range.nums(9, 30, 10, 05),
		Range.nums(10, 05, 10, 20),
		Range.nums(10, 20, 10, 55),
		Range.nums(11, 00, 11, 35),
		Range.nums(11, 40, 12, 15),
		Range.nums(12, 20, 12, 55),
		Range.nums(1, 00, 1, 35), 
		Range.nums(1, 40, 2, 15),
		Range.nums(2, 15, 2, 35),
		Range.nums(2, 35, 3, 10),
		Range.nums(3, 15, 3, 50)
	],
	homeroom: 3,
	mincha: 10
);