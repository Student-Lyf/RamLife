import "package:flutter/material.dart";

/// Prompts the user to pick a date from the calendar.
/// 
/// The calendar will show the days of the school year. 
Future<DateTime?> pickDate({
	required BuildContext context,
	required DateTime initialDate,
}) async {
	final now = DateTime.now();
	final beginningOfYear = DateTime(
		now.month > 6 ? now.year : now.year - 1, 9,
	);
	final endOfYear = DateTime (
		now.month > 6 ? now.year + 1 : now.year, 7,
	);
	return showDatePicker(
		context: context,
		initialDate: initialDate,
		firstDate: beginningOfYear,
		lastDate: endOfYear,
	);
}
