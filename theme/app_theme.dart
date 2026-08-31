import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemoryLensColors extends ThemeExtension<MemoryLensColors> {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceSecondary;
  final Color primary;
  final Color primaryContainer;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color icon;
  final Color success;
  final Color warning;
  final Color error;

  const MemoryLensColors({
    required this.background, required this.surface, required this.surfaceElevated,
    required this.surfaceSecondary, required this.primary, required this.primaryContainer,
    required this.accent, required this.textPrimary, required this.textSecondary,
    required this.border, required this.icon, required this.success,
    required this.warning, required this.error,
  });

  @override
  ThemeExtension<MemoryLensColors> copyWith({
    Color? background, Color? surface, Color? surfaceElevated, Color? surfaceSecondary,
    Color? primary, Color? primaryContainer, Color? accent, Color? textPrimary,
    Color? textSecondary, Color? border, Color? icon, Color? success, Color? warning, Color? error,
  }) => MemoryLensColors(
    background: background ?? this.background, surface: surface ?? this.surface,
    surfaceElevated: surfaceElevated ?? this.surfaceElevated, surfaceSecondary: surfaceSecondary ?? this.surfaceSecondary,
    primary: primary ?? this.primary, primaryContainer: primaryContainer ?? this.primaryContainer,
    accent: accent ?? this.accent, textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary, border: border ?? this.border,
    icon: icon ?? this.icon, success: success ?? this.success,
    warning: warning ?? this.warning, error: error ?? this.error,
  );

  @override
  ThemeExtension<MemoryLensColors> lerp(ThemeExtension<MemoryLensColors>? other, double t) {
    if (other is! MemoryLensColors) return this;
    return MemoryLensColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceSecondary: Color.lerp(surfaceSecondary, other.surfaceSecondary, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryContainer: Color.lerp(primaryContainer, other.primaryContainer, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      icon: Color.lerp(icon, other.icon, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }

  static const light = MemoryLensColors(
    background: Color(0xFFFFF8F3),   surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFFFDFC), surfaceSecondary: Color(0xFFF8E9DF),
    primary: Color(0xFFB9654D),      primaryContainer: Color(0xFFF4D8CC),
    accent: Color(0xFFD98C70),       textPrimary: Color(0xFF302522),
    textSecondary: Color(0xFF806F67), border: Color(0xFFE8D8D0),
    icon: Color(0xFF695850),         success: Color(0xFF66856B),
    warning: Color(0xFFC58A45),      error: Color(0xFFB85C5C),
  );

  static const dark = MemoryLensColors(
    background: Color(0xFF1C1513),   surface: Color(0xFF271D1A),
    surfaceElevated: Color(0xFF30221E), surfaceSecondary: Color(0xFF34241F),
    primary: Color(0xFFE29477),      primaryContainer: Color(0xFF513229),
    accent: Color(0xFFC87559),       textPrimary: Color(0xFFF8EEE9),
    textSecondary: Color(0xFFB5A29A), border: Color(0xFF45332D),
    icon: Color(0xFFC7B4AA),         success: Color(0xFF91B395),
    warning: Color(0xFFD7A465),      error: Color(0xFFDF8585),
  );
}

class AppTheme {
  static ThemeData get lightTheme => _build(MemoryLensColors.light, Brightness.light);
  static ThemeData get darkTheme  => _build(MemoryLensColors.dark,  Brightness.dark);

  static ThemeData _build(MemoryLensColors c, Brightness b) {
    final isLight = b == Brightness.light;
    final base = isLight ? ThemeData.light() : ThemeData.dark();
    final textTheme = GoogleFonts.manropeTextTheme(base.textTheme).copyWith(
      bodyLarge:   GoogleFonts.manrope(color: c.textPrimary, fontSize: 15),
      bodyMedium:  GoogleFonts.manrope(color: c.textPrimary, fontSize: 14),
      bodySmall:   GoogleFonts.manrope(color: c.textSecondary, fontSize: 12),
      titleLarge:  GoogleFonts.manrope(color: c.textPrimary, fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: GoogleFonts.manrope(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall:  GoogleFonts.manrope(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      labelLarge:  GoogleFonts.manrope(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: GoogleFonts.manrope(color: c.textSecondary, fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall:  GoogleFonts.manrope(color: c.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: b,
      scaffoldBackgroundColor: c.background,
      colorScheme: (isLight ? ColorScheme.light : ColorScheme.dark)(
        primary: c.primary, primaryContainer: c.primaryContainer,
        secondary: c.accent, surface: c.surface, error: c.error,
        onPrimary: Colors.white, onSecondary: Colors.white,
        onSurface: c.textPrimary, onError: Colors.white,
      ),
      extensions: [isLight ? MemoryLensColors.light : MemoryLensColors.dark],
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: c.background, elevation: 0, scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: c.icon),
        titleTextStyle: GoogleFonts.manrope(fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
            ? IconThemeData(color: c.primary, size: 24)
            : IconThemeData(color: c.icon, size: 24)),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected)
            ? GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: c.primary)
            : GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w500, color: c.icon)),
      ),
      cardTheme: CardTheme(
        color: c.surface, elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), side: BorderSide(color: c.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: c.surfaceSecondary,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c.primary, width: 1.5)),
        hintStyle: GoogleFonts.manrope(color: c.textSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceSecondary,
        side: BorderSide(color: c.border),
        labelStyle: GoogleFonts.manrope(color: c.textPrimary, fontSize: 12),
      ),
      iconTheme: IconThemeData(color: c.icon),
      dividerColor: c.border,
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: c.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.manrope(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        contentTextStyle: GoogleFonts.manrope(color: c.textSecondary, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.surfaceElevated,
        contentTextStyle: GoogleFonts.manrope(color: c.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static Color getCategorySurface(String category, bool isDark) {
    if (isDark) {
      switch (category.toLowerCase()) {
        case 'event': return const Color(0xFF3F2D40);
        case 'receipt': return const Color(0xFF3D2723);
        case 'notice': return const Color(0xFF42331C);
        case 'personal': return const Color(0xFF402B34);
        case 'opportunity': return const Color(0xFF28362B);
        case 'document': return const Color(0xFF23303D);
        default: return const Color(0xFF322825);
      }
    } else {
      switch (category.toLowerCase()) {
        case 'event': return const Color(0xFFF7F0FA);
        case 'receipt': return const Color(0xFFFCF0EB);
        case 'notice': return const Color(0xFFFDF4E7);
        case 'personal': return const Color(0xFFFAF0F4);
        case 'opportunity': return const Color(0xFFEFF5F1);
        case 'document': return const Color(0xFFEFF3F8);
        default: return const Color(0xFFF8E9DF);
      }
    }
  }

  static Color getCategoryAccent(String category, bool isDark) {
    if (isDark) {
      switch (category.toLowerCase()) {
        case 'event': return const Color(0xFFD6BBE0);
        case 'receipt': return const Color(0xFFEDAFA0);
        case 'notice': return const Color(0xFFE5C18A);
        case 'personal': return const Color(0xFFE0B8CB);
        case 'opportunity': return const Color(0xFFA5C9B0);
        case 'document': return const Color(0xFFA6BED6);
        default: return const Color(0xFFC7B4AA);
      }
    } else {
      switch (category.toLowerCase()) {
        case 'event': return const Color(0xFF8B5A96);
        case 'receipt': return const Color(0xFFB9654D);
        case 'notice': return const Color(0xFFB57A2A);
        case 'personal': return const Color(0xFF9E5474);
        case 'opportunity': return const Color(0xFF4A7D5B);
        case 'document': return const Color(0xFF4E6B8A);
        default: return const Color(0xFF806F67);
      }
    }
  }
}

extension ThemeContextExtension on BuildContext {
  MemoryLensColors get mlColors => Theme.of(this).extension<MemoryLensColors>()!;
}
