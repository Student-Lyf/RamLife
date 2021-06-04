import "package:ramaz/models.dart";
import "package:ramaz/data.dart";
import "package:ramaz/services.dart";
import "../model.dart";

/// A model which handles all the actions which a captain may need.
/// Club captains and faculty advisors have to be able to upload clubs,
/// edit the clubs, remove a memer, post a message, and change the meeting
/// time for a week.
class ClubCaptains extends Model {

  @override
  Future<void> init() async{
  }

  /// Checks if a user is a captain.
  bool isCaptain(Club club) =>
      club.captains.contains(Models.instance.user.data.contactInfo);

  /// Checks if a user is a faculty advisor.
  bool isFacultyAdvisor(Club club) =>
      club.facultyAdvisor.contains(Models.instance.user.data.contactInfo);

  /// Allows user to upload a club.
  Future<void> uploadClub(Club newClub) async {
    newClub.isApproved = (Models.instance.user.adminScopes ?? [])
      .contains(AdminScope.clubs) ? true : null;
    await Services.instance.database.clubs.admin.create(newClub.toJson());
  }

  /// Allows admin or club captain to remove a member from a club.
  Future<void> removeMember(Club club, ContactInfo member) async {
    Models.instance.user.data.registeredClubs.remove(club.id);
    club.members.remove(member);
    await Services.instance.database.clubs.memberRemove(
        club.id, member.toJson()
    );
    club.attendance.remove(Models.instance.user.data.contactInfo);
  }

  /// Allows captain to post message.
  Future<void> postMessage(Club club, Message message) async {
    await Services.instance.database.clubs.postMessage(
       club.id, message.toJson());
  }

  /// Allows captains to edit a club.
  Future<void> editClub(Club club) async {
    club.isApproved = (Models.instance.user.adminScopes ?? [])
        .contains(AdminScope.clubs) ? true : null;
    await Services.instance.database.clubs.update(club.toJson());
  }

  /// Allows a captain to take attendance.
  Future<void> takeAttendance(
      ContactInfo member, Club club, {required bool didAttend}) async{
    if (didAttend) {
      club.attendance [member] = (club.attendance[member] ?? 0) + 1;
    }
   await Services.instance.database.clubs.update(club.toJson());
  }

  /// If a captain wants to either change the time
  Future<void> editNextMeetingTime(
      Club club, DateTime date, DateTime? time) async {
    club.editedMeetingTimes[date]=time;
    await Services.instance.database.clubs.update(club.toJson());
  }

  /// A function to add another club captain
  Future<void> addCaptain(Club club, ContactInfo captain) async{
    club.captains.add(captain);
    await Services.instance.database.clubs.update(club.toJson());
  }
}
