import 'package:flutter/material.dart';

import 'package:studyverse/core/constants/app_colors.dart';
import 'package:studyverse/core/constants/app_sizes.dart';
import 'package:studyverse/core/constants/app_strings.dart';
import 'package:studyverse/core/constants/app_text_styles.dart';

/// Bottom navigation item definition.
final class _NavItem {
  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.isCenter = false,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isCenter;
}

/// Custom bottom navigation bar matching StudyVerse design.
/// The center tab (공부) has a special elevated circular treatment.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItem> _items = [
    _NavItem(
      label: AppStrings.navHome,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _NavItem(
      label: AppStrings.navStatistics,
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart_rounded,
    ),
    _NavItem(
      label: AppStrings.navStudy,
      icon: Icons.school_outlined,
      selectedIcon: Icons.school_rounded,
      isCenter: true,
    ),
    _NavItem(
      label: AppStrings.navCommunity,
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_rounded,
    ),
    _NavItem(
      label: AppStrings.navMyPage,
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Container(
      height: AppSizes.bottomNavHeight +
          MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(
            _items.length,
            (i) => Expanded(
              child: _NavTile(
                item: _items[i],
                index: i,
                isSelected: currentIndex == i,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTile extends StatefulWidget {
  const _NavTile({
    required this.item,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  final _NavItem item;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    if (widget.isSelected) _controller.value = 1;
  }

  @override
  void didUpdateWidget(_NavTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward(from: 0);
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.isCenter) {
      return _buildCenterTab();
    }
    return _buildRegularTab();
  }

  Widget _buildCenterTab() {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: AppSizes.icon4xl,
              height: AppSizes.icon4xl,
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? AppColors.primaryGradient
                    : const LinearGradient(
                        colors: [Color(0xFF9CA3AF), Color(0xFF6B7280)],
                      ),
                shape: BoxShape.circle,
                boxShadow: widget.isSelected
                    ? AppColors.primaryShadow
                    : null,
              ),
              child: Icon(
                widget.isSelected
                    ? widget.item.selectedIcon
                    : widget.item.icon,
                color: Colors.white,
                size: AppSizes.iconLg,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceXxs),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: widget.isSelected
                ? AppTextStyles.navLabelSelected
                : AppTextStyles.navLabel.copyWith(
                    color: AppColors.textHint,
                  ),
            child: Text(widget.item.label),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularTab() {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: AppSizes.iconXxl + AppSizes.spaceXs * 2,
              height: AppSizes.iconXxl + AppSizes.spaceXxs * 2,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? AppColors.primaryContainer
                    : Colors.transparent,
                borderRadius:
                    BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Icon(
                widget.isSelected
                    ? widget.item.selectedIcon
                    : widget.item.icon,
                color: widget.isSelected
                    ? AppColors.primary
                    : AppColors.textHint,
                size: AppSizes.iconLg,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceXxs),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: widget.isSelected
                ? AppTextStyles.navLabelSelected
                : AppTextStyles.navLabel.copyWith(
                    color: AppColors.textHint,
                  ),
            child: Text(widget.item.label),
          ),
        ],
      ),
    );
  }
}
