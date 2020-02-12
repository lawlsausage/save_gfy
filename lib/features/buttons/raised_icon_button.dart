import 'package:flutter/material.dart';

class RaisedIconButton extends StatelessWidget {
  RaisedIconButton({
    Key key,
    this.color,
    this.icon = const Icon(Icons.add),
    this.iconSize = 24.0,
    this.padding = const EdgeInsets.all(24.0),
    this.onPressed,
  }) : super(key: key);

  /// Defaults to the context's Theme [primaryColor] if null.
  final Color color;

  final Icon icon;

  final double iconSize;

  final EdgeInsets padding;
  
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.antiAlias,
      type: MaterialType.transparency,
      shape: CircleBorder(),
      child: InkWell(
        child: Ink(
          decoration: ShapeDecoration(
            color: color ?? Theme.of(context).primaryColor,
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: icon,
            iconSize: iconSize,
            padding: padding,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
