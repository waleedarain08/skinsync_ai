import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../models/treatment_progress/treatment_progress.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';

class TreatmentProgressCard extends StatelessWidget {
  final TreatmentProgress treatmentProgress;
  final VoidCallback onTap;

  const TreatmentProgressCard({
    super.key,
    required this.treatmentProgress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: context.h(20)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(24)),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: CustomColors.cardShadow,
        ),
        child: Column(
          children: [
            // Top Section
            Container(
              padding: EdgeInsets.all(context.w(18)),
              decoration: BoxDecoration(
                gradient: CustomColors.purpleBlueGradient,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(context.r(24)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          treatmentProgress.treatmentName,
                          style: CustomFonts.black18w600,
                        ),
                        Text(
                          treatmentProgress.area,
                          style: CustomFonts.black14w500.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context),
                ],
              ),
            ),
            
            // Progress Section
            Padding(
              padding: EdgeInsets.all(context.w(18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${treatmentProgress.completedSteps} of ${treatmentProgress.totalSteps} completed",
                        style: CustomFonts.grey14w400,
                      ),
                      Text(
                        "${(treatmentProgress.progress * 100).toInt()}%",
                        style: CustomFonts.black14w600,
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(8)),
                  _buildProgressBar(context),
                  SizedBox(height: context.h(16)),
                  _buildTimelineDots(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color bgColor;
   // Color textColor = Colors.white;

    switch (treatmentProgress.status) {
      case TreatmentStatus.inProgress:
        bgColor = CustomColors.darkPurple;
        break;
      case TreatmentStatus.completed:
        bgColor = Colors.green;
        break;
      case TreatmentStatus.upcoming:
        bgColor = Colors.orange;
        break;
      case TreatmentStatus.paused:
        bgColor = Colors.grey;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(12),
        vertical: context.h(6),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Text(
        treatmentProgress.statusText.toUpperCase(),
        style: CustomFonts.white10w600.copyWith(
          letterSpacing: 1,
          fontSize: context.sp(9),
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Container(
      height: context.h(8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(context.r(4)),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: treatmentProgress.progress,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [CustomColors.darkPurple, CustomColors.purpleColor],
            ),
            borderRadius: BorderRadius.circular(context.r(4)),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineDots(BuildContext context) {
    return Row(
      children: List.generate(treatmentProgress.events.length, (index) {
        final event = treatmentProgress.events[index];
        final isLast = index == treatmentProgress.events.length - 1;
        
        return Expanded(
          child: Row(
            children: [
              Container(
                width: context.w(12),
                height: context.w(12),
                decoration: BoxDecoration(
                  color: event.isCompleted 
                    ? CustomColors.darkPurple 
                    : (event.isUpcoming ? CustomColors.purpleColor.withValues(alpha: 0.3) : Colors.grey.shade300),
                  shape: BoxShape.circle,
                  border: event.isUpcoming 
                    ? Border.all(color: CustomColors.darkPurple, width: 1.5) 
                    : null,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 1.5,
                    color: event.isCompleted ? CustomColors.darkPurple : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
