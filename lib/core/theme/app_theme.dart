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
    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF1B1E28),
          outline: const Color(0xFF353947),
          outlineVariant: const Color(0xFF2A2E39),
        );
    final text = GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme);
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF11131A),
      colorScheme: scheme,
      textTheme: text,
      cardTheme: const CardThemeData(
        color: Color(0xFF1B1E28),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF232631),
        border: _inputBorder(const Color(0xFF353947)),
        enabledBorder: _inputBorder(const Color(0xFF353947)),
        focusedBorder: _inputBorder(primary, width: 1.5),
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
