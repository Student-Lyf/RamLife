import "package:flutter/material.dart";
import "package:provider/provider.dart";

/// A [Provider] and a [Consumer], wrapped in one.
/// 
/// To use, pass in a [create] function to create a new [ChangeNotifier], then pass a [builder] to
/// build the UI based on the data in the model. If you have a widget that does *not* depend on the 
/// underlying data, you can pass it in the [cachedChild] parameter to ensure it is not rebuilt. 
/// 
/// If you already have a [ChangeNotifier], you can pass it to the [.value()] constructor and it 
/// won't be disposed.
class ProviderConsumer<T extends ChangeNotifier> extends StatelessWidget {
	/// A function to create the [ChangeNotifier].
	final T Function()? create;

	/// A [ChangeNotifier] that was already created and won't be disposed here.
	final T? value;

	/// A function to build the UI based on the [ChangeNotifier].
	final Widget Function(T, Widget) builder;

	/// An optional [Widget] that does not depend on the model.
	/// 
	/// Large widget subtrees that don't depend on the model don't need to be rebuilt when the model
	/// updates. Passing the subtree here will ensure it is only built once. 
	final Widget? cachedChild;

	/// A widget that rebuilds when the underlying data changes.
	const ProviderConsumer({
		required this.create,
		required this.builder,
		this.cachedChild,
	}) : value = null;

	/// Analagous to [Provider.value].
	const ProviderConsumer.value({
		required this.value, 
		required this.builder, 
		this.cachedChild,
	}) : create = null;

	/// A [ChangeNotifierProvider] that will or won't dispose of the model. 
	Widget provider(Widget child) => value == null
		? ChangeNotifierProvider(
			create: (_) => create!(),
			builder: (context, _) => child,
		) : ChangeNotifierProvider.value(
			value: value,
			builder: (context, _) => child,
		);

	@override
	Widget build(BuildContext context) => provider(
		Consumer<T>(
			builder: (context, model, _) => builder(model, cachedChild ?? Container()),
		),
	);
}
