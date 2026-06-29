import 'package:flutter/material.dart';
import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';
import 'package:studyverse/features/legal/data/legal_documents.dart';

/// Displays a legal document (Terms of Service or Privacy Policy).
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key, required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(document.title),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingPageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(document.title, style: AppTextStyles.headlineSmall),
              const SizedBox(height: AppSizes.spaceXs),
              Text(
                '시행일: ${document.effectiveDate}',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSizes.spaceXl),
              ...document.sections.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.spaceXl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.heading, style: AppTextStyles.titleMedium),
                      const SizedBox(height: AppSizes.spaceSm),
                      Text(
                        s.body,
                        style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.space3xl),
            ],
          ),
        ),
      ),
    );
  }
}
