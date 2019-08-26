import "package:flutter/material.dart";

import "theme_changer.dart" show ThemeChanger;

import "package:ramaz/services.dart";

enum BrightnessChangerForm {button, dropdown}

class BrightnessChanger extends StatelessWidget {
	final Preferences prefs;
	final BrightnessChangerForm form;
	final Icon icon;

	BrightnessChanger({@required this.prefs, @required this.form}) : 
		icon = Icon (
			caseConverter<IconData>(
				value: prefs.brightness,
				onNull: Icons.brightness_auto,
				onTrue: Icons.brightness_high,
				onFalse: Icons.brightness_low,
			)
		),
		assert (prefs != null),
		assert (form != null);

	factory BrightnessChanger.iconButton({@required Preferences prefs}) => 
		BrightnessChanger (prefs: prefs, form: BrightnessChangerForm.button);

	factory BrightnessChanger.dropdown({@required Preferences prefs}) => 
		BrightnessChanger (prefs: prefs, form: BrightnessChangerForm.dropdown);

	static T caseConverter<T>({
		@required bool value,
		@required T onNull, 
		@required T onTrue,
		@required T onFalse,
	}) => value == null ? onNull
		: value ? onTrue : onFalse;

	@override Widget build (BuildContext context) {
		switch (form) {
			case BrightnessChangerForm.button: return IconButton (
				icon: icon,
				onPressed: () => buttonToggle(context),
			);

			case BrightnessChangerForm.dropdown: return ListTile (
				title: Text ("Change theme"),
				leading: icon, 
				trailing: DropdownButton<bool>(
					onChanged: (bool value) => setBrightness(context, value),
					value: prefs.brightness, 
					items: [
						DropdownMenuItem<bool> (
							value: null,
							child: Text ("Automatic")
						),
						DropdownMenuItem<bool> (
							value: true,
							child: Text ("Light theme")
						),
						DropdownMenuItem<bool> (
							value: false,
							child: Text ("Dark theme"),
						),
					],
				)
			);

			default: return null;  // somehow got null
		}
	}

	void buttonToggle(BuildContext context) => setBrightness(
		context, 
		caseConverter<bool>(
			value: prefs.brightness,
			onTrue: false,
			onFalse: null,
			onNull: true,
		),
	);

	void setBrightness (BuildContext context, bool value) {
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
