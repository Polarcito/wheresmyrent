import 'package:flutter/material.dart';

class AppColors {
  // Colores claros
  static const Color primary = Color(0xFF2563EB);       // Azul principal
  static const Color secondary = Color(0xFF3B82F6);     // Un azul intermedio
  static const Color background = Color(0xFFF9FAFB);    // Fondo claro
  static const Color surface = Color(0xFFFFFFFF);       // Cartas, diálogos
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Colors.black87;
  static const Color onSurface = Colors.black87;

  // Colores oscuros
  static const Color primaryDark = Color(0xFF60A5FA);   // Azul más suave
  static const Color secondaryDark = Color(0xFFFCD34D); // Amarillo claro
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color onPrimaryDark = Colors.black;
  static const Color onSecondaryDark = Colors.black;
  static const Color onBackgroundDark = Colors.white70;
  static const Color onSurfaceDark = Colors.white70;
}

class AppColorScheme {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    error: Colors.red,
    onError: Colors.white,
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryDark,
    onPrimary: AppColors.onPrimaryDark,
    secondary: AppColors.secondaryDark,
    onSecondary: AppColors.onSecondaryDark,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.onSurfaceDark,
    error: Colors.red,
    onError: Colors.white,
  );
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColorScheme.light,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      titleTextStyle: TextStyle(
        color: AppColors.onPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: AppColors.surface,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: const CardTheme(
      color: AppColors.surface,
      margin: EdgeInsets.all(8),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: AppColors.onPrimary,
      unselectedLabelColor: AppColors.onPrimary.withOpacity(0.6),
      indicatorColor: AppColors.onPrimary,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.primary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.4), // borde sutil azul
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      hintStyle: TextStyle(color: AppColors.primary),
      labelStyle: TextStyle(color: AppColors.primary.withValues(alpha: 0.4)),
      floatingLabelStyle: TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
    )
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: AppColorScheme.dark,
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: AppColors.onPrimaryDark,
      titleTextStyle: TextStyle(
        color: AppColors.onPrimaryDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    dialogTheme: const DialogTheme(
      backgroundColor: AppColors.surfaceDark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: AppColors.onPrimaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    cardTheme: const CardTheme(
      color: AppColors.surfaceDark,
      margin: EdgeInsets.all(8),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryDark,
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    tabBarTheme: TabBarTheme(
      labelColor: AppColors.onPrimaryDark,
      unselectedLabelColor: AppColors.onPrimaryDark.withOpacity(0.6),
      indicatorColor: AppColors.onPrimaryDark,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.primaryDark),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primaryDark.withValues(alpha: 0.4), // borde sutil azul
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primaryDark,
          width: 2,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primaryDark.withValues(alpha: 0.4),
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primaryDark.withValues(alpha: 0.4),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primaryDark,
          width: 2,
        ),
      ),
      hintStyle: TextStyle(color: AppColors.primaryDark),
      labelStyle: TextStyle(color: AppColors.primaryDark.withValues(alpha: 0.4)),
      floatingLabelStyle: TextStyle(
        color: AppColors.primaryDark,
        fontWeight: FontWeight.w600,
      ),
    )
  );
}
