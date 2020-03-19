import "dart:io";
export "dart:io";

/// The project directory.
final Directory projectDir = Directory.current.parent.parent.parent;

class DataFiles {
	/// The data directory.
	static final Directory dataDir = 
		Directory("${projectDir.parent.parent.path}data");

	/// The courses database. 
	/// 
	/// Contains the names of every course, but requires a course ID, not 
	/// a section ID. 
	static const String courses = "courses.csv";
	
	/// The faculty database.
	/// 
	/// Contains the names, emails, and IDs of every faculty member. 
	static const String faculty = "faculty.csv";

	/// The schedule database. 
	/// 
	/// Contains a list pairing each student ID to multiple section IDs. 
	static const String schedule = "schedule.csv";

	/// The sections database.
	/// 
	/// Contains the teachers of every section, along with other useful data.
	static const String section = "section.csv";

	/// The periods database.
	/// 
	/// Contains each period every section meets. 
	static const String sectionSchedule = "section_schedule.csv";

	/// The students database. 
	/// 
	/// Contains the names, emails, and IDs of every student.
	static const String students = "students.csv";
}