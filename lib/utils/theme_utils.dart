import 'package:PiliPlus/common/constants.dart';
import 'package:PiliPlus/main.dart';
import 'package:PiliPlus/utils/extension/theme_ext.dart';
import 'package:PiliPlus/utils/storage_pref.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class ThemeUtils {
  static ThemeData getThemeData({
    required ColorScheme colorScheme,
    required bool isDynamic,
    bool isDark = false,
  }) {
    final appFontWeight = Pref.appFontWeight.clamp(
      -1,
      FontWeight.values.length - 1,
    );
    final fontWeight =
        appFontWeight == -1 ? null : FontWeight.values[appFontWeight];
    final textStyle = TextStyle(fontWeight: fontWeight);

    ThemeData themeData = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: fontWeight == null
          ? null
          : TextTheme(
              displayLarge: textStyle,
              displayMedium: textStyle,
              displaySmall: textStyle,
              headlineLarge: textStyle,
              headlineMedium: textStyle,
              headlineSmall: textStyle,
              titleLarge: textStyle,
              titleMedium: textStyle,
              titleSmall: textStyle,
              bodyLarge: textStyle,
              bodyMedium: textStyle,
              bodySmall: textStyle,
              labelLarge: textStyle,
              labelMedium: textStyle,
              labelSmall: textStyle,
            ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        titleTextStyle: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurface,
          fontWeight: fontWeight,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: StyleString.bottomSheetRadius,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        },
      ),
    );

    if (isDark) {
      const bg = Color(0xFF17181A);

      themeData = themeData.copyWith(
        scaffoldBackgroundColor: bg,
        appBarTheme: themeData.appBarTheme.copyWith(
          backgroundColor: bg,
        ),
        dialogTheme: themeData.dialogTheme.copyWith(
          backgroundColor: bg,
        ),
        bottomSheetTheme: themeData.bottomSheetTheme.copyWith(
          backgroundColor: bg,
        ),
        cardTheme: themeData.cardTheme.copyWith(
          color: const Color(0xFF1E1F22),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: bg,
          surfaceTintColor: Colors.transparent,
          indicatorColor:
              themeData.colorScheme.primary.withOpacity(0.18),
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return TextStyle(
                  color: themeData.colorScheme.primary,
                );
              }
              return const TextStyle(
                color: Color(0xFF9E9E9E),
              );
            },
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return IconThemeData(
                  color: themeData.colorScheme.primary,
                );
              }
              return const IconThemeData(
                color: Color(0xFF9E9E9E),
              );
            },
          ),
        ),
        colorScheme: themeData.colorScheme.copyWith(
          surface: bg,
          background: bg,
          surfaceTint: Colors.transparent,
          surfaceContainer: bg,
          surfaceContainerLow: bg,
          surfaceContainerHigh: bg,
          surfaceContainerHighest: bg,
        ),
      );

      if (Pref.darkVideoPage) {
        MyApp.darkThemeData = themeData;
      }
    }

    return themeData;
  }
}
