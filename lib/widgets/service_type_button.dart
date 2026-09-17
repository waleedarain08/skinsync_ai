import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import 'app_network_image.dart';
import 'sticky_tooltip.dart';

class ServiceTypeButton extends StatelessWidget {
  final String? icon;
  final String text;
  final bool selected;
  final VoidCallback? onPressed;
  final String? imageUrl;
  final String? description;
  final String? highLightedArea;
  final String? infoImageUrl;

  const ServiceTypeButton({
    super.key,
    this.icon,
    this.text = "",
    this.selected = false,
    this.onPressed,
    this.imageUrl,
    this.description,
    this.highLightedArea,
    this.infoImageUrl,
  });

  String? get _effectiveTooltipImage {
    if (infoImageUrl != null && infoImageUrl!.trim().isNotEmpty) {
      return infoImageUrl!.trim();
    }
    if (highLightedArea != null && highLightedArea!.trim().isNotEmpty) {
      return highLightedArea!.trim();
    }
    return null;
  }

  String? get _effectiveDescription {
    if (description != null && description!.trim().isNotEmpty) {
      return description!.trim();
    }
    return null;
  }

  Widget _buildLeftIcon(BuildContext context, String iconPath, bool selected) {
    if (iconPath.startsWith('http://') || iconPath.startsWith('https://')) {
      return AppNetworkImage(
        imageUrl: iconPath,
        width: context.w(26),
        height: context.w(26),
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(context.r(6)),
        errorIcon: Icons.broken_image,
      );
    } else {
      return Image.asset(
        iconPath,
        width: context.w(22),
        height: context.w(22),
        color: selected ? Colors.white : Colors.black,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final String? imgUrl = _effectiveTooltipImage;
    final String? desc = _effectiveDescription;
    final bool hasTooltip = imgUrl != null || desc != null;
    return GestureDetector(
      onTap: onPressed,
      onLongPress: hasTooltip
          ? () {
              showStickyTooltip(
                context: context,
                title: text,
                description: desc,
                imageUrl: imgUrl,
              );
            }
          : null,
      child: Container(
        height: context.h(50),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(
            color: selected ? CustomColors.purpleColor : Colors.black,
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? CustomColors.purpleColor.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.015),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.r(14)),
          child: Stack(
            children: [
              if (hasImage)
                Positioned.fill(
                  child: AppNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholderColor: Colors.transparent,
                  ),
                ),
              Positioned.fill(
                child: Container(
                  color: selected
                      ? Colors.black.withValues(alpha: 0.5)
                      : (hasImage
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(16),
                  vertical: context.h(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null && icon!.isNotEmpty &&  icon != "") ...[
                      _buildLeftIcon(context, icon!, selected),
                      SizedBox(width: context.w(8)),
                    ],
                    Text(
                      text,
                      style: CustomFonts.black13w600.copyWith(
                        color: selected ? Colors.white : Colors.black,
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
}
