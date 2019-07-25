import "package:flutter/material.dart";

class ChangeNotifierListener<Model extends ChangeNotifier> extends StatefulWidget {
  final Model model;
  final Widget Function (BuildContext, Model, Widget) builder;
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