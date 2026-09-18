import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../models/responses/appointment_detail_response.dart';
import '../models/responses/appointments_list_response.dart';
import '../utils/app_lunach_utils.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/string_utils.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';

class RecoveryJourneyArgs {
  final AppointmentDetailData? detail;
  final AppointmentItem? appointment;

  RecoveryJourneyArgs({this.detail, this.appointment});
}

class RecoveryJourneyScreen extends ConsumerStatefulWidget {
  static const String routeName = "/RecoveryJourneyScreen";
  final RecoveryJourneyArgs? args;

  const RecoveryJourneyScreen({super.key, this.args});

  @override
  ConsumerState<RecoveryJourneyScreen> createState() =>
      _RecoveryJourneyScreenState();
}

class _RecoveryJourneyScreenState
    extends ConsumerState<RecoveryJourneyScreen> {
  int _selectedTreatmentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final detail = widget.args?.detail;
    final appointment = widget.args?.appointment;

    final clinicPhone =
        detail?.clinic?.phone ?? appointment?.clinic?.phone ?? "+18005550199";

    final treatments = detail?.treatments ?? [];

    // Calculate elapsed time from appointment date
    final timestamp = detail?.date ?? appointment?.date;
    final appointmentDate = timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000)
        : DateTime.now();

    final hoursElapsed = DateTime.now().difference(appointmentDate).inHours;
    final daysElapsed = DateTime.now().difference(appointmentDate).inDays;

    // Determine current active recovery stage (0: 24h, 1: 48h, 2: 7d, 3: 14d)
    int currentStage = 0;
    if (daysElapsed > 7) {
      currentStage = 3; // 14 Days
    } else if (daysElapsed > 2) {
      currentStage = 2; // 7 Days
    } else if (hoursElapsed > 24) {
      currentStage = 1; // 48 Hours
    } else {
      currentStage = 0; // 24 Hours
    }

    final activeTreatment = treatments.isNotEmpty
        ? treatments[_selectedTreatmentIndex.clamp(0, treatments.length - 1)]
        : null;

    final treatmentName = activeTreatment?.treatmentName ?? "Treatment";

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: const CustomAppBar(title: "Recovery Journey"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(10),
          context.w(20),
          context.h(40),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Progress Banner
            _buildProgressBanner(
              context,
              hoursElapsed: hoursElapsed,
              daysElapsed: daysElapsed,
              currentStage: currentStage,
            ),
            SizedBox(height: context.h(20)),

            // Treatment Selector Tabs (if multiple treatments)
            if (treatments.length > 1) ...[
              _buildTreatmentSelector(context, treatments),
              SizedBox(height: context.h(20)),
            ],

            // Milestone Timeline Section
            _buildMilestoneTimeline(
              context,
              currentStage: currentStage,
              clinicPhone: clinicPhone,
              treatmentName: treatmentName,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBanner(
    BuildContext context, {
    required int hoursElapsed,
    required int daysElapsed,
    required int currentStage,
  }) {
    final stages = [
      "Within 24 Hours",
      "Within 48 Hours",
      "7 Days Recovery",
      "14 Days Final Result",
    ];

    final stageName = stages[currentStage.clamp(0, 3)];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.w(20)),
      decoration: BoxDecoration(
        gradient: CustomColors.checkInGradient,
        borderRadius: BorderRadius.circular(context.r(24)),
        boxShadow: CustomColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.w(10)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Iconsax.status_up,
                  color: CustomColors.blackColor,
                  size: context.sp(22),
                ),
              ),
              SizedBox(width: context.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Recovery Tracker",
                      style: CustomFonts.black18w600,
                    ),
                    SizedBox(height: context.h(2)),
                    Text(
                      "Active Stage: $stageName",
                      style: CustomFonts.black12w600.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(10),
                  vertical: context.h(5),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(context.r(14)),
                ),
                child: Text(
                  daysElapsed <= 0 ? "${hoursElapsed.clamp(0, 24)}h Elapsed" : "Day ${daysElapsed + 1}",
                  style: CustomFonts.black12w600,
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(16)),

          // 4-Stage Progress Line
          Row(
            children: List.generate(4, (index) {
              final isCompleted = index < currentStage;
              final isCurrent = index == currentStage;

              return Expanded(
                child: Container(
                  height: context.h(6),
                  margin: EdgeInsets.symmetric(horizontal: context.w(2)),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Colors.black87
                        : isCompleted
                            ? Colors.green.shade800
                            : Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(context.r(3)),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentSelector(
    BuildContext context,
    List<DetailedAppointmentTreatment> treatments,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(treatments.length, (index) {
          final isSelected = index == _selectedTreatmentIndex;
          final treatment = treatments[index];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTreatmentIndex = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: context.w(10)),
              padding: EdgeInsets.symmetric(
                horizontal: context.w(16),
                vertical: context.h(10),
              ),
              decoration: BoxDecoration(
                color: isSelected ? CustomColors.blackColor : Colors.white,
                borderRadius: BorderRadius.circular(context.r(20)),
                border: Border.all(
                  color: isSelected ? CustomColors.blackColor : Colors.grey.shade300,
                  width: 1.2,
                ),
                boxShadow: CustomColors.cardShadow,
              ),
              child: Text(
                treatment.treatmentName?.capitalize ?? "Treatment ${index + 1}",
                style: TextStyle(
                  color: isSelected ? Colors.white : CustomColors.blackColor,
                  fontSize: context.sp(13),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Degular',
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMilestoneTimeline(
    BuildContext context, {
    required int currentStage,
    required String clinicPhone,
    required String treatmentName,
  }) {
    return Column(
      children: [
        // Milestone 1: Within 24 Hours
        _buildMilestoneCard(
          context,
          title: "Within 24 Hours",
          subtitle: "Immediate Post-Care & Sensation Guidelines",
          icon: Iconsax.clock,
          isCurrent: currentStage == 0,
          isCompleted: currentStage > 0,
          guidelines: [
            "Mild swelling, tenderness, redness, and bruising are common.",
            "Use a cool compress as needed.",
            "Stay hydrated.",
            "Avoid exercise, alcohol, heat, and pressure on the area.",
            "Do not massage unless instructed by your provider.",
          ],
        ),

        // ⚠️ Vascular Occlusion Warning Box (Always Visible Red Flag Section)
        _buildVascularOcclusionWarningCard(
          context,
          clinicPhone: clinicPhone,
        ),

        // Milestone 2: Within 48 Hours
        _buildMilestoneCard(
          context,
          title: "Within 48 Hours",
          subtitle: "Intermediate Settling Phase",
          icon: Iconsax.calendar_1,
          isCurrent: currentStage == 1,
          isCompleted: currentStage > 1,
          guidelines: [
            "Swelling or bruising may still be present.",
            "Avoid unnecessary pressure or manipulation.",
            "Resume normal activity as tolerated.",
            "Contact your provider if pain, redness, or swelling is worsening.",
          ],
        ),

        // Milestone 3: 7 Days
        _buildMilestoneCard(
          context,
          title: "7 Days",
          subtitle: "Mid-Recovery & Initial Settling",
          icon: Iconsax.calendar_tick,
          isCurrent: currentStage == 2,
          isCompleted: currentStage > 2,
          guidelines: [
            "Most swelling and bruising should be improving.",
            "Mild firmness or unevenness may remain as filler settles.",
            "Do not massage unless instructed.",
            "Contact your provider for increasing redness, warmth, pain, or swelling.",
          ],
        ),

        // Milestone 4: 14 Days
        _buildMilestoneCard(
          context,
          title: "14 Days",
          subtitle: "Final Settling & Result Evaluation",
          icon: Iconsax.verify,
          isCurrent: currentStage == 3,
          isCompleted: currentStage > 3,
          guidelines: [
            "Most filler has settled and results can be evaluated.",
            "Review symmetry and results.",
            "Schedule a follow-up if recommended.",
            "Do not manipulate the filler yourself.",
          ],
        ),
      ],
    );
  }

  Widget _buildMilestoneCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCurrent,
    required bool isCompleted,
    required List<String> guidelines,
  }) {
    Color statusColor = isCurrent
        ? CustomColors.darkPurple
        : isCompleted
            ? Colors.green
            : Colors.grey;

    String statusText = isCurrent
        ? "IN PROGRESS"
        : isCompleted
            ? "COMPLETED"
            : "UPCOMING";

    return Container(
      margin: EdgeInsets.only(bottom: context.h(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(24)),
        border: Border.all(
          color: isCurrent
              ? CustomColors.darkPurple.withValues(alpha: 0.6)
              : Colors.grey.shade200,
          width: isCurrent ? 2 : 1.2,
        ),
        boxShadow: CustomColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.r(24)),
        child: Padding(
          padding: EdgeInsets.all(context.w(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(context.w(10)),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: statusColor, size: context.sp(20)),
                  ),
                  SizedBox(width: context.w(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: CustomFonts.black18w600),
                        SizedBox(height: context.h(2)),
                        Text(
                          subtitle,
                          style: CustomFonts.black12w600.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(10),
                      vertical: context.h(4),
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(context.r(12)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: context.sp(9),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: context.h(16)),
              const Divider(height: 1, color: CustomColors.greyColor),
              SizedBox(height: context.h(14)),

              // Guidelines Checklist
              Column(
                children: guidelines.map((rule) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: context.h(8)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: statusColor,
                          size: context.sp(16),
                        ),
                        SizedBox(width: context.w(10)),
                        Expanded(
                          child: Text(
                            rule,
                            style: CustomFonts.black14w600.copyWith(
                              height: 1.35,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVascularOcclusionWarningCard(
    BuildContext context, {
    required String clinicPhone,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: context.h(20)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(context.r(24)),
        border: Border.all(color: Colors.red.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(context.w(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(context.w(10)),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade800,
                    size: context.sp(22),
                  ),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: Text(
                    "⚠️ Vascular Occlusion Warning Signs",
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontSize: context.sp(16),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Degular',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(12)),
            Text(
              "These symptoms are NOT normal:",
              style: TextStyle(
                color: Colors.red.shade900,
                fontSize: context.sp(13),
                fontWeight: FontWeight.w700,
                fontFamily: 'Degular',
              ),
            ),
            SizedBox(height: context.h(10)),

            // Warning Symptoms
            _buildWarningSymptom("Severe or increasing pain"),
            _buildWarningSymptom("White, pale, gray, blue, or mottled skin"),
            _buildWarningSymptom("Skin that looks increasingly dusky or discolored"),
            _buildWarningSymptom("Blistering or worsening skin changes"),
            _buildWarningSymptom("Any vision changes"),

            SizedBox(height: context.h(16)),
            Text(
              "Contact your provider immediately if any of these occur. Seek emergency medical care for vision changes or stroke-like symptoms.",
              style: TextStyle(
                color: Colors.red.shade900,
                fontSize: context.sp(12),
                fontWeight: FontWeight.w600,
                height: 1.35,
                fontFamily: 'Degular',
              ),
            ),
            SizedBox(height: context.h(18)),

            // CALL NOW CTA Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: () => launchPhone(clinicPhone),
                text: "CALL NOW",
                backgroundColor: Colors.red.shade700,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningSymptom(String symptom) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Colors.red.shade700,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              symptom,
              style: TextStyle(
                color: Colors.red.shade900,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                fontFamily: 'Degular',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
