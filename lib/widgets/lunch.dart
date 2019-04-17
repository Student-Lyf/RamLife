import "package:flutter/material.dart";
import "../backend/schedule.dart" show Lunch;
import "info_tile.dart";

class LunchTile extends StatelessWidget {
	final Lunch lunch;
	const LunchTile ({@required this.lunch});

	@override Widget build (BuildContext context) => InfoTile (
		icon: Icons.fastfood,
		title: "Today's lunch is ${lunch.main}",
		children: [
			"Main: ${lunch.main}",
			"Soup: ${lunch.soup}",
			"Side 1: ${lunch.side1}",
			"Side 2: ${lunch.side2}",
			"Salad: ${lunch.salad}",
			"Dessert: ${lunch.dessert}"
		]
	);
}