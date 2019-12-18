import "package:flutter/material.dart";

import "package:ramaz/data.dart";

class ActivityTile extends StatelessWidget {
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
				title: const Text("Activity"),
				subtitle: Text(
					activity.byGrade
						? "Tap to see details"
						: activity.toString(),
				),
				onTap: activity.message == null ? null : () => showDialog(
					context: context,
					builder: (_) => AlertDialog(
						title: const Text("Activity"),
						content: Text(activity.message ),
					)
				)
			)
		)
	);
}
