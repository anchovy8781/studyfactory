import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

/// StudyVerse light theme — Material 3 based.
final class AppTheme {
  const AppTheme._();

  // ── Color scheme (seed-generated) ─────────────────────────────────────────
  static final ColorScheme _colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.textOnPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.accent,
    onSecondary: AppColors.textOnPrimary,
    secondaryContainer: AppColors.accentLight,
    onSecondaryContainer: AppColors.accentDark,
    error: AppColors.error,
    onError: AppColors.textOnPrimary,
    errorContainer: AppColors.errorLight,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.border,
    outlineVariant: AppColors.divider,
    background: AppColors.background,
    onBackground: AppColors.textPrimary,
  );

  // ── Text theme ────────────────────────────────────────────────────────────
  static const TextTheme _textTheme = TextTheme(
    displayLarge: AppTextStyles.displayLarge,
    displayMedium: AppTextStyles.displayMedium,
    displaySmall: AppTextStyles.displaySmall,
    headlineLarge: AppTextStyles.headlineLarge,
    headlineMedium: AppTextStyles.headlineMedium,
    headlineSmall: AppTextStyles.headlineSmall,
    titleLarge: AppTextStyles.titleLarge,
    titleMedium: AppTextStyles.titleMedium,
    titleSmall: AppTextStyles.titleSmall,
    labelLarge: AppTextStyles.labelLarge,
    labelMedium: AppTextStyles.labelMedium,
    labelSmall: AppTextStyles.labelSmall,
    bodyLarge: AppTextStyles.bodyLarge,
    bodyMedium: AppTextStyles.bodyMedium,
    bodySmall: AppTextStyles.bodySmall,
  );

  // ── Main light theme ──────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: _colorScheme,
        textTheme: _textTheme,
        fontFamily: 'Pretendard',
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        canvasColor: AppColors.background,

        // AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.textPrimary,
            size: AppSizes.iconLg,
          ),
          actionsIconTheme: const IconThemeData(
            color: AppColors.textPrimary,
            size: AppSizes.iconLg,
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),

        // BottomNavigationBar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // NavigationBar (Material 3)
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryContainer,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: AppColors.primary,
                size: AppSizes.iconLg,
              );
            }
            return const IconThemeData(
              color: AppColors.textHint,
              size: AppSizes.iconLg,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.navLabelSelected;
            }
            return AppTextStyles.navLabel.copyWith(
              color: AppColors.textHint,
            );
          }),
          height: AppSizes.bottomNavHeight,
          elevation: 0,
        ),

        // Card
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: AppSizes.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            side: const BorderSide(color: AppColors.border),
          ),
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
        ),

        // ElevatedButton
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            disabledBackgroundColor: AppColors.border,
            disabledForegroundColor: AppColors.textDisabled,
            elevation: 0,
            shadowColor: Colors.transparent,
            minimumSize: const Size(
              AppSizes.buttonMinWidth,
              AppSizes.buttonHeightMd,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            textStyle: AppTextStyles.button,
          ),
        ),

        // OutlinedButton
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.textDisabled,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            minimumSize: const Size(
              AppSizes.buttonMinWidth,
              AppSizes.buttonHeightMd,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
          ),
        ),

        // TextButton
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledForegroundColor: AppColors.textDisabled,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            textStyle: AppTextStyles.button.copyWith(color: AppColors.primary),
          ),
        ),

        // FilledButton
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            minimumSize: const Size(
              AppSizes.buttonMinWidth,
              AppSizes.buttonHeightMd,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            textStyle: AppTextStyles.button,
          ),
        ),

        // InputDecoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: AppSizes.borderWidthLg,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: AppSizes.borderWidthLg,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            borderSide: const BorderSide(
              color: AppColors.error,
              width: AppSizes.borderWidthLg,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spaceLg,
            vertical: AppSizes.spaceMd,
          ),
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textHint,
          ),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          floatingLabelStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
          ),
          errorStyle: AppTextStyles.caption.copyWith(
            color: AppColors.error,
          ),
          prefixIconColor: AppColors.textSecondary,
          suffixIconColor: AppColors.textSecondary,
          constraints: const BoxConstraints(minHeight: AppSizes.inputHeight),
        ),

        // Chip
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.surfaceVariant,
          selectedColor: AppColors.primaryContainer,
          disabledColor: AppColors.divider,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          labelStyle: AppTextStyles.labelMedium,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusRound),
          ),
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surface,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXxl),
          ),
          titleTextStyle: AppTextStyles.titleLarge,
          contentTextStyle: AppTextStyles.bodyMedium,
        ),

        // BottomSheet
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surface,
          modalBackgroundColor: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXxl),
            ),
          ),
          clipBehavior: Clip.antiAlias,
        ),

        // Snackbar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.textPrimary,
          contentTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.surface,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 4,
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: AppSizes.borderWidth,
          space: 0,
        ),

        // Switch
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.textOnPrimary;
            }
            return AppColors.textHint;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.border;
          }),
        ),

        // Checkbox
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(AppColors.textOnPrimary),
          side: const BorderSide(color: AppColors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusXs),
          ),
        ),

        // Radio
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.border;
          }),
        ),

        // Slider
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.primary,
          inactiveTrackColor: AppColors.border,
          thumbColor: AppColors.primary,
          overlayColor: Color(0x201A73E8),
        ),

        // Progress indicator
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.border,
          circularTrackColor: AppColors.border,
        ),

        // List tile
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSizes.paddingPageHorizontal,
            vertical: AppSizes.spaceXs,
          ),
          minLeadingWidth: AppSizes.iconLg,
          iconColor: AppColors.textSecondary,
          titleTextStyle: AppTextStyles.titleSmall,
          subtitleTextStyle: AppTextStyles.bodySmall,
        ),

        // Tab bar
        tabBarTheme: TabBarThemeData(
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: AppTextStyles.titleSmall,
          unselectedLabelStyle: AppTextStyles.bodySmall,
          indicatorColor: AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: AppColors.divider,
        ),

        // Floating action button
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
        ),

        // Icon
        iconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: AppSizes.iconLg,
        ),

        // Popup menu
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.surface,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          textStyle: AppTextStyles.bodyMedium,
        ),

        // Tooltip
        tooltipTheme: TooltipThemeData(
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withOpacity(0.9),
            borderRadius: BorderRadius.circular(AppSizes.radiusXs),
          ),
          textStyle: AppTextStyles.caption.copyWith(
            color: AppColors.surface,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
      );
}
