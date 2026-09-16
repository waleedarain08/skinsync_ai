import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../utils/color_constant.dart';

class BorderdContainerWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const BorderdContainerWidget({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(context.w(14)),
      decoration: BoxDecoration(
        color: backgroundColor ?? CustomColors.whiteColor,
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(
          color: CustomColors.greyColor.withValues(alpha: 0.5),
        ),
      ),
      child: child,
    );
  }
}
