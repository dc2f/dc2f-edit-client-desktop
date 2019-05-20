import 'package:flutter/material.dart';

final primaryColor = Colors.deepPurple[50];
final darkPrimaryColor = Colors.deepPurple[500];

ThemeData createTheme() {
  final theme = ThemeData(
    primarySwatch: Colors.deepPurple,
    primaryColor: primaryColor,
//    accentColor: Colors.deepOrange,
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
      fillColor: Colors.deepPurple[50].withOpacity(0.3),
      labelStyle: TextStyle(color: Colors.deepPurple),
//    enabledBorder: border,
//    focusedBorder: border,
//      border: border,
      isDense: true,
    ),
  );
}
