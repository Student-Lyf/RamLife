import "package:flutter/material.dart";

class BrightnessChanger extends StatefulWidget {
	final Widget Function(BuildContext context, Brightness brightness) builder;
	BrightnessChanger({this.builder});

	@override BrightnessChangerState createState() => BrightnessChangerState();

	static BrightnessChangerState of (BuildContext context) => 
		context.ancestorStateOfType(TypeMatcher<BrightnessChangerState>());
}

class BrightnessChangerState extends State<BrightnessChanger> {
	Brightness _brightness = Brightness.light;
	set brightness (Brightness newBrightness) => 
		setState(() => _brightness = newBrightness);

	@override Widget build(BuildContext context) => 
		widget.builder(context, _brightness);
}
