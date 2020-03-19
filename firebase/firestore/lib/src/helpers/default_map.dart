class DefaultDict<K, V> {
	final Map<K, V> _map = {};

	final V Function(K) builder;

	DefaultDict(this.builder);

	V operator [] (K key) {
		if (!_map.containsKey(key)) {
			final V value = builder(key);
			_map [key] = value;
			return value;
		} else {
			return _map [key];
		}
	}

	void operator []= (K key, V value) {
		_map [key] = value;
	}
}