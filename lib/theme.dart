import 'package:flutter/material.dart';

ThemeData createTheme() {
  final theme = ThemeData(
    primarySwatch: Colors.deepPurple,
    primaryColor: Colors.deepPurple[50],
    // See https://github.com/flutter/flutter/wiki/Desktop-shells#fonts
    fontFamily: 'Roboto',
  );
  final border = OutlineInputBorder(
      gapPadding: 4,
      borderSide: BorderSide(color: theme.primaryColor, width: 2),
      borderRadius: const BorderRadius.all(Radius.circular(4)));
  return theme.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
//    enabledBorder: border,
//    focusedBorder: border,
//      border: border,
      isDense: true,
    ),
  );
}
