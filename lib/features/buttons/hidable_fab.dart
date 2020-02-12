import 'package:flutter/material.dart';

class HidableFab extends StatefulWidget {
  HidableFab({
    Key key,
    this.hide,
    this.onPressed,
    this.tooltip,
    this.fabChild,
  }) : super(key: key);

  final bool hide;

  final void Function() onPressed;

  final String tooltip;

  final Widget fabChild;

  @override
  HidableFabState createState() => HidableFabState();
}

class HidableFabState extends State<HidableFab> with TickerProviderStateMixin {
  AnimationController _hideFabController;

  @override
  void initState() {
    super.initState();

    _hideFabController =
        AnimationController(vsync: this, duration: kThemeAnimationDuration);
    _hideFabController.forward();
  }

  @override
  void didUpdateWidget(HidableFab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.hide != widget.hide) {
      TickerFuture Function() controllerAction =
          widget.hide ? _hideFabController.reverse : _hideFabController.forward;
      controllerAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _hideFabController,
      // alignment: Alignment.bottomCenter,
      child: FloatingActionButton(
        // elevation: 8,
        onPressed: widget.onPressed,
        tooltip: widget.tooltip,
        child: widget.fabChild,
      ),
    );
  }
}
