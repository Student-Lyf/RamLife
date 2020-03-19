import "dart:collection";

// ignore: prefer_mixin
class DefaultDict<K, V> extends MapMixin<K, V> {
	final Map<K, V> _map = {};

	final V Function(K) builder;

	DefaultDict(this.builder);

	@override
	V operator [] (Object key) {
		if (!_map.containsKey(key)) {
			final V value = builder(key);
			_map [key] = value;
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
}