import "package:ramaz/models.dart";
import "package:ramaz/data.dart";
import "package:ramaz/services.dart";
import "../model.dart";

/// A model which handles all the actions which a captain may need.
class ClubCaptains extends Model {

  @override
  Future<void> init() async{
  }

  /// Checks if a user is a captain.
  bool isCaptain(Club club) =>
      club.captains.contains(Models.instance.user.data.contactInfo);

  /// Checks if a user is a faculty advisor.
  bool? isFacultyAdvisor(Club club) =>
      club.facultyAdvisor.contains(Models.instance.user.data.contactInfo);

  /// Allows user to upload a club.
  Future<void> uploadClub(Club newClub) async {
    if((Models.instance.user.adminScopes ?? []).contains(AdminScope.clubs)){
      newClub.isApproved = true;
    }else{
      newClub.isApproved = null;
    }
    Services.instance.database.clubs.admin.create(newClub.toJson());
  }

  /// Allows admin or club captain to remove a member from a club.
  Future<void> removeMember(Club club, ContactInfo member) async {
    Models.instance.user.data.registeredClubs.remove(club.id);
    club.members.remove(member);
    Services.instance.database.clubs.memberRemove(
        club.id, member.toJson()
    );
    club.attendance.remove(Models.instance.user.data.contactInfo);
  }

  /// Allows captain to post message.
  Future<void>? postMessage(Club club, Message message) async {
    Services.instance.database.clubs.postMessage(club.id, message.toJson());
  }

  /// Allows captains to edit a club.
  Future<void> editClub(Club club) async {
    if((Models.instance.user.data.adminScopes ?? []).contains(
        AdminScope.clubs)){
      club.isApproved = true;
    }else{
      club.isApproved = null;
    }
    Services.instance.database.clubs.update(club.toJson());
  }

  /// Allows a captain to take attendance.
  Future<void> takeAttendance(
      ContactInfo member, Club club, bool attend) async{
    attend ? club.attendance[member]= (club.attendance[member]!) + 1
        :club.attendance[member] = club.attendance[member]!;
    Services.instance.database.clubs.update(club.toJson());
  }
}
