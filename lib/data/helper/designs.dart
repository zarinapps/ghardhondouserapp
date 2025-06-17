import 'package:ebroker/utils/extensions/lib/custom_text.dart';
import 'package:flutter/material.dart';

//
const double defaultPadding = 20;
//
Widget setTextbutton(
  String titleTxt,
  Color txtColor,
  FontWeight? fontWeight,
  VoidCallback onPressed,
  BuildContext context,
) {
  return TextButton(
    onPressed: onPressed,
    child: CustomText(
      titleTxt,
      color: txtColor,
      fontWeight: fontWeight,
      letterSpacing: 0.5,
    ),
  );
}
