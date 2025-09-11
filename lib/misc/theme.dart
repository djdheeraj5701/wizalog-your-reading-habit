import 'package:flutter/material.dart';

// Defines the global theme for the WizAlog app.
final ThemeData wizalogTheme = ThemeData(
  // Use a modern color scheme
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Primary color for the app
    primary: Colors.blue[600]!,
    onPrimary: Colors.white,
    secondary: Colors.amber[400]!, // Accent color for floating action button
    onSecondary: Colors.black,
    surface: Colors.white,
    onSurface: Colors.black,
  ),
  // Customize the typography
  fontFamily: 'Inter',

  // Customize the ElevatedButton theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, // Text color
      backgroundColor: Colors.blue[600], // Button background color
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4, // Add a slight shadow
      // You can also add other properties like textStyle
    ),
  ),

  // Customize the FloatingActionButton theme
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.amber[400],
    foregroundColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50),
    ),
  ),

  // Customize the AppBar theme
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
    elevation: 0,
  ),
);
