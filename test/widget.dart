import "package:flutter/material.dart" show Widget;

import "package:flutter_test/flutter_test.dart";
export "package:flutter_test/flutter_test.dart" show WidgetTester;

// typedef Widget = void Function();

void test_suite(Map<String, WidgetTesterCallback> suite) {
	for (MapEntry<String, WidgetTesterCallback> entry in suite.entries) {
		testWidgets (entry.key, entry.value);
	}
}

Finder findText (String text) => find.text (text);
Finder findWidget (Widget widget) => find.byWidget(widget);
Finder findAncestor(Finder of, Finder matching) => 
	find.ancestor(of: of, matching: matching);

void findOne(Finder finder) => expect (finder, findsOneWidget);
void findNone(Finder finder) => expect (finder, findsNothing);