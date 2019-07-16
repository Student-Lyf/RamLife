// import "package:flutter_test/flutter_test.dart" show WidgetTester;
import "package:flutter/material.dart";

import "package:ramaz/widgets/next_class.dart";

import "package:ramaz/data/schedule.dart";
import "package:ramaz/data/times.dart";

import "../widget.dart" as Test;

void main() => Test.test_suite (
	{"NextClass title": NextClassTester.infoTest}
);

class NextClassTester {
	static final Period period = Period (
		PeriodData (
			id: "123-45",
			room: "U507"
		), 
		time: Range.nums (8, 00, 8, 50),
		period: "7",
	);
	static const Subject subject = Subject (
		name: "Math",
		teacher: "Ms. Shine"
	);
	static final NextClass current = NextClass (period, subject);
	static final NextClass next = NextClass (period, subject);

	static Future<void> infoTest (Test.WidgetTester tester) async {
		await tester.pumpWidget (
			MaterialApp (
				home: Scaffold (
					body: Center (
						child: current
					)
				)
			)
		);

		Test.findOne (Test.findText ("Current period: Math"));
		Test.findOne(Test.findText ("Teacher: Ms. Shine"));
		Test.findNone (Test.findText ("School is over"));
	}

	static Future<void> nextCurrentTest (Test.WidgetTester tester) async {
		await tester.pumpWidget(
			MaterialApp (
				home: Center (child: next)
			)
		)
	}
}