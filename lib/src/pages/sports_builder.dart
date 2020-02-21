import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/widgets.dart";

const List<String> teams = [
  "Boys Varsity basketball", 
  "Girls Varsity volleyball", 
  "(other teams)"
];

class FormRow extends StatelessWidget {
  final Widget a, b;
  final bool spaced;
  const FormRow(this.a, this.b, {this.spaced = false});
  
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          a, 
          const Spacer(), 
          if (spaced) SizedBox(width: 300, child: b)
          else b
        ]
      ),
      const SizedBox(height: 20),
    ]
  );
}

class EditableField<T> extends StatelessWidget {
  final String label;
  final String value;
  final IconData whenNull;
  final void Function() setNewValue;
  
  const EditableField({
    @required this.label,
    @required this.value,
    @required this.whenNull,
    @required this.setNewValue
  });
  
  @override
  Widget build(BuildContext context) => FormRow(
    Text(label),
    value == null
      ? IconButton(
        icon: Icon(whenNull),
        onPressed: setNewValue
      )
    : InkWell(
      onTap: setNewValue,
      child: Text(
        value,
        style: TextStyle(color: Colors.blue),
      ),
    )
  );
}

class SportBuilder extends StatefulWidget {
  @override
  SportBuilderState createState() => SportBuilderState();
}

class SportBuilderState extends State<SportBuilder> {
  Sport sport;
  String team;
  bool away = false;
  DateTime date;
  TimeOfDay start, end;
  final TextEditingController opponentController = TextEditingController();
  
  Time getTime(TimeOfDay time) => time == null 
    ? null : Time(time.hour, time.minute);
  
  bool get ready => sport != null &&
    team != null &&
    away != null &&
    date != null &&
    start != null &&
    end != null &&
    opponentController.text.isNotEmpty;
  
  SportsGame get game => SportsGame(
    date: date,
    home: !away,
    times: Range(getTime(start), getTime(end)),
    team: team ?? "",
    opponent: opponentController.text,
    sport: sport,
  );
  
  Future<void> setDate() async {
    final DateTime selected = await showDatePicker(
      firstDate: DateTime(2019, 09, 01),
      lastDate: DateTime(2020, 06, 30),
      initialDate: DateTime.now(),
      context: context
    );
    setState(() => date = selected);
  }
  
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text("Add game"),
    ),
    body: Form(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          FormRow(
            const Text("Sport"),
            DropdownButtonFormField<Sport>(
              hint: const Text("Choose a sport"),
              value: sport,
              onChanged: (Sport value) => setState(() => sport = value),
              items: [
                for (final Sport sport in Sport.values) 
                  DropdownMenuItem<Sport>(
                    value: sport,
                    child: Text(sport.toString().split(".") [1])
                  )
              ],
            ),
            spaced: true,
          ),
          const SizedBox(height: 10), 
          FormRow(
            const Text("Team"),
            DropdownButtonFormField<String>(
              itemHeight: 70,
              hint: const Text("Choose a Team"),
              value: team,
              onChanged: (String value) => setState(() => team = value),
              items: [
                for (final String team in teams)
                  DropdownMenuItem<String>(value: team, child: Text(team)),

                DropdownMenuItem<String>(
                  value: "", 
                  child: SizedBox(
                    width: 150, 
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add),
                        const SizedBox(width: 10),
                        const Text("Add team"),
                      ]
                    )
                  )
                )
              ]
            ),
            spaced: true,
          ),
          FormRow(
            const Text("Opponent"),
            TextField(
              controller: opponentController,
              onChanged: (_) => setState(() {}),
            ),
            spaced: true,
          ),
          FormRow(
            const Text("Away game"),
            Checkbox(
              onChanged: (bool value) => setState(() => away = value),
              value: away,
            ),
          ),
          EditableField(
            label: "Date",
            value: date == null ? null 
              : "${date.month}-${date.day}-${date.year}",
            whenNull: Icons.date_range,
            setNewValue: setDate,
          ),
          EditableField(
            label: "Start time",
            value: start?.format(context),
            whenNull: Icons.access_time,
            setNewValue: () async {
              final TimeOfDay newTime = await showTimePicker(
                context: context,
                initialTime: start ?? TimeOfDay.now(),
              );
              setState(() => start = newTime);
            },
          ),
          EditableField(
            label: "End time",
            value: end?.format(context),
            whenNull: Icons.access_time,
            setNewValue: () async {
              final TimeOfDay newTime = await showTimePicker(
                context: context,
                initialTime: end ?? TimeOfDay.now(),
              );
              setState(() => end = newTime);
            },
          ),
          const SizedBox(height: 30),
          SportsTile(game),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              RaisedButton(
                onPressed: ready ? () => Navigator.of(context).pop(game) : null,
                child: const Text("Save"),
              )
            ]
          )
        ]
      )
    )
  );
}
