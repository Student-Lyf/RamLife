import "package:flutter/material.dart";

typedef ModelBuilder<T extends ChangeNotifier> = Widget Function(BuildContext, T, Widget);

class ModelListener<Model extends ChangeNotifier> extends StatefulWidget {
  final Model Function() model;
  final Widget Function(BuildContext, Model, Widget) builder;
  final Widget child;
  final VoidCallback setup;

  const ModelListener ({
    @required this.model,
    @required this.builder,
    this.child,
    this.setup,
  });

  @override 
  ModelListenerState createState() => ModelListenerState<Model>();
}

class ModelListenerState<Model extends ChangeNotifier> 
  extends State<ModelListener<Model>> 
{
  Model model;

  @override void initState() {
    super.initState();
    model = widget.model();
    model.addListener(listener);
    if (widget.setup != null) widget.setup();
  }

  @override void dispose() {
    model.removeListener(listener);
    super.dispose();
  }

  @override Widget build (BuildContext context) => widget.builder (
    context, model, widget.child
  );

  void listener() => setState(() {});
}
