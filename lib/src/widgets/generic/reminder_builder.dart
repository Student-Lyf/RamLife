import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

// Must be stateful to keep [TextEditingController.text] intact
class ReminderBuilder extends StatefulWidget {	
	static void noop(){}
	static final Color disabledColor = RaisedButton(onPressed: noop)
		.disabledTextColor;

	static String trimString (String text, int length) => text.length > length
		? text.substring(0, length) : text;

	static Color getButtonTextColor(
		BuildContext context, 
		Brightness brightness,
		bool enabled,
	) {
		if (!enabled) return disabledColor;
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

	static Future<Reminder> buildReminder(
		BuildContext context, [Reminder reminder]
	) async => await showDialog<Reminder>(
		context: context, 
		builder: (_) => ReminderBuilder(reminder: reminder),
	);

	final Reminder reminder;

	const ReminderBuilder({
		this.reminder
	}); 

	@override 
	ReminderBuilderState createState() => ReminderBuilderState();
}

// Exists solely to instantiate a TextEditingController
class ReminderBuilderState extends State<ReminderBuilder> {
	final TextEditingController controller = TextEditingController();

	@override initState() {
		super.initState();
		controller.text = widget.reminder?.message;
	}

	@override
	Widget build(BuildContext context) => ModelListener<RemindersBuilderModel>(
		child: FlatButton(
			child: Text (
				"Cancel", 
				style: TextStyle (
					color: ReminderBuilder.getButtonTextColor(
						context, 
						Theme.of(context).brightness,
						true
					),
				)
			),
			onPressed: Navigator.of(context).pop,
		),
		model: () => RemindersBuilderModel(
			services: Services.of(context).services, 
			reminder: widget.reminder
		),
		builder: (BuildContext context, RemindersBuilderModel model, Widget back) =>
			AlertDialog(
				title: Text (widget.reminder == null ? "Create reminder" : "Edit reminder"),
				actions: [
					back,
					RaisedButton(
						child: Text (
							"Save", 
							style: TextStyle (
								color: ReminderBuilder.getButtonTextColor(
									context, 
									ThemeData.estimateBrightnessForColor(
										Theme.of(context).buttonColor
									),
									model.ready,
								),
							)
						),
						color: Theme.of(context).buttonColor,
						onPressed: model.ready 
							? () => Navigator.of(context).pop(model.build())
							: null
					)
				],
				content: SingleChildScrollView(
					child: Column (
						mainAxisSize: MainAxisSize.min,
						children: [
							TextField (
								controller: controller,
								onChanged: model.onMessageChanged,
								textCapitalization: TextCapitalization.sentences,
							),
							SizedBox (height: 20),
							Wrap(
								children: [
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
								]
							),
							SizedBox (height: 20),
							if (model.type == ReminderTimeType.period) ...[
								ListTile (
									title: Text ("Letter day"),
									trailing: DropdownButton<Letters>(
										items: [
											for (final Letters letter in Letters.values)
												DropdownMenuItem(
													value: letter,
													child: Text (lettersToString [letter]),
												),
										],
										onChanged: model.changeLetter,
										value: model.letter,
										hint: Text ("Letter"),
									),
								),
								ListTile (
									title: Text ("Period"),
									trailing: DropdownButton<String> (
										items: [
											for (final String period in model.periods ?? [])
												DropdownMenuItem(
													child: Text (period),
													value: period,
												)
										],
										onChanged: model.changePeriod,
										value: model.period,
										hint: Text ("Period"),
									)
								)
							] else if (model.type == ReminderTimeType.subject)
								ListTile (
									title: Text ("Class"),
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
										hint: Text ("Class"),
									)
								),
							SwitchListTile (
								value: model.shouldRepeat,
								onChanged: model.toggleRepeat,
								title: Text ("Repeat"),
								secondary: Icon (Icons.repeat),
							),
						]
					)
				)
			)
	);
}