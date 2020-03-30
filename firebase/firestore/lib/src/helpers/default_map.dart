import "dart:collection";

/// A Map with default values based on its keys.
/// 
/// Instead of a normal Map with default values, these values can be customized
/// to depend on their values by passing in [builder].
// ignore: prefer_mixin
class DefaultMap<K, V> extends MapMixin<K, V> {
	final Map<K, V> _map = {};

	/// A function that creates a value based on its key.
	final V Function(K) builder;

	/// Creates a Map with default values based on its keys.
	DefaultMap(this.builder);

	@override
	V operator [] (Object key) {
		if (!_map.containsKey(key)) {
			final V value = builder(key);
			setDefault(key, value);
			return value;
		} else {
			return _map [key];
		}
	}

	@override
	void operator []= (K key, V value) {
		_map [key] = value;
	}

	@override
	void clear() => _map.clear();

	@override
	V remove(Object key) => _map.remove(key);

	@override
	Iterable<K> get keys => _map.keys;

	/// Sets the default value for a given key if not already set.
	void setDefault(K key, [V value]) {
		if (!_map.containsKey(key)) {
			_map [key] = value ?? builder(key);
		}
	}

	/// Sets the default value for a given set of keys if not already set.
	void setDefaultForAll(Iterable<K> keys) => keys.forEach(setDefault);
}