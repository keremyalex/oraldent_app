import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Asegúrate de tenerlo en pubspec.yaml
import 'package:odontologia_app/theme/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.neutral,
        onSurface: AppColors.inverted,
        // Colores adicionales basados en tu imagen
        outline: AppColors.secondary.withValues(alpha: 0.5),
      ),

      // 1. Tipografía: Stitch usa Manrope para títulos y Body, e Inter para Labels
      textTheme: TextTheme(
        displayLarge: GoogleFonts.manrope(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.inverted),
        bodyLarge: GoogleFonts.manrope(fontSize: 16, color: AppColors.inverted),
        labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600), // Para botones
      ),

      // 2. Estilo de Botones (redondeados como en tu captura)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),

      // 3. Estilo del Search Bar / Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEDF2F7), // El gris suave del buscador en tu imagen
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIconColor: AppColors.secondary,
      ),

      // 4. Estilo de Tarjetas (Cards)
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    ); // <-- Aquí faltaba cerrar el ThemeData
  }
}