import "package:flutter/material.dart";

import "package:ramaz/services.dart";

import "theme_changer.dart" show ThemeChanger;

/// Returns a custom value if [value] is null, true, or false. 
T caseConverter<T>({
	required bool? value,
	required T onNull, 
	required T onTrue,
	required T onFalse,
}) => value == null ? onNull
	: value ? onTrue : onFalse;

/// The form the [BrightnessChanger] widget should take. 
enum BrightnessChangerForm {
	/// The widget should appear as a toggle button.
	button, 

	/// The widget should appear as a drop-down menu.
	dropdown
}

/// A widget to toggle the app between light mode and dark mode. 
class BrightnessChanger extends StatefulWidget {
	/// The form this widget should take. 
	final BrightnessChangerForm form;

	/// Creates a widget to toggle the app brightness. 
	const BrightnessChanger({required this.form});

	/// Creates a [BrightnessChanger] as a toggle button. 
	factory BrightnessChanger.iconButton() => 
		const BrightnessChanger(form: BrightnessChangerForm.button);

	/// Creates a [BrightnessChanger] as a drop-down menu. 
	factory BrightnessChanger.dropdown() => 
		const BrightnessChanger(form: BrightnessChangerForm.dropdown);

	@override
	BrightnessChangerState createState() => BrightnessChangerState();
}

/// The state for a [BrightnessChanger].
class BrightnessChangerState extends State<BrightnessChanger> {
	bool? _brightness;

	/// The icon for this widget. 
	Icon get icon => Icon (
		caseConverter<IconData>(
			value: _brightness,
			onNull: Icons.brightness_auto,
			onTrue: Icons.brightness_high,
			onFalse: Icons.brightness_low,
		)
	);
	
	@override
	void initState() {
		super.initState();
		_brightness = Services.instance.prefs.brightness;
	}

	@override 
	Widget build (BuildContext context) {
		switch (widget.form) {
			case BrightnessChangerForm.button: return IconButton(
				icon: icon,
				onPressed: () => buttonToggle(context),
			);
			case BrightnessChangerForm.dropdown: return ListTile(
				title: const Text ("Theme"),
				leading: icon, 
				trailing: DropdownButton<bool?>(
					onChanged: (bool? value) => setBrightness(context, value: value),
					value: _brightness, 
          // Workaround until https://github.com/flutter/flutter/pull/77666 is released
          // DropdownButton with null value don't display the menu item.
          // Using a hint works too
          hint: const Text("Auto"),
					items: const [
						DropdownMenuItem<bool?> (
							value: null,
							child: Text ("Auto")
						),
						DropdownMenuItem<bool?> (
							value: true,
							child: Text ("Light")
						),
						DropdownMenuItem<bool?> (
							value: false,
							child: Text ("Dark"),
						),
					],
				)
			);
		}
	}

	/// Toggles the brightness of the app.
	/// 
	/// When the brightness is light, it will be set to dark. 
	/// If the brightness is dark, it will be set to auto.
	/// If the brightness is auto, it will be set to light. 
	void buttonToggle(BuildContext context) => setBrightness(
		context, 
		value: caseConverter<bool?>(
			value: _brightness,
			onTrue: false,
			onFalse: null,
			onNull: true,
		),
	);

	/// Sets the brightness of the app. 
	/// 
	/// Also saves it to [Preferences]. 
	void setBrightness (BuildContext context, {required bool? value}) {
		ThemeChanger.of(context).brightness = caseConverter<Brightness> (
			value: value,
			onTrue: Brightness.light,
			onFalse: Brightness.dark,
			onNull: MediaQuery.of(context).platformBrightness,
		);
		Services.instance.prefs.brightness = value;
		setState(() => _brightness = value);
	}
}
