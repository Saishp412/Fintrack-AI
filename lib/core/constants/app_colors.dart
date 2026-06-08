import 'package:flutter/material.dart';

class AppColors {
  // Luxury Finance App Theme
  static const Color background = Color(0xFF020617);
  static const Color surface = Color(0xFF111827);
  
  static const Color primary = Color(0xFF0EA5E9); 
  static const Color secondary = Color(0xFF14B8A6); // Accent Teal
  
  // Semantic Colors
  static const Color success = Color(0xFF14B8A6); // Using Accent Teal for success for a cohesive look
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF59E0B); // Amber
  
  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8); // Slate 400
  
  // Custom Gradients
  static const LinearGradient cosmicGradient = LinearGradient(
    colors: [Color(0xFF020617), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF14B8A6)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
