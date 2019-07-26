import "package:flutter/material.dart";

class ChangeNotifierListener<Model extends ChangeNotifier> extends StatefulWidget {
  final Model model;
  final ValueWidgetBuilder<Model> builder;
  final Widget child;
  const ChangeNotifierListener ({
    @required this.model,
    @required this.builder,
    this.child,
  });

  @override 
  ChangeNotifierState createState() => ChangeNotifierState();
}

class ChangeNotifierState extends State<ChangeNotifierListener> {

  @override void initState() {
    super.initState();
    widget.model.addListener(listener);
  }

  @override void didUpdateWidget (ChangeNotifierListener<ChangeNotifier> old) {
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
