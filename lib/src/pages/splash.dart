import "package:flutter/material.dart"; 

import "package:ramaz/widgets.dart";

class SplashScreen extends StatelessWidget {
	// ignore_for_file: prefer_const_constructors_in_immutables

	final void Function (Brightness) setBrightness;
	const SplashScreen({this.setBrightness});

	@override Widget build (BuildContext context) => MaterialApp (
		home: Scaffold (
			body: Builder (
				builder: (BuildContext context) {
					Future (
						() => setBrightness(
							MediaQuery.of(context).platformBrightness
						)
					);
					return Center (child: RamazLogos.ramSquareWords);
				}
			)
		)
	);
}