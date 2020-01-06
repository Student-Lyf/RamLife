import "package:flutter/material.dart";

typedef ThemeBuilder = Widget Function (BuildContext, ThemeData);

class ThemeChanger extends StatefulWidget {
	final ThemeBuilder builder;
	final Brightness defaultBrightness;
	final ThemeData light, dark;
	final Map<String, ThemeData> themes;

	const ThemeChanger ({
		@required this.builder,
		@required this.defaultBrightness,
		@required this.light, 
		@required this.dark,
		this.themes,
	});

	@override ThemeChangerState createState() => ThemeChangerState();

	static ThemeChangerState of (BuildContext context) => 
		context.findAncestorStateOfType<ThemeChangerState>();
}

class ThemeChangerState extends State<ThemeChanger> {
	ThemeData _theme;
	Brightness _brightness;
	String _key;

	@override void initState() {
		super.initState();
		brightness = widget.defaultBrightness;
	}

	set brightness(Brightness value) {
		setState(() => _theme = value == Brightness.light
			? widget.light : widget.dark
		);
		_brightness = value;
	}
	Brightness get brightness => _brightness;

	set theme(ThemeData data) => setState(() => _theme = data);
	ThemeData get theme => _theme;

	set themeName (String key) => setState(() {
		_theme = (widget.themes ?? {}) [key];
		_key = key;
	});

	String get themeName => _key; 

	@override Widget build (BuildContext context) =>
		widget.builder (context, _theme);
}
