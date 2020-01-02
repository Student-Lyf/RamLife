import "package:flutter/material.dart";

import "package:ramaz/data.dart";

class ActivityTile extends StatelessWidget {
	static const Set<ActivityType> detailedActivities = {
		ActivityType.grade,
		ActivityType.misc,
	};

	final Activity activity;
	final double height;

	const ActivityTile(
		this.activity,
		{this.height = 65}
	);

	@override
	Widget build(BuildContext context) => SizedBox(
		height: height,
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
