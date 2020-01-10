// ignore_for_file: prefer_const_constructors_in_immutables

import "package:flutter/material.dart"; 

import "package:ramaz/widgets.dart";

/// A splash screen that discreetly loads the device's brightness. 
class SplashScreen extends StatelessWidget {
	/// A callback for when the device's brightness is determined. 
	final void Function(Brightness) setBrightness;

	/// Creates a splash screen. 
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