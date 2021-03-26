import "package:flutter/material.dart";

/// A function to build a widget with a [ChangeNotifier] subclass. 
typedef ModelBuilder<T extends ChangeNotifier> = 
  Widget Function(BuildContext context, T model, Widget? child);

/// A widget that listens to a [ChangeNotifier] and rebuilds the widget tree
/// when [ChangeNotifier.notifyListeners].
class ModelListener<Model extends ChangeNotifier> extends StatefulWidget {
  /// A function to create the model to listen to. 
  /// 
  /// It is important that this be a function and not an instance, because 
  /// otherwise the model will be recreated every time the widget tree 
  /// is updated. With a function, this widget can choose when to create 
  /// the model. 
  final Model Function() model;

  /// The function to build the widget tree underneath this. 
  final ModelBuilder<Model> builder;

  /// An optional child to cache. 
  /// 
  /// This child is never re-built, so if there is an expensive widget that
  /// does not depend on [model], it would go here and can be 
  /// re-used in [builder]. 
  final Widget? child;

  /// Whether or not to dispose the [model].
  /// 
  /// Some models are used elsewhere in the app (like data models) while other 
  /// models (like view models) are only used in one screen. 
  final bool dispose;

  /// Creates a widget that listens to a [ChangeNotifier].
  const ModelListener ({
    required this.model,
    required this.builder,
    this.child,
    this.dispose = true
  });

  @override 
  ModelListenerState createState() => ModelListenerState<Model>();
}

/// A state for a [ModelListener]. 
class ModelListenerState<Model extends ChangeNotifier> 
  extends State<ModelListener<Model>> 
{
  /// The model to listen to.
  /// 
  /// This is different than [ModelListener.model], which is a function that is
  /// called to create the model. Here is where the result of that function is 
  /// actually stored. 
  late final Model model;

  @override 
  void initState() {
    super.initState();
    model = widget.model()..addListener(listener);
  }

  @override 
  void dispose() {
    try {
      model.removeListener(listener);
    } catch(_) {  // ignore: avoid_catches_without_on_clauses
      // The model may have already been disposed. If so, we're good. 
    }
    if (widget.dispose) {
      model.dispose();
    }
    super.dispose();
  }

  @override 
  Widget build (BuildContext context) => widget.builder (
    context, model, widget.child
  );

  /// Rebuilds the widget tree whenever [model] updates. 
  void listener() => setState(() {});
}
