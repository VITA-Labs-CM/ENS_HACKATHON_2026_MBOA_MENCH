import 'package:flutter/material.dart';

/// Palette MBOA MENCH — éducation, technologie, Afrique.
abstract final class AppColors {
  // Couleurs principales
  static const electricBlue = Color(0xFF0066FF);
  static const emeraldGreen = Color(0xFF00C896);
  static const accentOrange = Color(0xFFFF8C42);
  static const errorRed = Color(0xFFE53935);

  // Neutres
  static const white = Color(0xFFFFFFFF);
  static const lightGray = Color(0xFFF5F7FA);
  static const mediumGray = Color(0xFF94A3B8);
  static const darkGray = Color(0xFF64748B);
  static const darkBg = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkCard = Color(0xFF334155);

  // Dégradés
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electricBlue, emeraldGreen],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0066FF), Color(0xFF0052CC)],
  );

  static const warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentOrange, Color(0xFFFF6B35)],
  );
}
