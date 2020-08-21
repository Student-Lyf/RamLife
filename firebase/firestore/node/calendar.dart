import "package:firestore/data.dart";
import "package:firestore/helpers.dart";
import "package:firestore/services.dart";

bool isDateLine(int index) => (index - 2) % 7 == 0;
bool isLetterLine(int index) => (index - 4) % 7 == 0;
bool isSpecialLine(int index) => (index - 5) % 7 == 0;

Future<List<Day>> getCalendar(int month) async {
	final List<List<String>> lines = await csvReadLines(
		DataFiles.getMonth(month)
	).toList();

	List<String> dateLine, letterLine, specialLine;
	final List<Day> daysOfMonth = [];
	for (int index = 0; index < lines.length; index++) {
		if (isDateLine(index)) {
			dateLine = lines [index];
		} else if (isLetterLine(index)) {
			letterLine = lines [index];
		} else if (isSpecialLine(index)) {
			specialLine = lines [index];
			daysOfMonth.addAll(
			 	Day.getList(
					dateLine: dateLine,
					letterLine: letterLine,
					specialLine: specialLine,
					month: month,
				)
			);
		}
	}
	return daysOfMonth;
}

const Set<int> summerMonths = {7, 8};

Future<void> main() async {
	Args.initLogger("Processing calendar...");
	for (int month = 1; month <= 12; month++) {
		if (summerMonths.contains(month)) {
			Logger.verbose("Setting summer month $month.");
			if (Args.upload) {
				await Firestore.uploadMonth(month, Day.getEmptyCalendar(month));
			}
			continue;
		}
		final List<Day> monthCalendar = await Logger.logValue(
			"calendar for $month", () => getCalendar(month)
		);
		final verified = Day.verifyCalendar(month, monthCalendar);
		assert(
			verified,
			"Could not properly parse calendar for $month"
		);
		if (Args.upload) {
			await Firestore.uploadMonth(month, monthCalendar);
		}
	}
	if (!Args.upload) {
		Logger.warning("Did not upload the calendar. Use the --upload flag.");
	}
	await app.delete();
	Logger.info("Calendar processed");
}
