import "dart:io";
export "dart:io";

final Directory projectDir = Directory.current.parent.parent.parent;

class DataFiles {
	static final Directory dataDir = 
		Directory("${projectDir.parent.parent.path}data");

	static const String courses = "courses.csv";
	static const String faculty = "faculty.csv";
	static const String schedule = "schedule.csv";
	static const String section = "section.csv";
	static const String sectionSchedule = "section_schedule.csv";
	static const String students = "students.csv";
}