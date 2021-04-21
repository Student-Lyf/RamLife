import "package:ramaz/data.dart";
import "package:ramaz/models.dart";

class ScheduleSearchModel {
  late List<Subject> subjects;

  scheduleSearchModel() {
    final ScheduleModel model = Models.instance.schedule;
    subjects = model.subjects.values.toList();
  }

  List<Subject> getMatchingClasses(String query) =>
      [
        for(final Subject subject in subjects)
          if(subject.name.contains(query))
            subject
      ];
  List<String> getPeriods(Subject subject){
    final List<String> result = [];
    Map<String,List<PeriodData?>> schedule = Models.instance.schedule.user.schedule;
    for(final MapEntry<String,List<PeriodData?>> entry in schedule.entries){
      final String dayName = entry.key;
      final List<PeriodData?> daySchedule = entry.value;
      for(int index=0;index<daySchedule.length;index++){
        final PeriodData? period = daySchedule[index];
        if(period!=null && period.id == subject.id){
          result.add("$dayName-$index");
        }
      }
    }
    return result;
  }
}
