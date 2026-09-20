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

  List<TreatmentProgressItem> get _items =>
      treatmentProgress.progressData ?? const [];

  int get _totalSteps => _items.length;

  int get _completedSteps => _items
      .where((e) => e.status?.toLowerCase() == 'completed')
      .length;

  double get _progress =>
      _totalSteps == 0 ? 0 : _completedSteps / _totalSteps;

  // ASSUMPTION: derived from item statuses since there's no single
  // treatment-level status field on TreatmentProgressData — confirm
  // against actual API status strings.
  String get _overallStatusText {
    if (_totalSteps == 0) return 'UPCOMING';
    if (_completedSteps == _totalSteps) return 'COMPLETED';
    if (_completedSteps == 0) return 'UPCOMING';
    return 'IN PROGRESS';
  }

  Color get _overallStatusColor {
    switch (_overallStatusText) {
      case 'COMPLETED':
        return Colors.green;
      case 'UPCOMING':
        return Colors.orange;
      default:
        return CustomColors.darkPurple;
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
                        "$_completedSteps of $_totalSteps completed",
                        style: CustomFonts.grey14w400,
                      ),
                      Text(
                        "${(_progress * 100).toInt()}%",
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
        color: _overallStatusColor,
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Text(
        _overallStatusText,
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
        widthFactor: _progress,
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
    if (_items.isEmpty) return const SizedBox.shrink();

    return Row(
      children: List.generate(_items.length, (index) {
        final item = _items[index];
        final isCompleted = item.status?.toLowerCase() == 'completed';
        // ASSUMPTION: 'upcoming' status string — confirm against backend
        final isUpcoming = item.status?.toLowerCase() == 'upcoming';
        final isLast = index == _items.length - 1;

        return Expanded(
          child: Row(
            children: [
              Container(
                width: context.w(12),
                height: context.w(12),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? CustomColors.darkPurple
                      : (isUpcoming
                          ? CustomColors.purpleColor.withValues(alpha: 0.3)
                          : Colors.grey.shade300),
                  shape: BoxShape.circle,
                  border: isUpcoming
                      ? Border.all(color: CustomColors.darkPurple, width: 1.5)
                      : null,
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