import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../models/treatment_progress/treatment_progress.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/treatment_progress/treatment_progress_timeline_widget.dart';

class TreatmentProgressDetailScreen extends StatelessWidget {
  final TreatmentProgress treatmentProgress;

  const TreatmentProgressDetailScreen({super.key, required this.treatmentProgress});

  static const String routeName = "/TreatmentProgressDetailScreen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: "Treatment Progress Details",
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(24),
          vertical: context.h(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              padding: EdgeInsets.all(context.w(20)),
              decoration: BoxDecoration(
                gradient: CustomColors.purpleBlueGradient,
                borderRadius: BorderRadius.circular(context.r(24)),
                boxShadow: CustomColors.cardShadow,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          treatmentProgress.treatmentName,
                          style: CustomFonts.black22w600,
                        ),
                        Text(
                          treatmentProgress.area,
                          style: CustomFonts.black16w500.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: context.h(12)),
                        _buildProgressInfo(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.h(32)),
            
            Text(
              "Treatment Progress",
              style: CustomFonts.black18w600,
            ),
            SizedBox(height: context.h(20)),
            
            TreatmentProgressTimelineWidget(events: treatmentProgress.events),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressInfo(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(10),
            vertical: context.h(4),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(context.r(12)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
          ),
          child: Text(
            "${treatmentProgress.completedSteps}/${treatmentProgress.totalSteps} Completed",
            style: CustomFonts.black12w600,
          ),
        ),
        SizedBox(width: context.w(8)),
        Text(
          "${(treatmentProgress.progress * 100).toInt()}% Done",
          style: CustomFonts.black12w600,
        ),
      ],
    );
  }
}
