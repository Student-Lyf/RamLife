import "package:flutter/material.dart";

import "package:ramaz/models.dart";
import "package:ramaz/pages.dart";
import "package:ramaz/widgets.dart";

/// A page to show the admin's custom specials. 
class SpecialPage extends StatelessWidget {
	// If the user is on this page, they are an admin.
	// So, model.admin != null
	@override
	Widget build(BuildContext context) => ModelListener<UserModel>(
		model: () => Models.instance.user,
		dispose: false,
		builder: (_, UserModel model, __) => Scaffold(
			appBar: AppBar(
				title: const Text("Custom schedules"),
			),
			floatingActionButton: FloatingActionButton(
				onPressed: () async => model.addSpecialToAdmin(
					await SpecialBuilder.buildSpecial(context),
				),
				child: const Icon(Icons.add),
			),
			body: Padding(
				padding: const EdgeInsets.all(20), 
				child: model.admin!.specials.isEmpty
					? const Center (
						child: Text (
							"You don't have any schedules yet, but you can make one!",
							textScaleFactor: 1.5,
							textAlign: TextAlign.center,
						)
					)
					: ListView(
						children: [
							for (int index = 0; index < model.admin!.specials.length; index++)
								ListTile(
									title: Text (model.admin!.specials [index].name),
									trailing: IconButton(
										icon: const Icon(Icons.remove_circle),
										onPressed: () => model.removeSpecialFromAdmin(index),
									),
									onTap: () async => model.replaceAdminSpecial(
										index, 
										await SpecialBuilder.buildSpecial(
											context, 
											model.admin!.specials [index]
										),
									)
								)
						]
				)
			)
		)
	);
}

