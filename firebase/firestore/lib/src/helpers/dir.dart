import "package:node_io/node_io.dart";
export "package:node_io/node_io.dart";

/// The project directory.
final Directory projectDir = Directory.current;

/// A container class for all the database files.
class DataFiles {
	/// The data directory.
	static final Directory dataDir = 
		Directory("${projectDir.parent.parent.path}\\data");

	/// The courses database. 
	/// 
	/// Contains the names of every course, but requires a course ID, not 
	/// a section ID. 
	static final String courses = "${dataDir.path}\\courses.csv";
	
	/// The faculty database.
	/// 
	/// Contains the names, emails, and IDs of every faculty member. 
	static final String faculty = "${dataDir.path}\\faculty.csv";

	/// The schedule database. 
	/// 
	/// Contains a list pairing each student ID to multiple section IDs. 
	static final String schedule = "${dataDir.path}\\schedule.csv";

	/// The sections database.
	/// 
	/// Contains the teachers of every section, along with other useful data.
	static final String section = "${dataDir.path}\\section.csv";

	/// The periods database.
	/// 
	/// Contains each period every section meets. 
	static final String sectionSchedule = "${dataDir.path}\\section_schedule.csv";

	/// The students database. 
	/// 
	/// Contains the names, emails, and IDs of every student.
	static final String students = "${dataDir.path}\\students.csv";

	/// Returns the path for the calendar at a given month.
	/// 
	/// The month should follow 1-based indexing.
	static String getMonth(int month) => 
		"${dataDir.path}\\calendar\\${month.toString()}.csv";
}