import "package:adaptive_breakpoints/adaptive_breakpoints.dart";
import "package:flutter/material.dart";

/// Provides info about how this scaffold should be laid out.
/// 
/// Uses [getWindowType] from Material's `adaptive_breakpoints` package to 
/// determine which layout should be built and exposes getters such as 
/// [hasNavRail] to define how the layout should look.
@immutable
class LayoutInfo {
	/// The breakpoint as defined by [material.io](https://material.io/design/layout/responsive-layout-grid.html#breakpoints)
	final AdaptiveWindowType windowType;

	/// Stores info about the layout based on Material Design breakpoints. 
	LayoutInfo(BuildContext context) : 
		windowType = getWindowType(context);

	/// Whether the app should use a [NavigationBar].
	bool get hasBottomNavBar => deviceType == DeviceType.mobile;

	/// Whether the app should use a [NavigationRail]. 
	bool get hasNavRail => deviceType == DeviceType.tabletLandscape 
		|| deviceType == DeviceType.tabletPortrait;

	/// Whether the app should have a persistent [Scaffold.endDrawer].
	bool get hasStandardSideSheet => deviceType == DeviceType.tabletLandscape 
		|| deviceType == DeviceType.desktop;

	/// Whether the app should have a persistent [Drawer].
	bool get hasStandardDrawer => deviceType == DeviceType.desktop;

	/// The probable device being used, based on the size.
	DeviceType get deviceType {
		switch (windowType) {
			case AdaptiveWindowType.xsmall: return DeviceType.mobile;
			case AdaptiveWindowType.small: return DeviceType.tabletPortrait;
			case AdaptiveWindowType.medium: return DeviceType.tabletLandscape;
			case AdaptiveWindowType.large: return DeviceType.desktop;
			case AdaptiveWindowType.xlarge: return DeviceType.desktop;
			default: return DeviceType.mobile;
		}
	}
}

/// Different user devices.
enum DeviceType {
	/// A desktop, implying a large screen and a resizable window.
	desktop, 

	/// A tablet in landscape mode, implying a wide screen.
	tabletLandscape, 

	/// A tablet in portrait mode, implying a medium-widget screen. 
	tabletPortrait, 

	/// A phone, implying a narrow screen.
	mobile
}
