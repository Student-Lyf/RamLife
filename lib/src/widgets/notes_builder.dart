import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

// Must be stateful to keep [TextEditingController.text] intact
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

	static Future<Note> buildNote(
		BuildContext context, [Note note]
	) async => await showDialog<Note>(
		context: context, 
		builder: (_) => NotesBuilder(note: note),
	);

	final Note note;

	const NotesBuilder({
		this.note
	}); 

	@override 
	NotesBuilderState createState() => NotesBuilderState();
}

// Exists solely to instantiate a TextEditingController
class NotesBuilderState extends State<NotesBuilder> {
	final TextEditingController controller = TextEditingController();

	@override initState() {
		super.initState();
		controller.text = widget.note?.message;
	}

	@override
	Widget build(BuildContext context) => ModelListener<NotesBuilderModel>(
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
		model: () => NotesBuilderModel(
			services: Services.of(context).services, 
			note: widget.note
		),
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
							SizedBox (height: 20),
							Wrap(
								children: [
									RadioListTile<NoteTimeType> (
										value: NoteTimeType.period,
										groupValue: model.type,
										onChanged: model.toggleRepeatType,
										title: Text (
											"${model.shouldRepeat ? 'Repeats every' : 'On'} period"
										),
									),
									RadioListTile<NoteTimeType> (
										value: NoteTimeType.subject,
										groupValue: model.type,
										onChanged: model.toggleRepeatType,
										title: Text (
											"${model.shouldRepeat ? 'Repeats every' : 'On'} subject"
										),
									),
								]
							),
							SizedBox (height: 20),
							if (model.type == NoteTimeType.period) ...[
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
							] else if (model.type == NoteTimeType.subject) ...[
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
										value: model.course,
										isDense: true,
										hint: Text ("Class"),
									)
								)
							],
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