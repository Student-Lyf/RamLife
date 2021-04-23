import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
/// Searches the user's classes and finds on what days and period it meets.
class ScheduleSearchModel {
  /// Creates empty list which the subjects will be stored in.
  late List<Subject> subjects;
  /// Creates a list of all subjects the user is enrolled in.
  ScheduleSearchModel() {
    final ScheduleModel model = Models.instance.schedule;
    subjects = model.subjects.values.toList();
  }
  ///Query is the string which the user enters.
  ///
  ///Search will return a list of classes
  ///containing the the characters the user enters.
  List<Subject> getMatchingClasses(String query) => [
    for (final Subject subject in subjects)
      if (subject.name.contains(query))
        subject
  ];
  /// Searches the user's schedule to find what day and period it meets meets.
  List < String > getPeriods(Subject subject){
    final List<String> result = [];
    final Map <String, List<PeriodData?>> schedule =
        Models.instance.schedule.user.schedule;
    for(final MapEntry < String, List<PeriodData? >> entry in schedule.entries){
      final String dayName = entry.key;
      final List<PeriodData?> daySchedule = entry.value;
      for(int index=0 ; index<daySchedule.length ; index++){
        final PeriodData? period = daySchedule[index];
        if(period!=null && period.id == subject.id){
          result.add("$dayName-$index");
        }
      }
    }
    return result;
  }
}
