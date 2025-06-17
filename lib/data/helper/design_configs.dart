import 'package:flutter/material.dart';

class DesignConfig {
  static BoxDecoration boxDecorationBorder({
    required Color color,
    required double radius,
    Color? borderColor,
    double? borderWidth,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: borderColor == null
          ? null
          : Border.all(color: borderColor, width: borderWidth ?? 1),
    );
  }
}
