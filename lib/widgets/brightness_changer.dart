import "package:flutter/material.dart";

import "package:ramaz/services/preferences.dart";
import "package:ramaz/widgets/theme_changer.dart" show ThemeChanger;

enum BrightnessChangerForm {button, dropdown}

class BrightnessChanger extends StatelessWidget {
	final Preferences prefs;
	final BrightnessChangerForm form;
	final ValueNotifier<bool> brightnessNotifier;

	BrightnessChanger({@required this.prefs, @required this.form}) : 
		brightnessNotifier = ValueNotifier<bool>(prefs.brightness),
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

	@override Widget build (BuildContext context) => ValueListenableBuilder(
		valueListenable: brightnessNotifier,
		builder: (BuildContext context, bool brightness, Widget child) {
			final Icon icon = Icon (
				caseConverter<IconData>(
					value: brightness,
					onNull: Icons.brightness_auto,
					onTrue: Icons.brightness_high,
					onFalse: Icons.brightness_low,
				)
			);
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
						value: brightness, 
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
	);

	void buttonToggle(BuildContext context) => setBrightness(
		context, 
		caseConverter<bool>(
			value: brightnessNotifier.value,
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
		brightnessNotifier.value = value;  // trigger rebuild
	}
}
