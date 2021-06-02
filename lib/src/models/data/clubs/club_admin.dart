import "package:ramaz/models.dart";
import "package:ramaz/data.dart";
import "package:ramaz/services.dart";
import "../model.dart";

/// Handles all the actions a admin may need to do
class ClubAdmins extends Model{
  @override
  Future<void> init() async{
  }

  /// Allows clubs admin to approve a club to be shown to all the users
  Future<void> approveClub(Club club) async{
    club.isApproved=true;
    await Services.instance.database.clubs.save(club.toJson());
  }

  /// Allows a clubs admin to delete a club.
  Future<void> deleteClub(Club club) async{
    await Services.instance.database.clubs.delete(club.toJson);
  }
  /// Allows Clubs admin to add add a faculty advisor to a club.
  Future<void> addFacultyAdvisor(Club club, ContactInfo facultyAdvisor) async{
    club.facultyAdvisor.add(facultyAdvisor);
    await Services.instance.database.clubs.update(club.toJson());
  }
}
