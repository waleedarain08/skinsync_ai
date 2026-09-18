import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';

class SummaryTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final Widget? trailing;
  final Gradient? gradient;
  final String? backgroundImage;

  const SummaryTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.trailing,
    this.gradient,
    this.backgroundImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: gradient == null ? Colors.white : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(context.r(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.r(28)),
        child: Stack(
          children: [
            if (backgroundImage != null)
              Positioned(
                right: -context.w(20),
                bottom: -context.h(10),
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    backgroundImage!,
                    height: context.h(120),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(context.r(28)),
                child: Padding(
                  padding: EdgeInsets.all(context.w(18)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.all(context.w(10)),
                            decoration: BoxDecoration(
                              color: gradient != null 
                                  ? Colors.white.withValues(alpha: 0.3) 
                                  : color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: gradient != null 
                                  ? Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5) 
                                  : null,
                            ),
                            child: Icon(
                              icon, 
                              color: gradient != null ? Colors.black87 : color, 
                              size: context.sp(20)
                            ),
                          ),
                          if (trailing != null) trailing!,
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: CustomFonts.black16w700.copyWith(
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            SizedBox(height: context.h(4)),
                            Text(
                              subtitle!,
                              style: CustomFonts.black12w600.copyWith(
                                color: CustomColors.blackColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
