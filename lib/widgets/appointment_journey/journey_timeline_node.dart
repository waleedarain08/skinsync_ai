import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../utils/color_constant.dart';

class JourneyTimelineNode extends StatelessWidget {
  final Widget child;
  final bool isFirst;
  final bool isLast;
  final bool isCompleted;
  final Widget? indicator;
  final double? customPadding;

  const JourneyTimelineNode({
    super.key,
    required this.child,
    this.isFirst = false,
    this.isLast = false,
    this.isCompleted = true,
    this.indicator,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: context.w(32),
            child: Column(
              children: [
                if (isFirst) SizedBox(height: context.h(10)),
                indicator ?? _buildDefaultIndicator(context),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            isCompleted ? CustomColors.darkPurple : Colors.grey.shade200,
                            isCompleted ? CustomColors.purpleColor : Colors.grey.shade200,
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: context.w(12)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                top: isFirst ? context.h(0) : context.h(0),
                bottom: customPadding ?? context.h(32),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultIndicator(BuildContext context) {
    return Container(
      width: context.w(20),
      height: context.w(20),
      decoration: BoxDecoration(
        color: isCompleted ? CustomColors.darkPurple : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted ? CustomColors.darkPurple : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: isCompleted ? [
          BoxShadow(
            color: CustomColors.darkPurple.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ] : null,
      ),
      child: isCompleted
          ? Icon(
              Icons.check,
              size: context.sp(12),
              color: Colors.white,
            )
          : null,
    );
  }
}
