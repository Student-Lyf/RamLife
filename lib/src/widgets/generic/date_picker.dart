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
	return showDatePicker(
		context: context,
		initialDate: initialDate,
		firstDate: beginningOfMonth,
		lastDate: endOfMonth,
	);
}