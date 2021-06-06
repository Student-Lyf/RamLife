import "package:ramaz/models.dart";
import "package:ramaz/data.dart";
import "package:ramaz/services.dart";

/// A view model for club captains and faculty advisors. 
/// 
/// Captains and faculty advisors share the same permissions, including 
/// posting messages, editing metadata, changing meeting times, and more.
// TODO: implement a stream-based interface.
class ClubCaptainModel {
	/// The service for all club admins.
	final HybridClubAdmin service = Services.instance.database.clubs.admin;

	/// The club being managed. 
	final Club club;

	/// Allows a captain or advisor to manage a club.
	ClubCaptainModel(this.club);

	/// Whether this user is a captain.
	bool get isCaptain => club.captains
		.contains(Models.instance.user.data.contactInfo);

	/// Whether this user is a faculty advisor.
	bool get isFacultyAdvisor => club.facultyAdvisor
		.contains(Models.instance.user.data.contactInfo);

	/// Creates or updates a club in the database.
	Future<void> update() async {
		// If the user 1sn't a club admin, then the changes need approval.
		club.isApproved = (Models.instance.user.adminScopes ?? [])
			.contains(AdminScope.clubs) ? true : null;
		await service.upload(club.id, club.toJson());
	}

	/// Removes a member from the club.
	Future<void> removeMember(ContactInfo member) async {
		// TODO: unregister the user from the club.
		club.members.remove(member);
		club.attendance.remove(Models.instance.user.data.contactInfo);
		await service.removeMember(club.id, member.email);
		await takeAttendance();
	}

	/// Posts a message to the club's billboard.
	Future<void> postMessage(Message message) => service
		.postMessage(club.id, message.toJson());

	/// Saves the attendance records.
	Future<void> takeAttendance() => 
		service.setAttendance(club.id, club.attendance);

	/// Changes a meeting sometime in the future.
	/// 
	/// Set to null to cancel the meeting.
	Future<void> editMeeting(DateTime oldDate, DateTime? newDate) async {
		// TOOD: Add support for "special" meetings.
		club.editedMeetingTimes [oldDate] = newDate;
		await service.modifyMeeting(club.id, oldDate, newDate);
	}
}
