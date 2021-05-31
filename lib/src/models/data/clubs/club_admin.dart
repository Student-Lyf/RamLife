import "package:ramaz/models.dart";
import "package:ramaz/data.dart";
import "package:ramaz/services.dart";
import "../model.dart";

/// Handles all the actions a admin may need to do
class ClubAdmins extends Model{
  @override
  Future<void> init() {
    // TODO: implement init
    throw UnimplementedError();
  }

  /// Allows clubs admin to approve a club to be shown to all the users
  Future<void> approveClub(Club club) async{
    club.isApproved=true;
    Services.instance.database.clubs.save(club.id, club.toJson());
  }

  /// Allows a clubs admin to delete a club.
  Future<void> deleteClub(Club club) async{
    Services.instance.database.clubs.delete(club.id);
  }

  Future<void> addFacultyAdvisor(Club club, ContactInfo facultyAdvisor){
    club.facultyAdvisor.add(facultyAdvisor);
    Services.instance.database.clubs.update(club.toJson());
  }
}
