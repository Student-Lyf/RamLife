import "package:ramaz/data/schedule.dart";

const Lunch lunch = Lunch(
	main: "Fish Tacos",
	soup: "Navy Bean soup",
	side1: "Roasted Broccoli",
	side2: "Sweet Potato Wedges",
	salad: "Greek Salad",
);

final Day placeholderToday = Day (
	letter: Letters.C,
	lunch: null
);

// ----------------Mocked functions----------------

// Derived from the calendar/date
Day getToday() => placeholderToday;