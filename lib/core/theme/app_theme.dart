import 'package:flutter/material.dart';

ThemeData buildAppTheme(BuildContext context) {
  final colorScheme = const ColorScheme.dark(
    primary: Colors.white,
    onPrimary: Colors.black,
    secondary: Colors.white70,
    onSecondary: Colors.black,
    surface: Colors.black54,
    onSurface: Colors.white,
    primaryContainer: Color(0xFF2E7D32),
    onPrimaryContainer: Colors.white,
    secondaryContainer: Color(0xFF1565C0),
    onSecondaryContainer: Colors.white,
  );

  final scaffoldBg = const Color.fromARGB(183, 0, 0, 0).withOpacity(0.3);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: scaffoldBg,
    dialogBackgroundColor: Colors.black54,
    textTheme: const TextTheme(
      titleMedium: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      bodySmall: TextStyle(color: Colors.white70),
      labelLarge: TextStyle(color: Colors.white),
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, foregroundColor: Colors.white),
    cardTheme: CardThemeData(
      color: Colors.black45,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white12,
      selectedColor: Colors.white24,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((_) => Colors.white),
      trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.blueGrey : Colors.white24),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(color: Colors.white70),
      labelStyle: TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
    ),
  );
}


