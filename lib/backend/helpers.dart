import "../mock.dart" show getSubjectByID;  // belongs here but is a mock...
import "schedule.dart";

String aOrAn (String nextWord) => 
	["a", "e", "i", "o", "u"].contains (
		nextWord [0].toLowerCase()
	) 
		? "n"
		: "";
	
Subject getSubject (Period period) => period == null 
	? null 
	: getSubjectByID (period.id);