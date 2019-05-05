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
	final double width, height;
	final String path;
	const LoadingImage(
		this.path,
		{
			this.width,
			this.height,
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

	void onLoad(ImageInfo info, bool _) => setState(() => loading = false);

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
