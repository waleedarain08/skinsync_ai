import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../models/responses/appointments_list_response.dart';
import '../../models/responses/clinical_journey_response.dart';
import '../../view_models/treatment_view_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/clinical_journey/journey_timeline_node.dart';
import '../../widgets/clinical_journey/request_journey_card.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../../utils/date_time_utils.dart';

class ClinicalJourneyScreen extends ConsumerStatefulWidget {
  const ClinicalJourneyScreen({super.key});

  static const String routeName = "/ClinicalJourneyScreen";

  @override
  ConsumerState<ClinicalJourneyScreen> createState() =>
      _ClinicalJourneyScreenState();
}

class _ClinicalJourneyScreenState extends ConsumerState<ClinicalJourneyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(treatmentViewModel.notifier).getClinicalJourney();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(treatmentViewModel);
    final journey = state.clinicJourneyResonse?.data;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Clinical Journey"),
      body: state.loading && journey == null
          ? const Center(child: CircularProgressIndicator())
          : journey == null
              ? const Center(child: Text("No journey data found"))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(24),
                    vertical: context.h(10),
                  ),
                  child: Column(
                    children: [
                      // 1. Patient Request
                      if (journey.patientRequest != null)
                        JourneyTimelineNode(
                          isFirst: true,
                          isCompleted: true,
                          indicator: _buildHeroIndicator(
                            context,
                            Iconsax.document_text,
                          ),
                          child: RequestJourneyCard(
                            request: journey.patientRequest!,
                          ),
                        ),

                      // 2. Treatment Branches & Chronological Steps
                      _buildChronologicalTimeline(
                        context,
                        journey.treatmentBranches ?? [],
                      ),

                      // 3. Journey Completed
                      if (journey.isCompleted == true)
                        JourneyTimelineNode(
                          isLast: true,
                          isCompleted: true,
                          indicator: _buildHeroIndicator(
                            context,
                            Iconsax.crown,
                            isGold: true,
                          ),
                          child: _buildCompletionCard(context, journey),
                        ),

                      SizedBox(height: context.h(40)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeroIndicator(
    BuildContext context,
    IconData icon, {
    bool isGold = false,
  }) {
    return Container(
      width: context.w(32),
      height: context.w(32),
      decoration: BoxDecoration(
        gradient: isGold
            ? const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              )
            : CustomColors.purpleBlueGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isGold ? Colors.orange : CustomColors.purpleColor)
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, size: context.sp(16), color: Colors.black),
      ),
    );
  }

  Widget _buildChronologicalTimeline(
    BuildContext context,
    List<TreatmentBranch> branches,
  ) {
    final allEvents = <_JourneyEventWrapper>[];
    for (var branch in branches) {
      if (branch.mainAppointment != null) {
        allEvents.add(
          _JourneyEventWrapper(
            appointment: branch.mainAppointment!,
            treatmentName: branch.treatmentName ?? '',
            area: branch.area ?? '',
          ),
        );
      }
      for (var f in branch.followUps ?? <AppointmentItem>[]) {
        allEvents.add(
          _JourneyEventWrapper(
            appointment: f,
            treatmentName: branch.treatmentName ?? '',
            area: branch.area ?? '',
          ),
        );
      }
    }

    allEvents.sort(
      (a, b) => (a.appointment.date ?? 0).compareTo(b.appointment.date ?? 0),
    );

    final Map<DateTime, List<_JourneyEventWrapper>> dateGroups = {};
    for (var event in allEvents) {
      if (event.appointment.date == null) continue;
      final date = DateTimeUtils.fromTimestamp(
        event.appointment.date!,
      ).toLocal();
      final dateOnly = DateTime(date.year, date.month, date.day);
      dateGroups.putIfAbsent(dateOnly, () => []).add(event);
    }

    final sortedDates = dateGroups.keys.toList()..sort();

    return Column(
      children: sortedDates.map((date) {
        final group = dateGroups[date]!;
        final isCompleted = group.every(
          (e) => e.appointment.status?.toLowerCase() == 'completed',
        );

        return JourneyTimelineNode(
          isCompleted: isCompleted,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(context, date),
              SizedBox(height: context.h(16)),
              ...group.map(
                (e) => Padding(
                  padding: EdgeInsets.only(bottom: context.h(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: context.w(4),
                            height: context.h(16),
                            decoration: BoxDecoration(
                              color: CustomColors.darkPurple,
                              borderRadius:
                                  BorderRadius.circular(context.r(2)),
                            ),
                          ),
                          SizedBox(width: context.w(8)),
                          Text(
                            "${e.treatmentName} – ${e.area}",
                            style: CustomFonts.black16w600.copyWith(
                              fontSize: context.sp(14),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.h(10)),
                      AppointmentCard(appointment: e.appointment, onTap: () {}),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateHeader(BuildContext context, DateTime date) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(16),
        vertical: context.h(10),
      ),
      decoration: BoxDecoration(
        color: CustomColors.greyColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: CustomColors.greyColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Iconsax.calendar_1,
            size: context.sp(18),
            color: CustomColors.darkPurple,
          ),
          SizedBox(width: context.w(10)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE').format(date),
                style: CustomFonts.black12w600.copyWith(color: Colors.black54),
              ),
              Text(date.formattedFullDate, style: CustomFonts.black14w600),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard(BuildContext context, ClinicalJourneyData journey) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(24)),
        boxShadow: CustomColors.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.r(24)),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(context.w(24)),
              decoration: const BoxDecoration(
                gradient: CustomColors.purpleBlueGradient,
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(context.w(12)),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.verify,
                      color: Colors.black,
                      size: context.sp(32),
                    ),
                  ),
                  SizedBox(height: context.h(16)),
                  Text(
                    "Journey Successfully Completed",
                    textAlign: TextAlign.center,
                    style: CustomFonts.black20w600,
                  ),
                  SizedBox(height: context.h(8)),
                  Text(
                    "All treatments and follow-ups have been finished.",
                    textAlign: TextAlign.center,
                    style: CustomFonts.black14w400.copyWith(
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: context.h(24)),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: context.h(16)),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(context.r(20)),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSmallStat(
                          context,
                          "Treatments",
                          "${journey.treatmentBranches?.length ?? 0}",
                        ),
                        _buildSmallStat(
                          context,
                          "Visits",
                          "${journey.treatmentBranches?.length ?? 0}",
                        ),
                        _buildSmallStat(context, "Completed", "100%"),
                      ],
                    ),
                  ),
                  SizedBox(height: context.h(20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (journey.requestedAt != null)
                        _buildMiniStat(
                          context,
                          "Started",
                         DateTimeUtils.formatTimestampToDayDate(journey.requestedAt!),
                        ),
                      if (journey.completedAt != null)
                        _buildMiniStat(
                          context,
                          "Finished",
                          DateTimeUtils.formatTimestampToDayDate(journey.completedAt!),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: CustomFonts.black20w600),
        SizedBox(height: context.h(2)),
        Text(
          label,
          style: CustomFonts.black10w600.copyWith(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildMiniStat(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CustomFonts.black10w600.copyWith(color: Colors.black54),
        ),
        Text(value, style: CustomFonts.black12w600),
      ],
    );
  }
}

class _JourneyEventWrapper {
  final AppointmentItem appointment;
  final String treatmentName;
  final String area;

  _JourneyEventWrapper({
    required this.appointment,
    required this.treatmentName,
    required this.area,
  });
}