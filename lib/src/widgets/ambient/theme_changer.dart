import "package:flutter/material.dart";

/// Builds a widget with the given theme.
typedef ThemeBuilder = Widget Function(BuildContext, ThemeData);

/// A widget to change the theme. 
/// 
/// There are three ways to change the theme: 
/// 1. By theme: set a new theme (as a [ThemeData]) with
/// `ThemeChanger.of(context).theme = newTheme`. See [ThemeChangerState.theme]
/// 
/// 2. By key: pass a map of themes to [ThemeChanger()] as `themes` and call 
/// `ThemeChanger.of(context).themeName = key`. See 
/// [ThemeChangerState.themeName].
/// 
/// 3. By brightness: pass in a light theme, dark theme, and default brightness
/// to [ThemeChanger()] and call 
/// `ThemeChanger.of(context).brightness = brightness`. See 
/// [ThemeChangerState.brightness].
class ThemeChanger extends StatefulWidget {
	/// The function that builds the widgets from the theme. 
	final ThemeBuilder builder;

	/// The default brightness to use with [light] and [dark]. 
	final Brightness defaultBrightness;

	/// The light theme. 
	/// 
	/// To switch between themes, change [ThemeChangerState.brightness] with 
	/// `ThemeChanger.of(context).brightness = newBrightness`. 
	final ThemeData light;

	/// The dark theme. 
	/// 
	/// To switch between themes, change [ThemeChangerState.brightness] with 
	/// `ThemeChanger.of(context).brightness = newBrightness`. 
	final ThemeData dark;

	/// A collection of predefined themes. 
	/// 
	/// To switch between themes, change [ThemeChangerState.themeName] with
	/// `ThemeChanger.of(context).themeName = key`. 
	final Map<String, ThemeData> themes;

	/// Creates a widget to change the theme. 
	const ThemeChanger ({
		required this.builder,
		required this.defaultBrightness,
		required this.light, 
		required this.dark,
		this.themes = const {},
	});

	@override 
	ThemeChangerState createState() => ThemeChangerState();

	/// Gets the [ThemeChangerState] from a [BuildContext]. 
	/// 
	/// Use this function to switch the theme. 
	static ThemeChangerState of(BuildContext context) {
		final state = context.findAncestorStateOfType<ThemeChangerState>();
		if (state == null) {
			throw StateError("No theme changer found in the widget tree");
		} else {
			return state;
		}
	}
}

/// The state for a [ThemeChanger]. 
/// 
/// This class has properties that control the theme. 
class ThemeChangerState extends State<ThemeChanger> {
	late ThemeData _theme;
	late Brightness _brightness;
	String? _key;

	@override 
	void initState() {
		super.initState();
		brightness = widget.defaultBrightness;
	}

	@override 
	Widget build (BuildContext context) => widget.builder (context, _theme);

	/// The current brightness. 
	/// 
	/// When changed, the theme will be changed to the appropriate theme (set by 
	/// [ThemeChanger.light] and [ThemeChanger.dark]).
	Brightness get brightness => _brightness;
	set brightness(Brightness value) {
		_key = null;
		_brightness = value;
		setState(() => _theme = value == Brightness.light 
			? widget.light : widget.dark
		);
	}

	/// The current theme. 
	/// 
	/// Changing this will rebuild the widget tree.
	ThemeData get theme => _theme;
	set theme(ThemeData data) {
		_brightness = data.brightness;
		_key = null;
		setState(() => _theme = data);
	}

	/// The name of the theme. 
	/// 
	/// This name matches the name associated with the [theme] in 
	/// [ThemeChanger.themes]. Changing this will update [theme] to the theme in 
	/// [ThemeChanger.themes] with this key. 
	/// 
	/// When [brightness] or [theme] are changed, [theme] may not exist in 
	/// [ThemeChanger.themes], in which case `themeName` will equal null. 
	String? get themeName => _key; 
	set themeName (String? key) {
		setState(() => _theme = (widget.themes) [key] ?? _theme);
		_key = key;
		_brightness = _theme.brightness;
	}
}
