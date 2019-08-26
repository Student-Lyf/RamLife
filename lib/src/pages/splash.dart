import "package:flutter/material.dart"; 
import "package:ramaz/widgets/icons.dart" show RamazLogos;

class SplashScreen extends StatelessWidget {
	final void Function (Brightness) setBrightness;
	SplashScreen({this.setBrightness});

	@override Widget build (BuildContext context) => MaterialApp (
		home: Scaffold (
			body: Builder (
				builder: (BuildContext context) {
					Future (
						() => setBrightness(
							MediaQuery.of(context).platformBrightness
						)
					);
					return Center (child: RamazLogos.ram_square_words);
				}
			)
		)
	);
}