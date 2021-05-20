import "package:ramaz/data.dart";
import "package:ramaz/models.dart";

/// Searches the user's classes and finds on what days and period it meets.
class ScheduleSearchModel {
	/// A list of all the courses this user is enrolled in. 
	late List<Subject> subjects;

	/// The user's schedule.
	late Map<String, List<PeriodData?>> schedule;

	/// Gathers data for searching the user's schedule.
	ScheduleSearchModel() {
		final ScheduleModel model = Models.instance.schedule;
		subjects = model.subjects.values.toList();
		schedule = model.user.schedule;
	}

	/// Finds all courses that match the given query.
	/// 
	/// The query parameter should be a part of a course's name, id, or teacher
	/// and classes will be matched by searching against
	/// [Subject.name], [Subject.id], or [Subject.teacher].
	///
	/// [query] should be in lower-case to allow broader matching.
	List<Subject> getMatchingClasses(String query) => [
		for (final Subject subject in subjects)
			if (subject.name.toLowerCase().contains(query.toLowerCase())||
					subject.id.toLowerCase().contains(query.toLowerCase())||
					subject.teacher.toLowerCase().contains(query.toLowerCase()))
				subject
	];

	/// Finds the periods when a given course meets. 
	List<PeriodData> getPeriods(Subject subject) => [
		for (final List<PeriodData?> day in schedule.values)
			for (final PeriodData? period in day)
				if (period != null && period.id == subject.id)
					period
	];
}
