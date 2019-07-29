import "package:flutter/material.dart";

typedef ModelBuilder<T extends ChangeNotifier> = Widget Function(BuildContext, T, Widget);

class ChangeNotifierListener<Model extends ChangeNotifier> extends StatefulWidget {
  final Model model;
  // final ValueWidgetBuilder<Model> builder;
  // final ModelBuilder<Model> builder;
  final Widget Function(BuildContext, Model, Widget) builder;
  final Widget child;
  const ChangeNotifierListener ({
    @required this.model,
    @required this.builder,
    this.child,
  });

  @override 
  ChangeNotifierState createState() => ChangeNotifierState<Model>();
}

class ChangeNotifierState<Model extends ChangeNotifier> extends State<ChangeNotifierListener<Model>> {
  @override void initState() {
    super.initState();
    widget.model.addListener(listener);
  }

  @override void didUpdateWidget (ChangeNotifierListener<Model> old) {
    if (old.model != widget.model) {
      old.model.dispose();
      widget.model.addListener(listener);
    }
    super.didUpdateWidget(old);
  }

  @override void dispose() {
    widget.model.removeListener(listener);
    widget.model.dispose();
    super.dispose();
  }

  @override Widget build (BuildContext context) => widget.builder (
    context, widget.model, widget.child
  );

  void listener() => setState(() {});
}
