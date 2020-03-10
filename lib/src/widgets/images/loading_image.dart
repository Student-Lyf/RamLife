import "package:flutter/material.dart";


/// An image that displays a [CircularProgressIndicator] while loading. 
/// 
/// This widget helps keep the same shape as the image so that when the image 
/// finishes loading the other widgets won't move around. This is accomplished
/// by providing the aspect ratio of the image. To get the aspect ratio, if 
/// it's not already known, there is a two-step process:
/// 
/// Setup:
/// 
/// 1. Install devtools: `flutter packages pub global activate devtools`
/// 2. Start devtools: `flutter packages pub global run devtools`
/// 3. Start app: `flutter run --track-widget-creation`
/// 4. Open the url devtools gives with the url from flutter 
/// 
/// Usage: 
/// 
/// 1. Replace `Image.asset` with `LoadingImage(String path)`
/// 2. In devTools: 
/// 	1. Go to the corresponding LoadingImage widget
/// 	2. Expand Image.semantics.renderObject.size
/// 3. Enter the aspect ratio as parameters to [LoadingImage()] constructor
class LoadingImage extends StatefulWidget {
	/// The aspect ratio of the image. 
	/// 
	/// This is used to size the [CircularProgressIndicator] so that it is 
	/// roughly the same size as the image will be when it loads. 
	final double aspectRatio;

	/// The path of the image. 
	/// 
	/// All [LoadingImage]s use [AssetImage]s. 
	final String path;

	/// Creates an image with a placeholder while it loads. 
	const LoadingImage(
		this.path,
		{this.aspectRatio}
	);

	@override 
	LoadingImageState createState() => LoadingImageState();
}

/// A state for a [LoadingImage].
/// 
/// This state handles loading the image in the background and switching 
/// out the placeholder animation with the actual image when it loads. 
class LoadingImageState extends State<LoadingImage> {
	/// The image to be loaded. 
	ImageProvider image;

	/// A listener that will notify when the image has loaded. 
	ImageStreamListener listener;

	/// The stream of bytes in the image. 
	ImageStream stream;

	/// Whether the image is still loading. 
	bool loading = true;

	/// The aspect ratio of the image. 
	double aspectRatio;

	@override void initState() {
		super.initState();
		image = AssetImage(widget.path);
		stream = image.resolve(const ImageConfiguration());
		listener = ImageStreamListener(onLoad);
		stream.addListener(listener);
	}

	/// Rebuilds the widget tree to include the image. 
	/// 
	/// Also prints out the aspect ratio as a convenience to the developer. 
	// this is a Flutter function override
	// BUG: Check if this actually works.
	// ignore: avoid_positional_boolean_parameters
	void onLoad (ImageInfo info, bool _) {
		setState(() => loading = false);
		aspectRatio = Size (
			info.image.width.toDouble(), 
			info.image.height.toDouble()
		).aspectRatio;
		if (widget.aspectRatio == null) {
			debugPrint("LoadingImage: Aspect ratio for ${widget.path} is $aspectRatio");
		}
	}

	@override Widget build(BuildContext context) => loading
		? AspectRatio (
			aspectRatio: widget.aspectRatio ?? 1,
			child: const Center (child: CircularProgressIndicator()),
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
