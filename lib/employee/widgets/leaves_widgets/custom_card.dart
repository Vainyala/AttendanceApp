import 'package:AttendanceApp/employee/utils/app_colors.dart';
import 'package:flutter/material.dart';
import '../../utils/app_dimensions.dart';
import '../../utils/app_styles.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final bool showShadow;
  final Border? border;
  final BorderRadius? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.showShadow = true,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(AppDimensions.marginLarge),
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingXLarge),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackground,
        borderRadius: borderRadius ?? AppStyles.radiusLarge,
        border: border,
        boxShadow: showShadow ? AppStyles.cardShadowMedium : null,
      ),
      child: child,
    );
  }
}

class CustomFormCard extends StatelessWidget {
  final Widget child;
  final bool isHighlighted;
  final GlobalKey? formKey;

  const CustomFormCard({
    super.key,
    required this.child,
    this.isHighlighted = false,
    this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: formKey,
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.marginLarge),
      padding: const EdgeInsets.all(AppDimensions.paddingXLarge),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppStyles.radiusLarge,
        boxShadow: AppStyles.cardShadowMedium,
        border: isHighlighted
            ? Border.all(
          color: AppColors.primaryBlue,
          width: AppDimensions.borderMedium,
        )
            : null,
      ),
      child: child,
    );
  }
}

class InfoBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? color;

  const InfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bannerColor = color ?? AppColors.primaryBlue;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.marginMedium),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.1),
        borderRadius: AppStyles.radiusMedium,
      ),
      child: Row(
        children: [
          Icon(icon, color: bannerColor, size: AppDimensions.iconMedium),
          const SizedBox(width: AppDimensions.paddingSmall),
          Expanded(
            child: Text(
              message,
              style: AppStyles.labelSmall.copyWith(color: bannerColor),
            ),
          ),
        ],
      ),
    );
  }
}