import "package:flutter/material.dart";

// import "package:ramaz/widgets/linkIcon.dart";
import "package:ramaz/widgets/icons.dart";

import "package:ramaz/constants.dart";  // for route names

class NavigationDrawer extends StatelessWidget {
	@override Widget build (BuildContext context) => Drawer (
		child: ListView (
			children: [
				DrawerHeader (
					child: RamazLogos.ram_square,
					// child: LoadingImage(
					// 	"images/ram_square.png",
					// 	width: 272,
					// 	height: 137
					// )
				),
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
				Row (
					mainAxisSize: MainAxisSize.max,
					crossAxisAlignment: CrossAxisAlignment.center,
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Logos.ramazIcon,
						Logos.outlook,
						Logos.schoology,
						Logos.drive
					]
				)
				// ListTile (
				// 	onTap: () => launch (RAMAZ),
				// 	title: Text ("Ramaz.org"),
				// 	// Cannot use RamazLogos here, because we need an ImageProvider
				// 	leading: CircleAvatar (
				// 		backgroundImage: AssetImage ("images/logos/ramaz/teal.jpg"),
				// 	),
				// ),
				// ListTile (
				// 	onTap: () => launch (EMAIL),
				// 	title: Text ("Ramaz email"),
				// 	leading: Logos.outlook
				// 	// leading: CircleAvatar(
				// 	// 	backgroundImage: AssetImage("images/outlook.jpg")
				// 	// ),
				// ),
				// ListTile (
				// 	onTap: () => launch (SCHOOLOGY),
				// 	title: Text ("Schoology"),
				// 	leading: Logos.schoology
				// 	// leading: CircleAvatar(
				// 	// 	backgroundImage: AssetImage("images/schoology.png")
				// 	// ),
				// ),
				// ListTile (
				// 	onTap: () => launch (GOOGLE_DRIVE),
				// 	title: Text ("Google Drive"),
				// 	leading: Logos.drive
				// ),
				// ListTile (
				// 	title: Text ("My Backpack"),
				// 	leading: Icon (Icons.open_in_new),
				// 	onTap: () => launch (MY_BACKPACK)
				// ),
			]
		)
	);
}