import "package:flutter/material.dart";

import "package:ramaz/data/note.dart";
import "package:ramaz/data/schedule.dart";

import "package:ramaz/models/notes.dart" show NotesBuilderModel;
import "package:ramaz/services/reader.dart";
import "package:ramaz/widgets/change_notifier_listener.dart";

///Must be stateful to keep [TextEditingController.text] intact
class NotesBuilder extends StatefulWidget {	
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

	final Note note;
	final Reader reader;

	NotesBuilder({
		@required this.reader,
		this.note
	}); 

	@override 
	NotesBuilderState createState() => NotesBuilderState();
}

/// Exists solely to instantiate a TextEditingController
class NotesBuilderState extends State<NotesBuilder> {
	final TextEditingController controller = TextEditingController();

	@override
	Widget build(BuildContext context) => ChangeNotifierListener(
		setup: () => controller.text = widget.note?.message,
		child: FlatButton(
			child: Text (
				"Cancel", 
				style: TextStyle (
					color: NotesBuilder.getButtonTextColor(
						context, 
						Theme.of(context).brightness,
						true
					),
				)
			),
			onPressed: Navigator.of(context).pop,
		),
		model: () => NotesBuilderModel(reader: widget.reader, note: widget.note),
		builder: (BuildContext context, NotesBuilderModel model, Widget back) =>
			AlertDialog(
				title: Text (widget.note == null ? "Create note" : "Edit note"),
				actions: [
					back,
					RaisedButton(
						child: Text (
							"Save", 
							style: TextStyle (
								color: NotesBuilder.getButtonTextColor(
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
							SwitchListTile (
								value: model.shouldRepeat,
								onChanged: model.toggleRepeat,
								title: Text ("Repeat"),
								secondary: Icon (Icons.repeat),
							),
							if (model.shouldRepeat) ...[
								Wrap(
									children: [
										RadioListTile<RepeatableType> (
											value: RepeatableType.period,
											groupValue: model.type,
											onChanged: model.toggleRepeatType,
											title: Text ("Repeat every period"),
										),
										RadioListTile<RepeatableType> (
											value: RepeatableType.subject,
											groupValue: model.type,
											onChanged: model.toggleRepeatType,
											title: Text ("Repeat every class"),
										),
									]
								),
								SizedBox (height: 20),
								if (model.type == RepeatableType.period) ...[
									ListTile (
										title: Text ("Letter day"),
										trailing: DropdownButton<Letters>(
											items: Letters.values.map(
												(Letters letter) => DropdownMenuItem<Letters>(
													value: letter,
													child: Text (lettersToString [letter])
												)
											).toList(),
											onChanged: model.changeLetter,
											value: model.letter,
											hint: Text ("Letter"),
										),
									),
									ListTile (
										title: Text ("Period"),
										trailing: DropdownButton<String> (
											items: model.periods?.map(
												(String period) => DropdownMenuItem<String>(
													value: period,
													child: Text (period),
												)
											)?.toList() ?? const [],
											onChanged: model.changePeriod,
											value: model.period,
											hint: Text ("Period"),
										)
									)
								] else if (model.type == RepeatableType.subject) ...[
									ListTile (
										title: Text ("Class"),
										trailing: DropdownButton<String>(
											items: model.courses.map(
												(String course) => DropdownMenuItem<String>(
													value: course,
													child: Text ("${NotesBuilder.trimString(course, 14)}..."),
												)
											).toList(),
											onChanged: model.changeCourse,
											value: model.name,
											isDense: true,
											hint: Text ("Class"),
										)
									)
								]
							],
						]
					)
				)
			)
	);
}