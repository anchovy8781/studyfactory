import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

/// StudyVerse dark theme — Material 3 based.
final class DarkTheme {
  const DarkTheme._();

  static final ColorScheme _colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
    primary: AppColors.primaryLight,
    onPrimary: AppColors.primaryDark,
    primaryContainer: AppColors.primaryDark,
    onPrimaryContainer: AppColors.primaryLight,
    secondary: AppColors.accent,
    onSecondary: AppColors.textOnPrimary,
    secondaryContainer: AppColors.accentDark,
    onSecondaryContainer: AppColors.accentLight,
    error: Color(0xFFCF6679),
    onError: Color(0xFF690000),
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    outline: AppColors.borderDark,
    outlineVariant: AppColors.dividerDark,
    background: AppColors.backgroundDark,
    onBackground: AppColors.textPrimaryDark,
  );

  static final TextTheme _textTheme = TextTheme(
    displayLarge: AppTextStyles.displayLarge.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    displayMedium: AppTextStyles.displayMedium.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    displaySmall: AppTextStyles.displaySmall.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    headlineLarge: AppTextStyles.headlineLarge.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    headlineMedium: AppTextStyles.headlineMedium.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    headlineSmall: AppTextStyles.headlineSmall.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    titleLarge: AppTextStyles.titleLarge.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    titleMedium: AppTextStyles.titleMedium.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    titleSmall: AppTextStyles.titleSmall.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    labelLarge: AppTextStyles.labelLarge.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    labelMedium: AppTextStyles.labelMedium.copyWith(
      color: AppColors.textSecondaryDark,
    ),
    labelSmall: AppTextStyles.labelSmall.copyWith(
      color: AppColors.textSecondaryDark,
    ),
    bodyLarge: AppTextStyles.bodyLarge.copyWith(
      color: AppColors.textPrimaryDark,
    ),
    bodyMedium: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.textSecondaryDark,
    ),
    bodySmall: AppTextStyles.bodySmall.copyWith(
      color: AppColors.textSecondaryDark,
    ),
  );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: _colorScheme,
        textTheme: _textTheme,
        fontFamily: 'Pretendard',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        canvasColor: AppColors.backgroundDark,

        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundDark,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          titleTextStyle: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimaryDark,
          ),
          iconTheme: const IconThemeData(
            color: AppColors.textPrimaryDark,
            size: AppSizes.iconLg,
          ),
          actionsIconTheme: const IconThemeData(
            color: AppColors.textPrimaryDark,
            size: AppSizes.iconLg,
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),

        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surfaceDark,
          indicatorColor: AppColors.primaryDark,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(
                color: AppColors.primaryLight,
                size: AppSizes.iconLg,
              );
            }
            return const IconThemeData(
              color: AppColors.textHintDark,
              size: AppSizes.iconLg,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppTextStyles.navLabelSelected.copyWith(
                color: AppColors.primaryLight,
              );
            }
            return AppTextStyles.navLabel.copyWith(
              color: AppColors.textHintDark,
            );
          }),
          height: AppSizes.bottomNavHeight,
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          color: AppColors.surfaceDark,
          elevation: AppSizes.cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            side: const BorderSide(color: AppColors.borderDark),
          ),
          margin: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight,
            foregroundColor: AppColors.primaryDark,
            disabledBackgroundColor: AppColors.borderDark,
            disabledForegroundColor: AppColors.textHintDark,
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
            textStyle: AppTextStyles.button.copyWith(
              color: AppColors.primaryDark,
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceVariantDark,
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
              color: AppColors.primaryLight,
              width: AppSizes.borderWidthLg,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            borderSide: const BorderSide(
              color: Color(0xFFCF6679),
              width: AppSizes.borderWidthLg,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            borderSide: const BorderSide(
              color: Color(0xFFCF6679),
              width: AppSizes.borderWidthLg,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.spaceLg,
            vertical: AppSizes.spaceMd,
          ),
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textHintDark,
          ),
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondaryDark,
          ),
          floatingLabelStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primaryLight,
          ),
          prefixIconColor: AppColors.textSecondaryDark,
          suffixIconColor: AppColors.textSecondaryDark,
          constraints: const BoxConstraints(minHeight: AppSizes.inputHeight),
        ),

        dividerTheme: const DividerThemeData(
          color: AppColors.dividerDark,
          thickness: AppSizes.borderWidth,
          space: 0,
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.surfaceElevatedDark,
          contentTextStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimaryDark,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          behavior: SnackBarBehavior.floating,
          elevation: 4,
        ),

        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.surfaceDark,
          modalBackgroundColor: AppColors.surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSizes.radiusXxl),
            ),
          ),
          clipBehavior: Clip.antiAlias,
        ),

        iconTheme: const IconThemeData(
          color: AppColors.textSecondaryDark,
          size: AppSizes.iconLg,
        ),

        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primaryLight,
          linearTrackColor: AppColors.borderDark,
          circularTrackColor: AppColors.borderDark,
        ),

        listTileTheme: ListTileThemeData(
          tileColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingPageHorizontal,
            vertical: AppSizes.spaceXs,
          ),
          minLeadingWidth: AppSizes.iconLg,
          iconColor: AppColors.textSecondaryDark,
          titleTextStyle: AppTextStyles.titleSmall.copyWith(
            color: AppColors.textPrimaryDark,
          ),
          subtitleTextStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondaryDark,
          ),
        ),

        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.textOnPrimary;
            }
            return AppColors.textHintDark;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryLight;
            }
            return AppColors.borderDark;
          }),
        ),
      );
}
