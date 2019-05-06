import "package:ramaz/data/schedule.dart";

Day placeholderToday = Day (
	letter: Letters.C,
	lunch: Lunch (  // Lunch for 2/7/19
		soup: "Navy Bean soup",
		main: "Fish Tacos",
		side1: "Roasted Broccoli",
		side2: "Sweet Potato Wedges",
		salad: "Greek Salad",
	)
);

// ----------------Mocked functions----------------

// Derived from the calendar/date
Day getToday() => placeholderToday;