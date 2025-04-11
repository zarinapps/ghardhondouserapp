// ignore_for_file: deprecated_member_use

import 'package:ebroker/utils/Extensions/extensions.dart';
import 'package:flutter/material.dart';

enum AppTheme { dark, light }

final commonThemeData = ThemeData(
  useMaterial3: false,
  fontFamily: 'Manrope',
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: tertiaryColor_.withValues(alpha: 0.3),
    cursorColor: tertiaryColor_,
    selectionHandleColor: tertiaryColor_,
  ),
);

final appThemeData = {
  AppTheme.light: commonThemeData.copyWith(
    brightness: Brightness.light,
    cardColor: tertiaryColor_,
    scrollbarTheme: const ScrollbarThemeData(
      radius: Radius.circular(8),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: tertiaryColor_,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(tertiaryColor_),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return tertiaryColor_.withValues(alpha: 0.3);
        }
        return primaryColorDark;
      }),
    ),
  ),
  AppTheme.dark: commonThemeData.copyWith(
    brightness: Brightness.dark,
    cardColor: tertiaryColor_.withValues(alpha: 0.7),
    scrollbarTheme: const ScrollbarThemeData(
      radius: Radius.circular(8),
    ),
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: tertiaryColor_,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(tertiaryColor_),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return tertiaryColor_.withValues(alpha: 0.3);
        }
        return primaryColor_.withValues(alpha: 0.2);
      }),
    ),
  ),
};
