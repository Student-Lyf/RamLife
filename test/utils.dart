import "package:flutter_test/flutter_test.dart";
import "package:matcher/matcher.dart" show TypeMatcher;

typedef VoidCallback = void Function();

void compare<T> (T target, T result) => expect (target, result);
void compareNot<T> (T target, T result) => expect (target, isNot (result));

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

void willThrow<Error> (VoidCallback function) => expect (
	function, throwsA (TypeMatcher<Error>())
);

void compareList<E> (List<E> a, List<E> b) => expect (
	a, pairwiseCompare<E, E> (b, (E a2, E b2) => a2 == b2, "Equality")
);

void compareDeepMaps<Key, ListValue> (
	Map<Key, List<ListValue>> a, Map<Key, List<ListValue>> b
) {
	for (MapEntry<Key, List<ListValue>> entry in a.entries) {
		// compareList<
		compare<bool> (b.containsKey(entry.key), true);
		compareList<ListValue> (b[entry.key], entry.value);
	}
}