import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - ألوان أكثر وضوحاً
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);

  // Background
  static const Color background = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;

  // Glass Effect
  static Color glassBackground = Colors.white.withOpacity(0.9);
  static Color glassBorder = Colors.white.withOpacity(0.5);

  // Status Colors - ألوان واضحة
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color pending = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Colors.white;

  // Bubble Background Colors
  static const List<Color> bubbleColors = [
    Color(0xFF2196F3),
    Color(0xFF64B5F6),
    Color(0xFF90CAF9),
    Color(0xFFBBDEFB),
  ];
}