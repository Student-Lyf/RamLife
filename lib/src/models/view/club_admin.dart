import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

import "club_captains.dart";

/// A view model for club admins. 
/// 
/// Club admins are separate from Club captains and faculty advisors. Captains 
/// and advisors are placed in charge of individual clubs, while admins have 
/// higher-level privileges, like creating, approving, and deleting clubs. 
/// 
/// Also, since faculty advisors are paid for managing clubs, only club admins
/// can assign faculty advisors to clubs.
// TODO: Archived clubs.
class ClubAdmins {
	/// Approve a club to be shown to all the users.
	Future<void> approveClub(Club club) => 
		Services.instance.database.clubs.admin.approve(club.id);

	/// Deletes a club.
	Future<void> deleteClub(Club club) => 
		Services.instance.database.clubs.admin.delete(club.id);

	/// Assigns a faculty advisor to a club.
	Future<void> addFacultyAdvisor(Club club, ContactInfo facultyAdvisor) async {
		club.facultyAdvisor.add(facultyAdvisor);
		await ClubCaptainModel(club).update();
	}
}
