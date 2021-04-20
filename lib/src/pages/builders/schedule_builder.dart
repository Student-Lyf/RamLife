import "package:flutter/material.dart";

import "package:ramaz/data.dart";
import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";

import "../drawer.dart";

/// Allows the user to input a small integer. 
/// 
/// Shows a number with + and - buttons nearby.
class IntegerInput extends StatelessWidget {
	/// The value being represented. 
  final int value;

  /// Callback for when the + button is pressed.
  final VoidCallback onAdd;

  /// Callback for when the - button is pressed.
  final VoidCallback onRemove;

  /// Creates a small integer input widget. 
  const IntegerInput({
    required this.value,
    required this.onAdd,
    required this.onRemove,
  });
  
  @override
  Widget build(BuildContext context) => Row(
    children: [
      const SizedBox(width: 16),
      const Text("Periods: "),
      const Spacer(),
      TextButton(
        onPressed: onRemove,
        child: const Icon(Icons.remove),
      ),
      Text(value.toString()),
      TextButton(
        onPressed: onAdd,
        child: const Icon(Icons.add),
      ),
      const SizedBox(width: 16),
    ]
  );
}

/// A page to create a [Schedule]. 
/// 
/// This uses [ScheduleBuilderModel] to create a schedule period by period. 
/// You can also pass in another schedule to quickly preset all the periods.
/// This allows admins to quickly make small changes to existing schedules.
class ScheduleBuilder extends StatefulWidget {
	/// Opens the schedule builder and saves the result.
	/// 
	/// If you pass a schedule, the builder will configure itself to match it.
	/// This allows admins to make small changes quickly. 
	static Future<Schedule?> buildSchedule(
		BuildContext context,
		{Schedule? preset}
	) => Navigator
		.of(context)
		.push<Schedule>(
			PageRouteBuilder(
				transitionDuration: Duration.zero,
				pageBuilder: (_, __, ___) => ScheduleBuilder(preset: preset))
		);

	/// The schedule to work off.
	final Schedule? preset;

	/// Creates a schedule builder, with an optional preset. 
	const ScheduleBuilder({this.preset});

  @override
  ScheduleBuilderState createState() => ScheduleBuilderState();
}

/// The state for the schedule builder.
class ScheduleBuilderState extends State<ScheduleBuilder> {
	/// The model that represents the data. 
	late ScheduleBuilderModel model;

	/// Triggers whenever the underlying data updates. 
	void listener() => setState(() {});

	@override
	void initState() {
		model = ScheduleBuilderModel()
			..usePreset(widget.preset)
			..addListener(listener);
		super.initState();
	}

	@override
	void dispose() {
		model
			..removeListener(listener)
			..dispose();
		super.dispose();
	}

  @override
  Widget build(BuildContext context) => ResponsiveScaffold(
  	drawer: const NavigationDrawer(),
    appBar: AppBar(title: const Text("Create schedule")),
    bodyBuilder: (_) => Column(
	    children: [
	      Expanded(
	        child: ListView(
	          padding: const EdgeInsets.all(16),
	          children: [
	            TextField(
	              decoration: const InputDecoration(hintText: "Name of schedule"),
	              onChanged: (String value) => model.name = value,
	            ),
	            const SizedBox(height: 16),
	            IntegerInput(
	              value: model.periods.length,
	              onAdd: model.addPeriod,
	              onRemove: model.removePeriod,
	            ),
	            const SizedBox(height: 24),
	            DataTable(
	              columns: const [
	                DataColumn(label: Text("Name")),
	                DataColumn(label: Text("Start")),
	                DataColumn(label: Text("End")),
	                DataColumn(label: Text("Class?")),
	              ],
	              rows: [
	                for (final EditablePeriod period in model.periods) DataRow(
	                  cells: [
	                    DataCell(
	                      TextField(
	                        controller: period.controller,
	                        onChanged: (_) => setState(() {}),
	                      ),
	                      showEditIcon: true,
	                    ),
	                    DataCell(
	                      Text(
	                      	period.start?.format(context) ?? "Start time",
	                      	style: !period.hasInvalidTime ? null : TextStyle(
	                      		color: Theme.of(context).colorScheme.error
                      		),
                      	),
	                      placeholder: period.start == null,
	                      showEditIcon: true,
	                      onTap: () async {
	                        period.start = (await editTime(period.start)) 
		                        ?? period.start;
	                        setState(() {});
	                      } 
	                    ),
	                    DataCell(
	                      Text(
	                      	period.end?.format(context) ?? "End time",
	                      	style: !period.hasInvalidTime ? null : TextStyle(
	                      		color: Theme.of(context).colorScheme.error
                      		),
                      	),
	                      placeholder: period.end == null,
	                      showEditIcon: true,
	                       onTap: () async {
	                        period.end = (await editTime(period.end)) 
		                        ?? period.end;
	                        setState(() {});
	                      } 
	                    ),
	                    DataCell(
	                      int.tryParse(period.name) == null ? Container() 
		                      : const Icon(Icons.check, color: Colors.green),
	                    )
	                  ]
	                ),
	              ]
	            ),
	          ],
	        ),
	      ),
	      const SizedBox(height: 16),
	      Row(
	        children: [
	          const SizedBox(width: 16),
	          TextButton(
	            onPressed: () => showModalBottomSheet(
	              context: context,
	              builder: (_) => ListView(
	                children: [
	                  for (final Schedule schedule in Schedule.schedules)
	                    ListTile(
	                    	title: Text(schedule.name),
	                    	subtitle: Text("${schedule.periods.length} periods"),
	                    	onTap: () {
	                    		model.usePreset(schedule);
	                    		Navigator.of(context).pop();
	                    	}
	                  	)
	                ]
	              )
	            ),
	            child: const Text("Build off another schedule"),
	          ),
	          const Spacer(),
	          TextButton(
	            onPressed: () => Navigator.of(context).pop(),
	            child: const Text("Cancel"),
	          ),
	          ElevatedButton(
	            onPressed: !model.isReady ? null : 
	              () => Navigator.of(context).pop(model.schedule),
	            child: const Text("Save"),
	          ),
	          const SizedBox(width: 16),
	        ]
	      ),
	      const SizedBox(height: 16),
	    ]
    )
  );
    
	/// Picks a new time for a period. 
	/// 
	/// On desktop, this shows the keyboard-friendly UI. On all other devices,
	/// the touch-friendly UI is the default.
  Future<TimeOfDay?> editTime([TimeOfDay? initialTime]) {
  	final LayoutInfo layout = LayoutInfo(context);
  	return showTimePicker(
	    context: context,
	    initialTime: initialTime ?? TimeOfDay.now(),
	    initialEntryMode: layout.isDesktop 
		    ? TimePickerEntryMode.input : TimePickerEntryMode.dial,
	  );
  }
}
