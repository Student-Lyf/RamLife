import "package:flutter_test/flutter_test.dart";
import "package:matcher/matcher.dart";

typedef VoidCallback = void Function();

void compare<T> (T target, T result) => expect (target, result);

void test_suite(Map<String, Map<String, VoidCallback>> suite) {
	for (MapEntry<String, Map<String, VoidCallback>> entry in suite.entries) {
		group (
			entry.key, 
			() {
				for (MapEntry<String, VoidCallback> entry2 in entry.value.entries) {
					test (entry2.key, entry2.value);
				}
			}
		);
	}
}

void willThrow (VoidCallback function, TypeMatcher error) => expect (
	function, throwsA (error)
);