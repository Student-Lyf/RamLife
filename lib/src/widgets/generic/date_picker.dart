import "package:flutter/material.dart";

Future<DateTime> pickDate({
	@required BuildContext context,
	@required DateTime initialDate
}) async {
	final DateTime now = DateTime.now();
	final DateTime beginningOfYear = DateTime(
		now.month > 6 ? now.year : now.year - 1, 1, 1
	);
	final DateTime endOfYear = DateTime (
		now.month > 6 ? now.year + 1 : now.year, 12, 1
	);
	return showDatePicker(
		context: context,
		initialDate: initialDate,
		firstDate: beginningOfYear,
		lastDate: endOfYear,
	);
}