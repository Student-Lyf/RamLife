import "package:flutter/material.dart";

class BrightnessChanger extends StatefulWidget {
	final Widget Function(BuildContext context, ThemeData theme) builder;
	// final void Function (ThemeData) onChanged;
	final ThemeData light, dark;
	final Map<String, ThemeData> themes;
	BrightnessChanger({
		@required this.builder, 
		this.light,
		this.dark,
		this.themes
	});

	@override BrightnessChangerState createState() => BrightnessChangerState();

	static BrightnessChangerState of (BuildContext context) => 
		context.ancestorStateOfType(TypeMatcher<BrightnessChangerState>());
}

class BrightnessChangerState extends State<BrightnessChanger> {
	ThemeData _theme;

	// @override void initState() {
	// 	super.initState();
	// 	if (widget.light != null && widget.dark != null) 
	// 			brightness = MediaQuery.of(context).platformBrightness;
	// }

	set brightness (Brightness brightness) => 
		setState(() => _theme = brightness == Brightness.light
		 ? widget.light
		 : widget.dark
		);

	void toggleBrightness() => setState(
		() {
			if (_theme == widget.light) _theme = widget.dark;
			else _theme = widget.light;
		}
	);

	set theme (ThemeData data) => setState(() => _theme = data);
	ThemeData get theme => _theme;

	set themeName (String key) {
		if (widget.themes == null) return;
		setState(() => _theme = widget.themes[key]);
	}

	@override Widget build(BuildContext context) => 
		widget.builder(context, _theme);
}
