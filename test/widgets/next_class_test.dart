// import "package:flutter_test/flutter_test.dart" show WidgetTester;
import "package:flutter/material.dart";

import "package:ramaz/src/widgets/atomic/next_class.dart";

import "package:ramaz/data.dart";

import "../widget.dart" as test;

// void main() {}

void main() => test.testSuite (
	{"NextClass title": NextClassTester.infoTest}
);

class NextClassTester {
	static final Period period = Period (
		const PeriodData (
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
	static final NextClass current = NextClass (period: period, subject: subject);
	static final NextClass next = NextClass (period: period, subject: subject);

	static Future<void> infoTest (test.WidgetTester tester) async {
		await tester.pumpWidget (
			MaterialApp (
				home: Scaffold (
					body: Center (
						child: current
					)
				)
			)
		);

		test.findOne (test.findText ("Current period: Math"));
		test.findOne(test.findText ("Teacher: Ms. Shine"));
		test.findNone (test.findText ("School is over"));
	}

	static Future<void> nextCurrentTest (test.WidgetTester tester) async {
		await tester.pumpWidget(
			MaterialApp (
				home: Center (child: next)
			)
		);
	}
}