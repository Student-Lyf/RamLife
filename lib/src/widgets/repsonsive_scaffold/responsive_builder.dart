import "package:flutter/material.dart";

import "layout_info.dart";
export "layout_info.dart";

/// A function that returns a widget that depends on a [LayoutInfo].
/// 
/// Used by [ResponsiveBuilder].
typedef ResponsiveWidgetBuilder = 
	Widget Function(BuildContext, LayoutInfo, Widget?);

/// Builds a widget tree according to a [LayoutInfo].
class ResponsiveBuilder extends StatelessWidget {
	/// An optional widget that doesn't depend on the layout info.
	/// 
	/// Use this field to cache large portions of the widget tree so they don't 
	/// rebuild every frame when a window resizes. 
	final Widget? child;

	/// A function to build the widget tree.
	final ResponsiveWidgetBuilder builder;

	/// A builder to layout the widget tree based on the device size. 
	const ResponsiveBuilder({
		required this.builder,
		this.child,
	});

	@override
	Widget build(BuildContext context) => 
		builder(context, LayoutInfo(context), child);
}
