import "package:flutter/material.dart";
import "dart:ui" show window;

// To use this class effectively: 
// - replace Image.asset constructors with LoadingImage
// - wait for screen to build and check the dimensions in the terminal
// - add the dimensions as paramters to the constructor
// - add debug: false in the constructor to silence

class LoadingImage extends StatefulWidget {
	final double width, height;
	final String path;
	final bool debug;
	const LoadingImage(
		this.path,
		{
			this.width,
			this.height,
			this.debug = true
		}
	);

	@override 
	LoadingImageState createState() => LoadingImageState();
}

class LoadingImageState extends State<LoadingImage> {
	ImageProvider image;
	bool loading = true;

	@override void initState() {
		super.initState();
		image = AssetImage(widget.path);
		image.resolve(ImageConfiguration()).addListener(onLoad);
	}

	void onLoad(ImageInfo info, bool _) {
		// final Size screenSize = MediaQuery.of(context).size;
		final double ratio = window.devicePixelRatio * 10;
		final int height = info.image.height ~/ ratio;
		final int width = info.image.width ~/ ratio;
		if (widget.debug) {
			// print ("MediaQuery height: ${screenSize.height}");
			print ("Image height: ${info.image.height}");
			// print ("MediaQuery width: ${screenSize.width}");
			print ("Image width: ${info.image.width}");
			print ("(LoadingImage) Image ${widget.path} loaded");
			print ("\tscale=${info.scale}");
			print ("(LoadingImage) \tDimensions: height=$height. width=$width");
		}
		setState(() => loading = false);
	}

	@override Widget build(BuildContext context) => loading
		? SizedBox (
			child: Center (child: CircularProgressIndicator()),
			height: widget.height,
			width: widget.width
		)
		: Image(
			image: image, 
			height: widget.height,
			width: widget.width
		);
}
