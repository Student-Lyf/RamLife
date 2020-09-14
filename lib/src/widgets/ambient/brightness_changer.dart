import "package:flutter/material.dart";

import "package:ramaz/services.dart";

import "theme_changer.dart" show ThemeChanger;

/// The form the [BrightnessChanger] widget should take. 
enum BrightnessChangerForm {
	/// The widget should appear as a toggle button.
	button, 

	/// The widget should appear as a drop-down menu.
	dropdown
}

/// A widget to toggle the app between light mode and dark mode. 
class BrightnessChanger extends StatelessWidget {
	/// Returns a custom value if [value] is null, true, or false. 
	static T caseConverter<T>({
		@required bool value,
		@required T onNull, 
		@required T onTrue,
		@required T onFalse,
	}) => value == null ? onNull
		: value ? onTrue : onFalse;

	/// The service to retrieve the user's preferences. 
	/// 
	/// This is used to save the brightness on next launch. 
	final Preferences prefs;

	/// The form this widget should take. 
	final BrightnessChangerForm form;

	/// The icon for this widget. 
	final Icon icon;

	/// Creates a widget to toggle the app brightness. 
	/// 
	/// This constructor determines the icon. 
	BrightnessChanger({@required this.prefs, @required this.form}) : 
		icon = Icon (
			caseConverter<IconData>(
				value: prefs.brightness,
				onNull: Icons.brightness_auto,
				onTrue: Icons.brightness_high,
				onFalse: Icons.brightness_low,
			)
		),
		assert (prefs != null, "Cannot load user preference"),
		assert (form != null, "Cannot build widget without selected appearance");

	/// Creates a [BrightnessChanger] as a toggle button. 
	factory BrightnessChanger.iconButton({@required Preferences prefs}) => 
		BrightnessChanger (prefs: prefs, form: BrightnessChangerForm.button);

	/// Creates a [BrightnessChanger] as a drop-down menu. 
	factory BrightnessChanger.dropdown({@required Preferences prefs}) => 
		BrightnessChanger (prefs: prefs, form: BrightnessChangerForm.dropdown);

	@override Widget build (BuildContext context) {
		switch (form) {
			case BrightnessChangerForm.button: return IconButton (
				icon: icon,
				onPressed: () => buttonToggle(context),
			);

			case BrightnessChangerForm.dropdown: return ListTile (
				title: const Text ("Theme"),
				leading: icon, 
				trailing: DropdownButton<bool>(
					onChanged: (bool value) => setBrightness(context, value: value),
					value: prefs.brightness, 
					items: const [
						DropdownMenuItem<bool> (
							value: null,
							child: Text ("Auto")
						),
						DropdownMenuItem<bool> (
							value: true,
							child: Text ("Light")
						),
						DropdownMenuItem<bool> (
							value: false,
							child: Text ("Dark"),
						),
					],
				)
			);

			default: return null;  // somehow got null
		}
	}

	/// Toggles the brightness of the app.
	/// 
	/// When the brightness is light, it will be set to dark. 
	/// If the brightness is dark, it will be set to auto.
	/// If the brightness is auto, it will be set to light. 
	void buttonToggle(BuildContext context) => setBrightness(
		context, 
		value: caseConverter<bool>(
			value: prefs.brightness,
			onTrue: false,
			onFalse: null,
			onNull: true,
		),
	);

	/// 
	void setBrightness (BuildContext context, {bool value}) {
		ThemeChanger.of(context).brightness = caseConverter<Brightness> (
			value: value,
			onTrue: Brightness.light,
			onFalse: Brightness.dark,
			onNull: MediaQuery.of(context).platformBrightness,
		);
		prefs.brightness = value;
		// brightnessNotifier.value = value;  // trigger rebuild
	}
}
