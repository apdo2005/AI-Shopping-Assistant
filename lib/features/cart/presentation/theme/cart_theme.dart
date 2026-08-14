import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the Cart & Checkout flow only. Kept local to this
/// feature (instead of touching the shared `AppColors`) so the premium
/// restyle here can't ripple into unrelated screens.
class CartTheme {
  CartTheme._();

  static const background = Color(0xFFF8F6FD);
  static const surface = Colors.white;
  static const border = Color(0xFFECE7F7);
  static const stepperBg = Color(0xFFF4F1FB);
  static const textPrimary = Color(0xFF1E1B2E);
  static const textSecondary = Color(0xFF8E8AA3);
  static const textMuted = Color(0xFFB4AFC8);
  static const success = Color(0xFF16A34A);
  static const danger = Color(0xFFEF4444);

  static const primary = Color(0xFF6C4FF6);
  static const primaryDark = Color(0xFF5B3EE8);

  static const primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7C5CFC), primaryDark],
  );

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF6F3FD), Color(0xFFFBFAFE)],
  );

  static TextStyle font({
    double size = 13,
    FontWeight weight = FontWeight.w500,
    Color color = textPrimary,
    double? height,
  }) => GoogleFonts.poppins(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );

  static final cardDecoration = BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: border),
    boxShadow: const [
      BoxShadow(color: Color(0x0F6C4FF6), blurRadius: 18, offset: Offset(0, 8)),
    ],
  );
}
