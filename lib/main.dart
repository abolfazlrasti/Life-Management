import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:live/core/Theme/theme_color.dart';

import 'ui/navigation/navigationBar.dart';
import 'Routes/routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemOverlay);

  runApp(const MyApp());
}

class AppTheme {
  static const double radius = 12;

  static const systemOverlay = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
  );

  static OutlineInputBorder _inputBorder(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static ThemeData get dark {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'inter',
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      dividerColor: AppColors.divider,
      visualDensity: VisualDensity.standard,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        onPrimary: AppColors.onAccent,
        secondary: AppColors.accentSoft,
        onSecondary: AppColors.background,
        error: AppColors.error,
        onError: AppColors.background,
        surface: AppColors.background,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        surfaceTint: Colors.transparent,
        surfaceContainerLowest: AppColors.background,
        surfaceContainerLow: AppColors.backgroundSecondary,
        surfaceContainer: AppColors.surface,
        surfaceContainerHigh: AppColors.surfaceElevated,
        surfaceContainerHighest: AppColors.selected,
        outline: AppColors.selected,
        outlineVariant: AppColors.divider,
      ),

      // لمس: ریپل ظریف و سریع
      splashFactory: InkRipple.splashFactory,
      splashColor: Colors.white.withValues(alpha: 0.06),
      highlightColor: Colors.white.withValues(alpha: 0.04),
      hoverColor: Colors.white.withValues(alpha: 0.04),

      // swipe-back هم تو اندروید
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 52,
        centerTitle: false,
        titleSpacing: 20,
        systemOverlayStyle: systemOverlay,
        titleTextStyle: TextStyle(
          fontFamily: 'inter',
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      iconTheme: const IconThemeData(color: AppColors.textSecondary, size: 24),

      // دکمه‌ها
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: AppColors.surfaceElevated,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: shape,
          textStyle: const TextStyle(
            fontFamily: 'inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: AppColors.surfaceElevated,
          disabledForegroundColor: AppColors.textDisabled,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: shape,
          textStyle: const TextStyle(
            fontFamily: 'inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.divider),
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: shape,
          textStyle: const TextStyle(
            fontFamily: 'inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentSoft,
          minimumSize: const Size(0, 44),
          shape: shape,
          textStyle: const TextStyle(
            fontFamily: 'inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(48, 48),
        ),
      ),

      // ورودی‌ها
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        floatingLabelStyle: const TextStyle(color: AppColors.accentSoft),
        errorStyle: const TextStyle(color: AppColors.error, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: _inputBorder(AppColors.divider),
        enabledBorder: _inputBorder(AppColors.divider),
        focusedBorder: _inputBorder(AppColors.accentSoft, 1.5),
        errorBorder: _inputBorder(AppColors.error),
        focusedErrorBorder: _inputBorder(AppColors.error, 1.5),
        disabledBorder: _inputBorder(AppColors.divider),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.accentSoft,
        selectionColor: AppColors.accent.withValues(alpha: 0.35),
        selectionHandleColor: AppColors.accentSoft,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // سطح‌های شناور
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.divider),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'inter',
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          fontFamily: 'inter',
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.surface,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: AppColors.selected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
        actionTextColor: AppColors.accentSoft,
        elevation: 0,
        contentTextStyle: const TextStyle(
          fontFamily: 'inter',
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: AppColors.divider),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        textStyle: const TextStyle(
          fontFamily: 'inter',
          color: AppColors.textPrimary,
          fontSize: 12,
        ),
      ),

      // اجزای کوچک
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        selectedTileColor: AppColors.selected,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        minVerticalPadding: 10,
        shape: shape,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.accent.withValues(alpha: 0.28),
        side: const BorderSide(color: AppColors.divider),
        labelStyle: const TextStyle(
          fontFamily: 'inter',
          color: AppColors.textPrimary,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.surfaceElevated;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.transparent
              : AppColors.divider;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.surfaceElevated,
        circularTrackColor: AppColors.surfaceElevated,
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.2,
          letterSpacing: -0.6,
        ),
        headlineLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.25,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.3,
          letterSpacing: -0.4,
        ),
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: AppColors.textDisabled,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.dark,
      // اندازه‌ی فونت سیستم محدود می‌شه تا چیدمان نشکنه
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.25,
            ),
          ),
          child: child!,
        );
      },
      initialRoute: Navigationbarview.routeName,
      routes: routes,
    );
  }
}