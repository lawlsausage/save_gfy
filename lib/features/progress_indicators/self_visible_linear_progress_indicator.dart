import 'package:flutter/material.dart';

/// A [LinearProgressIndicator] which handles its visibility based on the [value].
/// If [value] is < 1.0, [SelfVisibleLinearProgressIndicator] will be visible. When
/// [value] is >= 1.0, [SelfVisibleLinearProgressIndicator] will __NOT__ be visible.
class SelfVisibleLinearProgressIndicator extends StatelessWidget {
  const SelfVisibleLinearProgressIndicator({
    Key key,
    this.value,
    this.semanticsLabel,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  /// See documentation for the [ProgressIndicator.value] property.
  final double value;

  /// See documentation for the [ProgressIndicator.semanticsLabel] property.
  final String semanticsLabel;

  /// See documentation for the [ProgressIndicator.backgroundColor] property.
  /// If null, the property will default to [Colors.white].
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      child: Center(
        child: LinearProgressIndicator(
          semanticsLabel: semanticsLabel,
          backgroundColor: Colors.white,
          value: value,
        ),
      ),
      visible: value < 1.0,
    );
  }
}
