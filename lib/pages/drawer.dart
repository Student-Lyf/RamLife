import "package:flutter/material.dart";

// import "package:ramaz/widgets/linkIcon.dart";
import "package:ramaz/widgets/icons.dart";

import "package:ramaz/constants.dart";  // for route names

class NavigationDrawer extends StatelessWidget {
	@override Widget build (BuildContext context) => Drawer (
		child: ListView (
			children: [
				DrawerHeader (child: RamazLogos.ram_square),
				ListTile (
					title: Text ("Home"),
					leading: Icon (Icons.home),
					onTap: () => Navigator.of(context).pushReplacementNamed(HOME_PAGE)
				),
				ListTile (
					title: Text ("Schedule"),
					leading: Icon (Icons.schedule),
					onTap: () => Navigator.of(context).pushReplacementNamed(SCHEDULE)
				),
				ListTile (
					title: Text ("Newspapers (coming soon)"),
					leading: Icon (Icons.new_releases),
					onTap: () => Navigator.of(context).pushReplacementNamed(NEWS),
				),
				ListTile (
					title: Text ("Lost and Found (coming soon)"),
					leading: Icon (Icons.help),
					onTap: () => Navigator.of(context).pushReplacementNamed(LOST_AND_FOUND)
				),
				ListTile (
					title: Text ("Sports (coming soon)"),
					leading: Icon (Icons.directions_run),
					onTap: () => Navigator.of(context).pushReplacementNamed(SPORTS)
				),
				ListTile (
					title: Text ("Admin console (coming soon)"),
					leading: Icon (Icons.verified_user),
					onTap: () => Navigator.of(context).pushReplacementNamed(ADMIN_LOGIN)
				),
				ListTile (
					title: Text ("Logout"),
					leading: Icon (Icons.lock),
					onTap: () => Navigator.of(context).pushReplacementNamed(LOGIN)
				),
				SizedBox (height: 30),
				Divider(),
				SingleChildScrollView (
					physics: NeverScrollableScrollPhysics(),
					scrollDirection: Axis.horizontal,
					child: Row (
						children: [
							Logos.ramazIcon,
							Logos.outlook,
							Logos.schoology,
							Logos.drive,
							Logos.senior_systems
						]
					)
				)
			]
		)
	);
}
