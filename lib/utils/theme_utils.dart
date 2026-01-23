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
      tabBarTheme:
          fontWeight == null ? null : TabBarThemeData(labelStyle: textStyle),
      appBarTheme: AppBarTheme(
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: colorScheme.surface,
        titleTextStyle: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurface,
          fontWeight: fontWeight,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withOpacity(0.12),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(color: colorScheme.onSurface),
        ),
        iconTheme: WidgetStateProperty.all(
          IconThemeData(color: colorScheme.onSurface),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
      ),
      snackBarTheme: SnackBarThemeData(
        actionTextColor: colorScheme.primary,
        backgroundColor: colorScheme.secondaryContainer,
        closeIconColor: colorScheme.secondary,
        contentTextStyle:
            TextStyle(color: colorScheme.onSecondaryContainer),
        elevation: 20,
      ),
      popupMenuTheme: PopupMenuThemeData(
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        year2023: false,
        refreshBackgroundColor: colorScheme.onSecondary,
      ),
      dialogTheme: DialogThemeData(
        titleTextStyle: TextStyle(
          fontSize: 18,
          color: colorScheme.onSurface,
          fontWeight: fontWeight,
        ),
        backgroundColor: colorScheme.surface,
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 420),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: StyleString.bottomSheetRadius,
        ),
      ),
      sliderTheme: const SliderThemeData(year2023: false),
      tooltipTheme: TooltipThemeData(
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[700]!.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
        ),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        selectionHandleColor: colorScheme.primary,
      ),
      switchTheme: const SwitchThemeData(
        thumbIcon: WidgetStateProperty.fromMap(
          {
            WidgetState.selected: Icon(Icons.done),
            WidgetState.any: null,
          },
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        },
      ),
    );

    if (isDark) {
      const darkBg = Color(0xFF17181A);
      themeData = themeData.copyWith(
        scaffoldBackgroundColor: darkBg,
        appBarTheme: themeData.appBarTheme.copyWith(
          backgroundColor: darkBg,
        ),
        cardTheme: themeData.cardTheme.copyWith(
          color: darkBg,
        ),
        dialogTheme: themeData.dialogTheme.copyWith(
          backgroundColor: darkBg,
        ),
        bottomSheetTheme: themeData.bottomSheetTheme.copyWith(
          backgroundColor: darkBg,
        ),
        navigationBarTheme: themeData.navigationBarTheme.copyWith(
          backgroundColor: darkBg,
        ),
        bottomNavigationBarTheme:
            themeData.bottomNavigationBarTheme.copyWith(
          backgroundColor: darkBg,
        ),
        navigationRailTheme:
            themeData.navigationRailTheme.copyWith(
          backgroundColor: darkBg,
        ),
        colorScheme: themeData.colorScheme.copyWith(
          surface: darkBg,
          surfaceTint: Colors.transparent,
          surfaceContainer: darkBg,
          surfaceContainerHigh: darkBg,
          surfaceContainerHighest: darkBg,
          surfaceContainerLow: darkBg,
          surfaceContainerLowest: darkBg,
        ),
      );
      if (Pref.darkVideoPage) {
        MyApp.darkThemeData = themeData;
      }
    }

    return themeData;
  }
}
