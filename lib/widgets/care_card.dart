import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';

class CareCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData icon;
  final IconData? bgIcon;
  final Gradient? gradient;
  final VoidCallback onTap;
  final Widget? trailing;
  final Widget? body;
  final Widget? titleAction;
  final bool showDefaultArrow;
  final bool isLarge;
  final bool isWide;
  final double? bgIconSize;

  const CareCard({
    super.key,
    this.title,
    this.subtitle,
    required this.icon,
    this.bgIcon,
    this.gradient,
    required this.onTap,
    this.trailing,
    this.body,
    this.titleAction,
    this.showDefaultArrow = true,
    this.isLarge = false,
    this.isWide = false,
    this.bgIconSize,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgIcon = bgIcon ?? icon;
    final effectiveGradient = gradient ?? CustomColors.purpleBlueGradient;

    Widget? effectiveTrailing = trailing;
    if (effectiveTrailing == null && showDefaultArrow) {
      effectiveTrailing = Icon(
        Icons.arrow_outward_rounded,
        size: context.sp(18),
        color: Colors.black45,
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.r(28)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(context.r(28)),
            child: Stack(
              children: [
                // Gradient Background
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: effectiveGradient,
                    ),
                  ),
                ),

                // Decorative Watermark Icon
                Positioned(
                  right: isWide
                      ? context.w(10)
                      : (isLarge ? -context.w(10) : -context.w(20)),
                  bottom: isWide
                      ? -context.h(10)
                      : (isLarge ? -context.h(20) : -context.h(10)),
                  child: Opacity(
                    opacity: 0.12,
                    child: Icon(
                      effectiveBgIcon,
                      size: bgIconSize ??
                          (isWide
                              ? context.h(100)
                              : (isLarge ? context.h(150) : context.h(120))),
                      color: Colors.black,
                    ),
                  ),
                ),

                // Main Content
                Padding(
                  padding: EdgeInsets.all(context.w(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row (Circular Icon + Trailing widget)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(context.w(10)),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: Colors.black87,
                              size: context.sp(22),
                            ),
                          ),
                          if (effectiveTrailing != null) effectiveTrailing,
                        ],
                      ),

                      if (body != null) ...[
                        const Spacer(),
                        body!,
                      ] else ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title ?? '',
                                    style: CustomFonts.black18w600.copyWith(
                                      fontSize: isLarge
                                          ? context.sp(22)
                                          : (isWide
                                              ? context.sp(19)
                                              : context.sp(17)),
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                if (titleAction != null) titleAction!,
                              ],
                            ),
                            if (subtitle != null) ...[
                              SizedBox(height: context.h(6)),
                              SizedBox(
                                width: isWide ? context.w(220) : null,
                                child: Text(
                                  subtitle!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: CustomFonts.black14w400.copyWith(
                                    color:
                                        Colors.black87.withValues(alpha: 0.7),
                                    fontSize: isLarge
                                        ? context.sp(14)
                                        : context.sp(12),
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
