import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1D4ED8);
  static const primaryDark = Color(0xFF1E3A8A);
  static const background = Color(0xFFF8FAFC);
  static const inputFill = Color(0xFFF1F5F9);
  static const border = Color(0xFFE2E8F0);
  static const textStrong = Color(0xFF0F172A);
  static const text = Color(0xFF1E293B);
  static const textMuted = Color(0xFF64748B);
  static const textSoft = Color(0xFF94A3B8);
  static const success = Color(0xFF16A34A);
  static const successSoft = Color(0xFFDCFCE7);
  static const danger = Color(0xFFDC2626);
  static const dangerSoft = Color(0xFFFEE2E2);
  static const warning = Color(0xFFD97706);
  static const warningSoft = Color(0xFFFEF3C7);
  static const primarySoft = Color(0xFFDBEAFE);

  static InputDecoration input(String hint, IconData icon, {String? label}) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      hintStyle: const TextStyle(color: textSoft, fontSize: 14),
      prefixIcon: Icon(icon, color: textMuted, size: 20),
      filled: true,
      fillColor: inputFill,
      counterText: '',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    );
  }

  static ButtonStyle primaryButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      minimumSize: const Size.fromHeight(50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  static BoxDecoration card() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: border),
    );
  }
}
