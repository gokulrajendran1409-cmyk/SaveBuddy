import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

class PiggyBankApp extends StatelessWidget {
  const PiggyBankApp({super.key});

  ThemeData _buildDarkTheme() {
    final colorScheme = const ColorScheme.dark(
      primary: Color(0xFF21ACE6),
      onPrimary: Colors.white,
      secondary: Color(0xFF2A8AA6),
      onSecondary: Colors.white,
      surface: Color(0xFF05223A),
      onSurface: Color(0xFFE8F1F3),
      surfaceContainerHighest: Color(0xFF0C4C75),
      outline: Color(0xFF42617B),
      error: Color(0xFFFA5252),
      onError: Colors.white,
      inverseSurface: Color(0xFFE8F1F3),
      inversePrimary: Color(0xFF21ACE6),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        surfaceTintColor: Colors.transparent,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF062244),
        indicatorColor: colorScheme.primary,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white);
          }
          return const IconThemeData(color: Color(0xFF9BC8F3));
        }),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0E4A70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintStyle: const TextStyle(color: Color(0xFFA3DCE9)),
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
      textTheme: Typography.whiteMountainView.copyWith(
        titleLarge: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white),
        titleMedium: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
        bodyLarge: const TextStyle(color: Color(0xFFE8F6FF)),
        bodyMedium: const TextStyle(color: Color(0xFFB8D6FB)),
        bodySmall: const TextStyle(color: Color(0xFF94B9E9)),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF007AAD),
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    final colorScheme = const ColorScheme.light(
      primary: Color(0xFF21ACE6),
      onPrimary: Colors.white,
      secondary: Color(0xFF2A8AA6),
      onSecondary: Colors.white,
      surface: Color(0xFFF2F9FF),
      onSurface: Color(0xFF0F3852),
      surfaceContainerHighest: Color(0xFFD6E7F4),
      outline: Color(0xFF80B8D6),
      error: Color(0xFFB00020),
      onError: Colors.white,
      inverseSurface: Color(0xFF0A304B),
      inversePrimary: Color(0xFF21ACE6),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        surfaceTintColor: Colors.transparent,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurface);
        }),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: colorScheme.onSecondary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintStyle: TextStyle(color: colorScheme.onSurface.withAlpha((0.7 * 255).round())),
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface.withAlpha((0.9 * 255).round())),
      textTheme: Typography.blackMountainView.copyWith(
        titleLarge: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF102A43)),
        titleMedium: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF102A43)),
        bodyLarge: TextStyle(color: colorScheme.onSurface),
        bodyMedium: TextStyle(color: colorScheme.onSurface.withAlpha((0.8 * 255).round())),
        bodySmall: TextStyle(color: colorScheme.onSurface.withAlpha((0.7 * 255).round())),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.primary,
        contentTextStyle: TextStyle(color: colorScheme.onPrimary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().themeMode;

    return MaterialApp(
      title: 'SaveBuddy',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}
