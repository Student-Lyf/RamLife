import "package:flutter/material.dart";

class NavigationDrawer extends StatelessWidget {
	@override Widget build (BuildContext context) => Drawer (
		child: Column (
			children: [
				DrawerHeader (child: Placeholder()),
				ListTile (
					title: Text ("Lunch"),
					leading: Icon (Icons.fastfood),
					onTap: () => Navigator.of(context).pushNamed("lunch")
				),
				ListTile (
					title: Text ("Schedule"),
					leading: Icon (Icons.schedule),
					onTap: () => Navigator.of(context).pushNamed("schedule")
				),
				ListTile (
					title: Text ("News"),
					leading: Icon (Icons.new_releases),
					onTap: () => Navigator.of(context).pushNamed("news"),
				),
				ListTile (
					title: Text ("Lost and Found"),
					leading: Icon (Icons.help),
					onTap: () => Navigator.of(context).pushNamed("lost-and-found")
				),
				ListTile (
					title: Text ("Sports"),
					subtitle: Text ("Need to find a good icon for this"),
					onTap: () => Navigator.of(context).pushNamed("sports")
				)
			]
		)
	);
}