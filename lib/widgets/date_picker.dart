import "package:flutter/material.dart";

Future<DateTime> pickDate({
	@required BuildContext context,
	@required DateTime initialDate
}) async {
	final DateTime now = DateTime.now();
	final DateTime beginningOfMonth = DateTime(
		now.year, now.month, 1
	);
	final DateTime endOfMonth = DateTime (
		now.year, now.month + 1, 0
	);
	return await showDatePicker(
		context: context,
		initialDate: initialDate,
		firstDate: beginningOfMonth,
		lastDate: endOfMonth,

		// For a darker theme -- set intelligently
		// builder: (BuildContext context, Widget child) => Theme (
		// 	data: ThemeData.dark(),
		// 	child: child
		// )
	);
}