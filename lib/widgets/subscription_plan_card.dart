import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../models/responses/patient_plans_response.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/date_time_utils.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final Plan plan;
  final bool isSelected;
  final bool isActive;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    this.isActive = false,
    required this.onTap,
    this.width,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin ?? EdgeInsets.only(bottom: context.h(16)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.r(24)),
          color: (isSelected || isActive) ? null : Colors.white,
          gradient: (isSelected || isActive)
              ? CustomColors.purpleBlueGradient
              : null,
          border: Border.all(
            color: (isSelected || isActive)
                ? Colors.transparent
                : CustomColors.greyColor.withValues(alpha: 0.3),
            width: (isSelected || isActive) ? 2 : 1,
          ),
          boxShadow: (isSelected || isActive)
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ]
              : CustomColors.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.r(24)),
          child: Stack(
            children: [
              // Decorative Circles (Larger and more prominent)
              Positioned(
                bottom: -context.h(50),
                right: -context.w(40),
                child: Container(
                  height: context.h(160),
                  width: context.h(160),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isSelected || isActive)
                        ? Colors.white.withValues(alpha: 0.18)
                        : CustomColors.purpleColor.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -context.h(20),
                left: -context.w(30),
                child: Container(
                  height: context.h(100),
                  width: context.h(100),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isSelected || isActive)
                        ? Colors.white.withValues(alpha: 0.12)
                        : CustomColors.lightPurpleColor.withValues(alpha: 0.06),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(context.w(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plan.name ?? '',
                          style: CustomFonts.black20w600.copyWith(
                            color: (isSelected || isActive)
                                ? CustomColors.blackColor
                                : CustomColors.silverColor,
                          ),
                        ),
                        if (isActive)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(12),
                              vertical: context.h(4),
                            ),
                            decoration: BoxDecoration(
                              color: (isSelected || isActive)
                                  ? CustomColors.blackColor.withValues(
                                      alpha: 0.1,
                                    )
                                  : CustomColors.silverColor.withValues(
                                      alpha: 0.05,
                                    ),
                              borderRadius: BorderRadius.circular(
                                context.r(20),
                              ),
                              border: Border.all(
                                color: (isSelected || isActive)
                                    ? CustomColors.blackColor
                                    : CustomColors.silverColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              "Active",
                              style: CustomFonts.white12w600.copyWith(
                                color: (isSelected || isActive)
                                    ? CustomColors.blackColor
                                    : CustomColors.silverColor,
                                fontSize: context.sp(10),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: context.h(8)),
                    Text(
                      _getPriceText(plan),
                      style: CustomFonts.black18w400.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: context.sp(14),
                        color: (isSelected || isActive)
                            ? CustomColors.blackColor
                            : CustomColors.silverColor,
                      ),
                    ),
                    SizedBox(height: context.h(16)),
                    _buildBenefitItem(
                      context,
                      (plan.unlimitedSimulation ?? false)
                          ? "Unlimited AI Simulations"
                          : "${plan.simulationCount ?? 0} AI Simulations",
                      color: (isSelected || isActive)
                          ? CustomColors.blackColor
                          : CustomColors.silverColor,
                    ),
                    _buildBenefitItem(
                      context,
                      (plan.unlimitedPostsView ?? false)
                          ? "Unlimited Posts View"
                          : "${plan.postsViewCount ?? 0} Posts View",
                      color: (isSelected || isActive)
                          ? CustomColors.blackColor
                          : CustomColors.silverColor,
                    ),
                    if (plan.benefits != null)
                      ...plan.benefits!.map(
                        (benefit) => _buildBenefitItem(
                          context,
                          benefit.title ?? '',
                          color: (isSelected || isActive)
                              ? CustomColors.blackColor
                              : CustomColors.silverColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPriceText(Plan plan) {
    if (plan.isLifetime == true) {
      return "\$${plan.basePrice} (Lifetime)";
    }
    if (plan.durationOptions == null || plan.durationOptions!.isEmpty) {
      return plan.basePrice == 0 || plan.basePrice == null
          ? "Free"
          : "\$${plan.basePrice}";
    }
    return plan.durationOptions!
        .map((opt) => "\$${opt.amount}/${opt.interval?.label ?? ''}")
        .join(" | ");
  }

  Widget _buildBenefitItem(BuildContext context, String title, {Color? color}) {
    if (title.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: context.h(2)),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: context.sp(16),
              color: color ?? CustomColors.darkPurple,
            ),
          ),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Text(
              title,
              style: CustomFonts.black14w400.copyWith(
                color: color,
                fontSize: context.sp(13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  final CurrentPlan plan;
  final bool isSelected;
  final bool isActive;
  final VoidCallback onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;

  const SubscriptionCard({
    super.key,
    required this.plan,
    required this.isSelected,
    this.isActive = false,
    required this.onTap,
    this.width,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: margin ?? EdgeInsets.only(bottom: context.h(16)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.r(24)),
          color: (isSelected || isActive) ? null : Colors.white,
          gradient: (isSelected || isActive)
              ? CustomColors.purpleBlueGradient
              : null,
          border: Border.all(
            color: (isSelected || isActive)
                ? Colors.transparent
                : CustomColors.greyColor.withValues(alpha: 0.3),
            width: (isSelected || isActive) ? 2 : 1,
          ),
          boxShadow: (isSelected || isActive)
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ]
              : CustomColors.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.r(24)),
          child: Stack(
            children: [
              // Decorative Circles (Larger and more prominent)
              Positioned(
                bottom: -context.h(50),
                right: -context.w(40),
                child: Container(
                  height: context.h(160),
                  width: context.h(160),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isSelected || isActive)
                        ? Colors.white.withValues(alpha: 0.18)
                        : CustomColors.purpleColor.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: -context.h(20),
                left: -context.w(30),
                child: Container(
                  height: context.h(100),
                  width: context.h(100),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (isSelected || isActive)
                        ? Colors.white.withValues(alpha: 0.12)
                        : CustomColors.lightPurpleColor.withValues(alpha: 0.06),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(context.w(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          plan.name ?? '',
                          style: CustomFonts.black20w600.copyWith(
                            color: (isSelected || isActive)
                                ? CustomColors.blackColor
                                : CustomColors.silverColor,
                          ),
                        ),
                        if (isActive)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(12),
                              vertical: context.h(4),
                            ),
                            decoration: BoxDecoration(
                              color: (isSelected || isActive)
                                  ? CustomColors.blackColor.withValues(
                                      alpha: 0.1,
                                    )
                                  : CustomColors.silverColor.withValues(
                                      alpha: 0.05,
                                    ),
                              borderRadius: BorderRadius.circular(
                                context.r(20),
                              ),
                              border: Border.all(
                                color: (isSelected || isActive)
                                    ? CustomColors.blackColor
                                    : CustomColors.silverColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              "Active",
                              style: CustomFonts.white12w600.copyWith(
                                color: (isSelected || isActive)
                                    ? CustomColors.blackColor
                                    : CustomColors.silverColor,
                                fontSize: context.sp(10),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: context.h(8)),
                    Text(
                      _getPriceSubText(plan),
                      style: CustomFonts.black18w400.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: context.sp(14),
                        color: (isSelected || isActive)
                            ? CustomColors.blackColor
                            : CustomColors.silverColor,
                      ),
                    ),
                    SizedBox(height: context.h(16)),
                    _buildBenefitItem(
                      context,
                      (plan.unlimitedSimulation ?? false)
                          ? "Unlimited AI Simulations"
                          : "AI Simulations: ${plan.usedSimulationCount ?? 0} Used / ${plan.simulationCount ?? 0} Total",
                      color: (isSelected || isActive)
                          ? CustomColors.blackColor
                          : CustomColors.silverColor,
                    ),
                    _buildBenefitItem(
                      context,
                      (plan.unlimitedPostsView ?? false)
                          ? "Unlimited Posts View"
                          : "Posts View: ${plan.usedPostCount ?? 0} Used / ${plan.postsViewCount ?? 0} Total",
                      color: (isSelected || isActive)
                          ? CustomColors.blackColor
                          : CustomColors.silverColor,
                    ),
                    if (plan.benefits != null)
                      ...plan.benefits!.map(
                        (benefit) => _buildBenefitItem(
                          context,
                          benefit.title ?? '',
                          color: (isSelected || isActive)
                              ? CustomColors.blackColor
                              : CustomColors.silverColor,
                        ),
                      ),
                    if (_getExpiryText(plan).isNotEmpty) ...[
                      SizedBox(height: context.h(12)),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          _getExpiryText(plan),
                          style: CustomFonts.black14w400.copyWith(
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.w600,
                            color: (isSelected || isActive)
                                ? CustomColors.blackColor.withValues(alpha: 0.7)
                                : CustomColors.silverColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getExpiryText(CurrentPlan plan) {
    final bool isLifetime = plan.isLifetime ?? false;
    if (isLifetime) {
      return "Lifetime";
    }

    if (plan.endDate != null) {
      return "Expires: ${plan.endDate!.formattedDate}";
    }

    return "";
  }

  String _getPriceSubText(CurrentPlan plan) {
    final String formattedPrice = (plan.price == 0 || plan.price == null)
        ? "Free"
        : "\$${plan.price! % 1 == 0 ? plan.price!.toInt() : plan.price}";

    if (plan.isLifetime == true) {
      return formattedPrice == "Free"
          ? "Free (Lifetime)"
          : "$formattedPrice (Lifetime)";
    }

    if (plan.durationName != null && plan.durationName!.isNotEmpty) {
      return formattedPrice == "Free"
          ? "Free / ${plan.durationName}"
          : "$formattedPrice / ${plan.durationName}";
    }

    return formattedPrice;
  }

  Widget _buildBenefitItem(BuildContext context, String title, {Color? color}) {
    if (title.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: context.h(2)),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: context.sp(16),
              color: color ?? CustomColors.darkPurple,
            ),
          ),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Text(
              title,
              style: CustomFonts.black14w400.copyWith(
                color: color,
                fontSize: context.sp(13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
