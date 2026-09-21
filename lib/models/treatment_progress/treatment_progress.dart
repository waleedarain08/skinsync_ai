import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../models/responses/treatment_progress_response.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';

class TreatmentProgressCard extends StatelessWidget {
  final TreatmentProgressData treatmentProgress;
  final VoidCallback onTap;

  const TreatmentProgressCard({
    super.key,
    required this.treatmentProgress,
    required this.onTap,
  });

  int get _totalSteps => treatmentProgress.totalSteps ?? 0;
  int get _currentStep => treatmentProgress.currentStep ?? 0;

  // ASSUMPTION: `progress` is already 0-100 — confirm with backend
  double get _progressFraction =>
      ((treatmentProgress.progress ?? 0) / 100).clamp(0, 1).toDouble();

  String get _statusText =>
      (treatmentProgress.status ?? 'upcoming').replaceAll('_', ' ').toUpperCase();

  // ASSUMPTION: status vocabulary — confirm exact strings with backend
  Color get _statusColor {
    switch (treatmentProgress.status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return CustomColors.darkPurple;
      case 'paused':
        return Colors.grey;
      default:
        return Colors.orange; // upcoming / pending / unknown
    }
  }

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
                          treatmentProgress.treatmentName ?? 'N/A',
                          style: CustomFonts.black18w600,
                        ),
                        Text(
                          treatmentProgress.areaName ?? 'N/A',
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
            Padding(
              padding: EdgeInsets.all(context.w(18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Step $_currentStep of $_totalSteps",
                        style: CustomFonts.grey14w400,
                      ),
                      Text(
                        "${(_progressFraction * 100).toInt()}%",
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
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(12),
        vertical: context.h(6),
      ),
      decoration: BoxDecoration(
        color: _statusColor,
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Text(
        _statusText,
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
        widthFactor: _progressFraction,
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
    if (_totalSteps == 0) return const SizedBox.shrink();

    return Row(
      children: List.generate(_totalSteps, (index) {
        final isCompleted = index < _currentStep;
        final isLast = index == _totalSteps - 1;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: context.w(12),
                height: context.w(12),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? CustomColors.darkPurple
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 1.5,
                    color: isCompleted
                        ? CustomColors.darkPurple
                        : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}