import "package:ramaz/models.dart";
import "package:ramaz/data.dart";
import "package:ramaz/services.dart";
import "../model.dart";

/// A model which handles all the club actions for users.
class Clubs extends Model{

  /// List of all the clubs.
  late List<Club> getAllClubs;

  ///Returns a list of all the clubs that have been created.
  @override
  Future<void> init() async {
    getAllClubs = [
      for(final Map json in await Services.instance.database.clubs.getAll()){
        Club.fromjson(json)
      }
    ];
  }

  /// Allows a user to register
  Future<void> registerForClub(Club club) async {
    Models.instance.user.data.registeredClubs.add(club.id);
    club.members.add(Models.instance.user.data.contactInfo);
    Services.instance.database.clubs.register(
        club.id, Models.instance.user.data.contactInfo.toJson()
    );
    club.attendance[(Models.instance.user.data.contactInfo)]=0;
  }

  ///Allows User to unregister from a club
  Future<void> unregisterFromClub(Club club) async {
    Models.instance.user.data.registeredClubs.remove(club.id);
    club.members.remove(Models.instance.user.data.contactInfo);
    Services.instance.database.clubs.unregister(
        club.id, Models.instance.user.data.contactInfo.toJson()
    );
    club.attendance.remove(Models.instance.user.data.contactInfo);
  }

  ///Adds the User's phone number to contactInfo.phoneNumber
  Future<void> addPhoneNumber(String number) async {
    Models.instance.user.data.contactInfo.phoneNumber=number;
  }
}