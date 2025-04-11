import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText(
    this.text, {
    super.key,
    this.color,
    this.showLineThrough = false,
    this.fontWeight,
    this.fontStyle,
    this.fontSize,
    this.textAlign,
    this.maxLines,
    this.height,
    this.showUnderline = false,
    this.underlineOrLineColor,
    this.letterSpacing,
    this.textBaseline,
  });

  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? fontSize;
  final double? height;
  final TextAlign? textAlign;
  final int? maxLines;
  final bool showLineThrough;
  final bool showUnderline;
  final Color? underlineOrLineColor;
  final double? letterSpacing;
  final TextBaseline? textBaseline;

  @override
  Widget build(BuildContext context) {
    final decoration = showLineThrough
        ? TextDecoration.lineThrough
        : showUnderline
            ? TextDecoration.underline
            : null;

    final style = TextStyle(
      color: color ?? context.color.textColorDark,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontSize: fontSize,
      decoration: decoration,
      decorationColor: underlineOrLineColor,
      height: height,
      letterSpacing: letterSpacing,
      textBaseline: textBaseline,
    );

    return Text(
      text,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : null,
      softWrap: maxLines != null,
      style: style,
      textAlign: textAlign,
      textScaler: TextScaler.noScaling,
    );
  }
}
