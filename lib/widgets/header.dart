import "package:flutter/material.dart";

class Header extends StatelessWidget {
	@override Widget build (BuildContext context) => BottomAppBar(
		child: Container (
			height: 50,
			child: Center (
				child: Text ("This will be the bottom bar")
			)
		)
	);
}