import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../../view_models/treatment_view_model.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/treatment_progress/treatment_progress_timeline_widget.dart';

class TreatmentProgressDetailScreen extends ConsumerStatefulWidget {
  final int treatmentId;
  const TreatmentProgressDetailScreen({super.key, required this.treatmentId});
  static const String routeName = "/TreatmentProgressDetailScreen";

  @override
  ConsumerState<TreatmentProgressDetailScreen> createState() =>
      _TreatmentProgressDetailScreenState();
}

class _TreatmentProgressDetailScreenState
    extends ConsumerState<TreatmentProgressDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(treatmentViewModel.notifier)
          .callTreatmentProgressDetail(id: widget.treatmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(
      treatmentViewModel.select((s) => s.treatmentProgressDetail?.data),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Treatment Progress Details"),
      body: detail == null
          ? const Center(child: AppLoader())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(24),
                vertical: context.h(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(context.w(20)),
                    decoration: BoxDecoration(
                      gradient: CustomColors.purpleBlueGradient,
                      borderRadius: BorderRadius.circular(context.r(24)),
                      boxShadow: CustomColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail.treatmentName ?? 'N/A',
                          style: CustomFonts.black22w600,
                        ),
                        Text(
                          detail.areaName ?? 'N/A',
                          style: CustomFonts.black16w500.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                        SizedBox(height: context.h(12)),
                        _buildProgressInfo(
                          context,
                          progressData: detail.progressData ?? [],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: context.h(32)),
                  Text("Treatment Progress", style: CustomFonts.black18w600),
                  SizedBox(height: context.h(20)),
                  TreatmentProgressTimelineWidget(
                    events: detail.progressData ?? [], // see note below
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressInfo(
    BuildContext context, {
    required List<dynamic> progressData,
  }) {
    final totalSteps = progressData.length;
    final completedSteps = progressData
        .where((e) => e.status == 'completed')
        .length;
    final percent = totalSteps == 0
        ? 0
        : ((completedSteps / totalSteps) * 100).round();

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
            "$completedSteps/$totalSteps Completed",
            style: CustomFonts.black12w600,
          ),
        ),
        SizedBox(width: context.w(8)),
        Text("$percent% Done", style: CustomFonts.black12w600),
      ],
    );
  }
}
