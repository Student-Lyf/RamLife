import "package:flutter/material.dart";

import "package:ramaz/models.dart";
import "package:ramaz/widgets.dart";
import "drawer.dart";

/// Clubs page
class ClubsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ProviderConsumer(
        create: DashboardModel.new,
        builder: (model, child) => ResponsiveScaffold(
            enableNavigation: true,
            drawer: const RamlifeDrawer(),
            appBar: AppBar(title: const Text("Clubs"), actions: [
              ResponsiveBuilder(
                  builder: (_, LayoutInfo layout, __) =>
                      !layout.hasStandardSideSheet && model.schedule.hasSchool
                          ? Builder(
                              builder: (BuildContext context) => IconButton(
                                    onPressed: () =>
                                        Scaffold.of(context).openEndDrawer(),
                                    icon: const Icon(Icons.schedule,
                                        color: Colors.white),
                                  ))
                          : const SizedBox.shrink())
            ]),
            sideSheet: !model.schedule.hasSchool
                ? null
                : Drawer(child: ClassList.fromSchedule(model.schedule)),
            body: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                children: const [Text("hi")])),
      );
}
