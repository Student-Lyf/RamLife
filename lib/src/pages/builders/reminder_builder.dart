import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

/// A widget to help the user create a [Reminder]. 
/// 
/// This widget must be a [StatefulWidget] in order to avoid recreating a 
/// [TextEditingController] every time the widget tree is rebuilt. 
class ReminderBuilder extends StatefulWidget {	
	static void _noop(){}
	static final Color _disabledColor = const RaisedButton(onPressed: _noop)
		.disabledTextColor;

	/// Trims a string down to a certain length.
	/// 
	/// This function is needed since calling [String.substring] with an `end` 
	/// argument greater than the length of the string will throw an error.
	static String trimString (String text, int length) => text.length > length
		? text.substring(0, length) : text;

	/// Gets the text color for a [MaterialButton].
	/// 
	/// Due to a bug in Flutter v1.9, [RaisedButton]s in [ButtonBar]s in 
	/// [AlertDialog]s do not respect [MaterialApp.theme.buttonTheme.textTheme]. 
	/// This function creates a new [RaisedButton] (outside of an [AlertDialog])
	/// and returns its text color. 
	static Color getButtonTextColor(
		BuildContext context, 
		Brightness brightness,
		{bool enabled}
	) {
		if (!enabled) {
			return _disabledColor;
		}
		switch (Theme.of(context).buttonTheme.textTheme) {
			case ButtonTextTheme.normal: return brightness == Brightness.dark
				? Colors.white : Colors.black87;
			case ButtonTextTheme.accent: return Theme.of(context).accentColor;
			case ButtonTextTheme.primary: return Theme.of(context).primaryColor;
			default: throw ArgumentError.notNull(
				"MaterialApp.theme.buttonTheme.textTheme"
			);
		}
	}

	/// Opens a [ReminderBuilder] pop-up to create or modify a [Reminder]. 
	static Future<Reminder> buildReminder(
		BuildContext context, [Reminder reminder]
	) => showDialog<Reminder>(
		context: context, 
		builder: (_) => ReminderBuilder(reminder: reminder),
	);

	/// A reminder to modify. 
	/// 
	/// A [ReminderBuilder] can either create a new [Reminder] from scratch or 
	/// modify an existing reminder (auto-fill its properties). 
	final Reminder reminder;

	/// Creates a widget to create or modify a [Reminder].
	const ReminderBuilder({
		this.reminder
	}); 

	@override 
	ReminderBuilderState createState() => ReminderBuilderState();
}

/// A state for a [ReminderBuilder].
/// 
/// [State.initState] is needed to instantiate a [TextEditingController]
/// exactly once. 
class ReminderBuilderState extends State<ReminderBuilder> {
	/// The text controller to hold the message of the [Reminder]. 
	final TextEditingController controller = TextEditingController();

	@override 
	void initState() {
		super.initState();
		controller.text = widget.reminder?.message;
	}

	@override
	Widget build(BuildContext context) => ModelListener<RemindersBuilderModel>(
		model: () => RemindersBuilderModel(widget.reminder),
		// ignore: sort_child_properties_last
		child: TextButton(
			onPressed: Navigator.of(context).pop,
			child: Text (
				"Cancel", 
				style: TextStyle (
					color: ReminderBuilder.getButtonTextColor(
						context, 
						Theme.of(context).brightness,
						enabled: true
					),
				)
			),
		),
		builder: (BuildContext context, RemindersBuilderModel model, Widget back) =>
			AlertDialog(
				title: Text (widget.reminder == null ? "Create reminder" : "Edit reminder"),
				actions: [
					back,
					ElevatedButton(
						onPressed: model.ready
							? () => Navigator.of(context).pop(model.build())
							: null,
						child: Text (
							"Save", 
							style: TextStyle (
								color: ReminderBuilder.getButtonTextColor(
									context, 
									ThemeData.estimateBrightnessForColor(
										Theme.of(context).buttonColor
									),
									enabled: model.ready,
								),
							)
						),
					)
				],
				content: Column (
					mainAxisSize: MainAxisSize.min,
					children: [
						TextField (
							controller: controller,
							onChanged: model.onMessageChanged,
							textCapitalization: TextCapitalization.sentences,
						),
						const SizedBox (height: 20),
						RadioListTile<ReminderTimeType> (
							value: ReminderTimeType.period,
							groupValue: model.type,
							onChanged: model.toggleRepeatType,
							title: Text (
								"${model.shouldRepeat ? 'Repeats every' : 'On'} period"
							),
						),
						RadioListTile<ReminderTimeType> (
							value: ReminderTimeType.subject,
							groupValue: model.type,
							onChanged: model.toggleRepeatType,
							title: Text (
								"${model.shouldRepeat ? 'Repeats every' : 'On'} subject"
							),
						),
						const SizedBox (height: 20),
						if (model.type == ReminderTimeType.period) ...[
							ListTile (
								title: const Text ("Day"),
								trailing: DropdownButton<String>(
									items: [
										for (final String dayName in Models.instance.schedule.user.dayNames)
											DropdownMenuItem(
												value: dayName,
												child: Text(dayName),
											),
									],
									onChanged: model.changeDay,
									value: model.dayName,
									hint: const Text("Day"),
								),
							),
							ListTile (
								title: const Text ("Period"),
								trailing: DropdownButton<String> (
									items: [
										for (final String period in model.periods ?? [])
											DropdownMenuItem(
												value: period,
												child: Text (period),
											)
									],
									onChanged: model.changePeriod,
									value: model.period,
									hint: const Text ("Period"),
								)
							)
						] else if (model.type == ReminderTimeType.subject)
							ListTile (
								title: const Text ("Class"),
								trailing: DropdownButton<String>(
									items: [
										for (final String course in model.courses)
											DropdownMenuItem(
												value: course,
												child: Text("${ReminderBuilder.trimString(course, 14)}..."),
											)
									],
									onChanged: model.changeCourse,
									value: model.course,
									isDense: true,
									hint: const Text ("Class"),
								)
							),
						SwitchListTile (
							value: model.shouldRepeat,
							onChanged: model.toggleRepeat,
							title: const Text ("Repeat"),
							secondary: const Icon (Icons.repeat),
						),
					]
				)
			)
	);
}