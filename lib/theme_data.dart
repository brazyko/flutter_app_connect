import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.lightBlueAccent, // Light blue as primary
  colorScheme: const ColorScheme.light(
    primary: Colors.lightBlueAccent,
    secondary: Colors.greenAccent, // Use a pastel green as a secondary color
  ),
  scaffoldBackgroundColor: Colors.white, // Light background
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue, // Light grey for AppBar background
    iconTheme: IconThemeData(color: Colors.black), // Black for AppBar icons
    titleTextStyle: TextStyle(
      color: Colors.black, // Dark text color for AppBar title
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.grey),
    bodySmall: TextStyle(color: Colors.grey), // Optional, dark grey text
  ),
  switchTheme: SwitchThemeData(
    trackColor: MaterialStateProperty.all(Colors.lightBlueAccent),
    thumbColor: MaterialStateProperty.all(Colors.white),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey[800], // Dark grey for primary color
  colorScheme: const ColorScheme.dark(
    primary: Colors.grey,
    secondary: Colors.pinkAccent, // Soft pastel pink as secondary
  ),
  scaffoldBackgroundColor: Colors.black26, // Dark background
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black, // Black for AppBar background
    iconTheme: IconThemeData(color: Colors.white), // White for AppBar icons
    titleTextStyle: TextStyle(
      color: Colors.white, // White for AppBar title text
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.lightGreen),
    bodyMedium: TextStyle(color: Colors.white),
    bodySmall: TextStyle(color: Colors.lightGreen), // Optional, light grey text
  ),
  switchTheme: SwitchThemeData(
    trackColor: MaterialStateProperty.all(Colors.grey[600]),
    thumbColor: MaterialStateProperty.all(Colors.grey[800]),
  ),
);
