// tabs/design_tokens.dart
import 'package:flutter/material.dart';

class DesignTokens {
  // Colors
  static const surface = Color(0xFFFFFFFF);
  static const bg = Color(0xFFF8F9FA);
  static const textPrimary = Color(0xFF2D3748);
  static const textSecondary = Color(0xFF718096);
  static const muted = Color(0xFFA0AEC0);
  static const border = Color(0xFFE2E8F0);
  static const brand = Color(0xFF3182CE);
  static const accent = Color(0xFF805AD5);
  static const info = Color(0xFF3182CE);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);

  // Card decoration
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: border),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 12,
        spreadRadius: 1,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
