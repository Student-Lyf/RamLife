import "dataclasses.dart";
import "package:flutter/material.dart";
import "home.dart";

// ----------------Temporary values----------------

// To be replaced with asset file
// const String RAMAZ_LOGO = "https://www.ramaz.org/uploaded/04_Support_Ramaz_(PDFs,_Docs,_other_files)/Annual_Campaign/logoteal.jpg";
const int PLACEHOLDER_PERIOD = 4;
const Map <int, Subject> PLACEHOLDER_SUBJECTS = {  // ID: Subject
	1: const Subject (
		name: "Chemistry",
		teacher: "Dr. Rotenberg",
	),
	2: const Subject (
		name: "Math",
		teacher: "Ms. Shine"
	),
	3: Subject (
		name: "Talmud",
		teacher: "Rabbi Albo"
	),
	4: Subject (
		name: "Gym",
		teacher: "Coach D."
	),
	5: Subject (
		name: "History",
		teacher: "Ms. Newman"
	),
	6: Subject (
		name: "Lunch",
		teacher: "Ms. Dashiff"
	),
	7: Subject (
		name: "Spanish",
		teacher: "Mr. Kabot"
	),
	8: Subject (
		name: "English",
		teacher: "Ms. Cohen"
	),
	9: Subject (
		name: "Hebrew",
		teacher: "Ms. Sole-Zier"
	),
	10: Subject (
		name: "Tech",
		teacher: "Ms. Joshi"
	),
	11: Subject (
		name: "Chumash",
		teacher: "Ms. Benus"
	), 
	12: Subject (
		name: "Tefillah",
		teacher: "Rabbi Weiser"
	)
};

Day placeholderToday = Day (
	letter: Letters.M,
	lunch: Lunch (  // Lunch for 2/7/19
		soup: "Navy Bean soup",
		main: "Fish Tacos",
		side1: "Roasted Broccoli",
		side2: "Sweet Potato Wedges",
		salad: "Greek Salad",
		icon: Icons.fastfood
	)
);

const Schedule aSchedule = Schedule (
	letter: Letters.A,
	periods: [
		PeriodData (
			period: "1",
			room: "Beit Knesset",
			id: 12
		),
		PeriodData (
			period: "2",
			room: "503",
			id: 1			
		),
		PeriodData (
			period: "3",
			room: "304",
			id: 2
		),
		PeriodData (
			period: "4",
			room: "303",
			id: 3
		),
		PeriodData (
			period: "5",
			room: "GYM",
			id: 4
		),
		PeriodData (
			period: "6",
			room: "604",
			id: 5
		),
		PeriodData (
			period: "7",
			room: "AUD",
			id: 6
		),
		PeriodData (
			period: "8",
			room: "506",
			id: 3
		),
		PeriodData (
			period: "9",
			room: "506",
			id: 7
		),
		PeriodData (
			period: "10",
			room: "601",
			id: 8
		),
		PeriodData (
			period: "11",
			room: "304",
			id: 9
		)
	]
);

const Schedule mSchedule = Schedule (
	letter: Letters.M,
	periods: [
		PeriodData (
			period: "1",
			room: "Beit Knesset",
			id: 12
		),
		PeriodData (
			period: "2",
			room: "GYM",
			id: 4
		),
		PeriodData (
			period: "3",
			room: "506",
			id: 3
		),
		PeriodData (
			period: "4",
			room: "503",
			id: 1
		),
		PeriodData (
			period: "5",
			room: "604",
			id: 5
		),
		PeriodData (
			period: "6",
			room: "703",
			id: 10
		),
		PeriodData (
			period: "7",
			room: "AUD",
			id: 6
		),
		PeriodData (
			period: "8",
			room: "401",
			id: 8
		),
		PeriodData (
			period: "9",
			room: "301",
			id: 7
		),
		PeriodData (
			period: "10",
			room: "506",
			id: 2
		),
		PeriodData (
			period: "11",
			room: "301",
			id: 11
		)
	]
);

Student levi = Student (
	id: 770,
	schedule: {
		Letters.A: aSchedule,
		Letters.B: null, 
		Letters.C: null,
		Letters.M: mSchedule,
		Letters.R: null,
		Letters.E: null,
		Letters.F: null
	},
	homeroomDay: Letters.B,
	homeroomMeeting: "507",
	minchaRooms: {
		Letters.M: "303",
		Letters.R: "304",
		Letters.A: "503",
		Letters.B: "304",
		Letters.C: "303",
	}
);

const int SCHOOL_START = 9, SCHOOL_END = 7;
const int WINTER_FRIDAY_MONTH_START = 11;
const int WINTER_FRIDAY_MONTH_END = 3;
const int WINTER_FRIDAY_DAY_START = 1;
const int WINTER_FRIDAY_DAY_END = 1;


// ----------------Mocked functions----------------

// Derived by FB query (id -> Subject.from (Document))
Subject getSubjectByID (int id) => PLACEHOLDER_SUBJECTS [id];

// Derived from the calendar/date
Day getToday () => placeholderToday;

// Dervied by FB query (username -> Student.fromDocument)
Student getStudent (String username) => username == "leschesl"
	? levi
	: null;

// Check the Shared Preferences for user login and decide from there
Widget getMainPage() => HomePage(levi);