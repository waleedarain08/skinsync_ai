import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../utils/color_constant.dart';

class JourneyTimelineNode extends StatelessWidget {
  final Widget child;
  final bool isFirst;
  final bool isLast;
  final bool isCompleted;
  final double? lineLength;

  const JourneyTimelineNode({
    super.key,
    required this.child,
    this.isFirst = false,
    this.isLast = false,
    this.isCompleted = true,
    this.lineLength,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: context.w(16),
                height: context.w(16),
                decoration: BoxDecoration(
                  color: isCompleted ? CustomColors.darkPurple : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? CustomColors.darkPurple : Colors.grey.shade300,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? Icon(
                        Icons.check,
                        size: context.sp(10),
                        color: Colors.white,
                      )
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted ? CustomColors.darkPurple : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          SizedBox(width: context.w(16)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: context.h(24)),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
