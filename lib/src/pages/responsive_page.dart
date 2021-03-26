import "package:flutter/material.dart";

abstract class ResponsivePage {
	const ResponsivePage();
	AppBar get appBar;
	WidgetBuilder get builder;
	Widget? get sideSheet => null;
	Widget? get floatingActionButton => null;
	FloatingActionButtonLocation? get floatingActionButtonLocation => null;
}
