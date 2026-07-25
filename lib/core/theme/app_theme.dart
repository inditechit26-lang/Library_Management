import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primary = Color(0xFF5650C7);
  static const canvas = Color(0xFFF7F8FC);
  static const ink = Color(0xFF171A2B);
  static const muted = Color(0xFF8E94A7);
  static const outline = Color(0xFFE5E7EF);

  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          surface: Colors.white,
        ).copyWith(
          primary: primary,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: ink,
          outline: outline,
          outlineVariant: const Color(0xFFF0F1F6),
          surfaceContainerLowest: Colors.white,
          surfaceContainerLow: const Color(0xFFFAFAFD),
          surfaceContainer: const Color(0xFFF4F5FA),
        );
    final text = GoogleFonts.manropeTextTheme().apply(
      bodyColor: ink,
      displayColor: ink,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      textTheme: text.copyWith(
        headlineSmall: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -.55,
        ),
        titleLarge: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -.35,
        ),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        bodyMedium: text.bodyMedium?.copyWith(height: 1.42),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      cardTheme: const CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: outline),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleLarge?.copyWith(
          color: ink,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF62687A), size: 22),
        shape: const Border(bottom: BorderSide(color: outline)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEBECF2),
        thickness: 1,
        space: 24,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFBFBFD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        labelStyle: const TextStyle(color: Color(0xFF73798C)),
        hintStyle: const TextStyle(color: Color(0xFFA0A5B4)),
        prefixIconColor: const Color(0xFF8D93A5),
        suffixIconColor: const Color(0xFF777D8F),
        border: _inputBorder(outline),
        enabledBorder: _inputBorder(outline),
        focusedBorder: _inputBorder(primary, width: 1.5),
        errorBorder: _inputBorder(const Color(0xFFD95C66)),
        focusedErrorBorder: _inputBorder(const Color(0xFFD95C66), width: 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          foregroundColor: const Color(0xFF4F5365),
          side: const BorderSide(color: outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFFEFEEFF),
        side: const BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        labelStyle: text.labelMedium?.copyWith(
          color: const Color(0xFF626779),
          fontWeight: FontWeight.w700,
        ),
        checkmarkColor: primary,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: Colors.white,
        modalBarrierColor: Color(0x66171A2B),
        elevation: 0,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _PremiumPageTransitionBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get dark {
    const background = Color(0xFF10131B);
    const surface = Color(0xFF191D28);
    const surfaceLow = Color(0xFF202532);
    const surfaceHigh = Color(0xFF292F3D);
    const onSurface = Color(0xFFF4F6FC);
    const onSurfaceVariant = Color(0xFFC5CAD8);
    const outlineDark = Color(0xFF414858);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: const Color(0xFFB8B1FF),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFFB8B1FF),
          onPrimary: const Color(0xFF201C52),
          primaryContainer: const Color(0xFF373173),
          onPrimaryContainer: const Color(0xFFE7E3FF),
          secondary: const Color(0xFF72DFB3),
          onSecondary: const Color(0xFF063824),
          surface: surface,
          onSurface: onSurface,
          onSurfaceVariant: onSurfaceVariant,
          outline: outlineDark,
          outlineVariant: const Color(0xFF303747),
          surfaceContainerLowest: background,
          surfaceContainerLow: surfaceLow,
          surfaceContainer: surfaceHigh,
          surfaceContainerHighest: const Color(0xFF313849),
        );
    final text = GoogleFonts.manropeTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: onSurface, displayColor: onSurface);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: scheme,
      textTheme: text.copyWith(
        bodyMedium: text.bodyMedium?.copyWith(height: 1.42),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: outlineDark),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: surface,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleLarge?.copyWith(
          color: onSurface,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: onSurfaceVariant),
        shape: const Border(bottom: BorderSide(color: outlineDark)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF303747),
        thickness: 1,
        space: 24,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHigh,
        labelStyle: const TextStyle(color: onSurfaceVariant),
        hintStyle: const TextStyle(color: Color(0xFF9FA7B8)),
        prefixIconColor: onSurfaceVariant,
        suffixIconColor: onSurfaceVariant,
        border: _inputBorder(outlineDark),
        enabledBorder: _inputBorder(outlineDark),
        focusedBorder: _inputBorder(scheme.primary, width: 1.5),
        errorBorder: _inputBorder(const Color(0xFFFFB4AB)),
        focusedErrorBorder: _inputBorder(const Color(0xFFFFB4AB), width: 1.5),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: onSurface,
          side: const BorderSide(color: outlineDark),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: const Color(0xFF373173),
        side: const BorderSide(color: outlineDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        labelStyle: text.labelMedium?.copyWith(
          color: onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
        checkmarkColor: scheme.primary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : const Color(0xFFC5CAD8),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : const Color(0xFF4A5264),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: Color(0x99000000),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _PremiumPageTransitionBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );
}

class _PremiumPageTransitionBuilder extends PageTransitionsBuilder {
  const _PremiumPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curve = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(.025, .015),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      ),
    );
  }
}
