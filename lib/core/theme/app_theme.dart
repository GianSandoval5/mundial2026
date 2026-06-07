import 'package:flutter/material.dart';

class MundialitoColors {
  static const pitch = Color(0xFF0C1207);
  static const deepOlive = Color(0xFF1A2412);
  static const olive = Color(0xFF4D5741);
  static const panel = Color(0xFF171A14);
  static const panelSoft = Color(0xFF23271F);
  static const lime = Color(0xFFA6FF00);
  static const limeSoft = Color(0xFFD7FF73);
  static const smoke = Color(0xFFECEFE4);
  static const muted = Color(0xFF9EA794);
  static const danger = Color(0xFFFF365E);
}

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: MundialitoColors.lime,
        secondary: MundialitoColors.limeSoft,
        surface: MundialitoColors.panel,
        onSurface: MundialitoColors.smoke,
        error: MundialitoColors.danger,
      ),
      scaffoldBackgroundColor: MundialitoColors.pitch,
      textTheme: base.textTheme.apply(
        bodyColor: MundialitoColors.smoke,
        displayColor: MundialitoColors.smoke,
        fontFamily: 'Roboto',
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: MundialitoColors.smoke,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: MundialitoColors.panelSoft,
        contentTextStyle: TextStyle(color: MundialitoColors.smoke),
      ),
    );
  }
}
