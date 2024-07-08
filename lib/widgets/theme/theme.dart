import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  appBarTheme: const AppBarTheme(
    color: Colors.grey,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
  ),

  brightness: Brightness.light,
  //
  primaryColor: Colors.blue,
  canvasColor: Colors.black,
  //
  colorScheme: ColorScheme.light(
    onSurface: const Color.fromARGB(225, 31, 44, 52),
    onPrimary: const Color.fromARGB(213, 0, 0, 0),
    surface: Colors.white,
    primary: const Color.fromARGB(255, 200, 199, 199),
    secondary: Colors.grey[200]!,
    tertiary: Colors.grey[800]!,
  ),
  fontFamily: 'SignikaNegative-VariableFont_wght',
);

ThemeData darkMode = ThemeData(
  appBarTheme: const AppBarTheme(color: Colors.black),
  brightness: Brightness.dark,
  primaryColor: Colors.blue,
  primarySwatch: Colors.orange,
  canvasColor: Colors.white,
  //
  colorScheme: ColorScheme.dark(
    onSurface: const Color.fromARGB(225, 31, 44, 52),
    onPrimary: const Color.fromARGB(255, 170, 166, 166),
    surface: const Color.fromARGB(196, 18, 27, 34),
    primary: Colors.grey[900]!,
    secondary: Colors.grey[800]!,
    tertiary: Colors.grey[300],
  ),
  fontFamily: 'SignikaNegative-VariableFont_wght',
);
