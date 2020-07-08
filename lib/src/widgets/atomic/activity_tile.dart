import "package:flutter/material.dart";

import "package:ramaz/data.dart";

/// A widget that represents an [Activity]. 
/// 
/// If the activity needs to show more details (ie, [Activity.type] is in 
/// [detailedActivities]), tapping on the tile will open a pop-up with 
/// more details. 
class ActivityTile extends StatelessWidget {
	/// Types of activities that will show more details when tapped. 
	static const Set<ActivityType> detailedActivities = {
		ActivityType.grade,
		ActivityType.misc,
	};

	/// The activity being represented by this tile.
	final Activity activity;
	
	/// Creates an ActivityTile widget. 
	const ActivityTile(
		this.activity,
	);

	@override
	Widget build(BuildContext context) => SizedBox(
		height: 65,
		child: Center(
			child: ListTile(
				title: Text(
					activity.type == ActivityType.grade 
						? "Activity by grade"
						: "Activity"
				),
				subtitle: Text(
					detailedActivities.contains(activity.type)
						? "Tap to see details"
						: activity.toString(),
				),
				onTap: activity.message == null ? null : () => showDialog(
					context: context,
					builder: (_) => AlertDialog(
						title: const Text("Activity"),
						content: SingleChildScrollView(
							child: Text(activity.message),
						)
					)
				)
			)
		)
	);
}
