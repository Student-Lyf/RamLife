import "package:flutter/material.dart";

// Setup:
// 	install devtools: flutter packages pub global activate devtools
// 	start devtools: flutter packages pub global run devtools
// 	start app: flutter run --track-widget-creation
// 	open the url devtools gives with the url from flutter 
// Usage: 
// 	replace Image.asset with LoadingImage(String path)
// 	in devTools: 
// 		go to the corresponding LoadingImage widget
// 		expand Image.semantics.renderObject.size
// 	Enter width and heights as parameters to LoadingImage constructor

class LoadingImage extends StatefulWidget {
	final double aspectRatio;
	final String path;
	const LoadingImage(
		this.path,
		{this.aspectRatio}
	);

	@override 
	LoadingImageState createState() => LoadingImageState();
}

class LoadingImageState extends State<LoadingImage> {
	ImageProvider image;
	ImageStreamListener listener;
	ImageStream stream;
	bool loading = true;
	double aspectRatio;

	@override void initState() {
		super.initState();
		image = AssetImage(widget.path);
		stream = image.resolve(ImageConfiguration());
		listener = ImageStreamListener (onLoad);
		stream.addListener(listener);
	}

	void onLoad (ImageInfo info, bool _) {
		setState(() => loading = false);
		final Size size = Size (
			info.image.width.toDouble(), 
			info.image.height.toDouble()
		);
		aspectRatio = size.aspectRatio;
		if (widget.aspectRatio == null)
			print ("LoadingImage: Aspect ratio for ${widget.path} is $aspectRatio");
	}

	@override Widget build(BuildContext context) => loading
		? AspectRatio (
			child: Center (child: CircularProgressIndicator()),
			aspectRatio: widget.aspectRatio ?? 1
		)
		: AspectRatio (
			aspectRatio: aspectRatio,
			child: Image (image: image)
		);

	@override void dispose () {
		stream.removeListener(listener);
		super.dispose();
	}
}
