import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../models/appointment_journey/appointment_journey_model.dart';
import '../../models/responses/appointments_list_response.dart';
import '../../view_models/appointment_journey/appointment_journey_view_model.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/appointment_card.dart';
import '../../widgets/appointment_journey/journey_timeline_node.dart';
import '../../widgets/appointment_journey/request_journey_card.dart';
import '../../widgets/appointment_journey/finalized_journey_card.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../../utils/date_time_utils.dart';

class AppointmentJourneyScreen extends ConsumerWidget {
  const AppointmentJourneyScreen({super.key});

  static const String routeName = "/AppointmentJourneyScreen";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appointmentJourneyProvider);
    final journey = state.journey;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Appointment Journey"),
      body: journey == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: context.w(24), vertical: context.h(20)),
              child: Column(
                children: [
                  // 1. Patient Request
                  JourneyTimelineNode(
                    isFirst: true,
                    isCompleted: true,
                    child: RequestJourneyCard(request: journey.patientRequest),
                  ),

                  // 2. Doctor Finalized
                  if (journey.doctorFinalized != null)
                    JourneyTimelineNode(
                      isCompleted: true,
                      child: FinalizedJourneyCard(finalized: journey.doctorFinalized!),
                    ),

                  // 3. Treatment Branches & Chronological Steps
                  _buildChronologicalTimeline(context, journey.treatmentBranches),

                  // 4. Journey Completed
                  if (journey.isCompleted)
                    JourneyTimelineNode(
                      isLast: true,
                      isCompleted: true,
                      child: _buildCompletionCard(context, journey),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildChronologicalTimeline(BuildContext context, List<TreatmentBranch> branches) {
    // 1. Flatten all appointments from all branches
    final allEvents = <_JourneyEventWrapper>[];
    for (var branch in branches) {
      allEvents.add(_JourneyEventWrapper(
        appointment: branch.mainAppointment,
        treatmentName: branch.treatmentName,
        area: branch.area,
      ));
      for (var f in branch.followUps) {
        allEvents.add(_JourneyEventWrapper(
          appointment: f,
          treatmentName: branch.treatmentName,
          area: branch.area,
        ));
      }
    }

    // 2. Sort by timestamp
    allEvents.sort((a, b) => (a.appointment.date ?? 0).compareTo(b.appointment.date ?? 0));

    // 3. Group by Date
    final Map<DateTime, List<_JourneyEventWrapper>> dateGroups = {};
    for (var event in allEvents) {
      if (event.appointment.date == null) continue;
      final date = DateTimeUtils.fromTimestamp(event.appointment.date!).toLocal();
      final dateOnly = DateTime(date.year, date.month, date.day);
      dateGroups.putIfAbsent(dateOnly, () => []).add(event);
    }

    final sortedDates = dateGroups.keys.toList()..sort();

    return Column(
      children: [
        // Visual Branching Header (The split point)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 2,
                    height: context.h(30),
                    color: CustomColors.darkPurple,
                  ),
                ],
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
        
        // Chronological Visits
        ...sortedDates.map((date) {
          final group = dateGroups[date]!;
          final isCompleted = group.every((e) => e.appointment.status?.toLowerCase() == 'completed');
          
          return JourneyTimelineNode(
            isCompleted: isCompleted,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(4)),
                  decoration: BoxDecoration(
                    color: CustomColors.darkPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.r(8)),
                  ),
                  child: Text(
                    date.formattedDayDate,
                    style: CustomFonts.darkPurple12w600,
                  ),
                ),
                SizedBox(height: context.h(16)),
                ...group.map((e) => Padding(
                  padding: EdgeInsets.only(bottom: context.h(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: context.w(4), bottom: context.h(6)),
                        child: Text(
                          "${e.treatmentName} – ${e.area}",
                          style: CustomFonts.black14w600.copyWith(fontSize: context.sp(13)),
                        ),
                      ),
                      AppointmentCard(
                        appointment: e.appointment,
                        onTap: () {},
                      ),
                    ],
                  ),
                )),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCompletionCard(BuildContext context, AppointmentJourney journey) {
    return Container(
      padding: EdgeInsets.all(context.w(20)),
      decoration: BoxDecoration(
        gradient: CustomColors.purpleBlueGradient,
        borderRadius: BorderRadius.circular(context.r(24)),
        boxShadow: CustomColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stars_rounded, color: Colors.white, size: context.sp(24)),
              SizedBox(width: context.w(10)),
              Text("Journey Completed", style: CustomFonts.white18w600.copyWith(color: Colors.black)),
            ],
          ),
          SizedBox(height: context.h(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, "Started", journey.requestedAt.formattedDayDate),
              if (journey.completedAt != null)
                _buildStatItem(context, "Completed", journey.completedAt!.formattedDayDate),
            ],
          ),
          SizedBox(height: context.h(16)),
          const Divider(color: Colors.white30),
          SizedBox(height: context.h(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSmallStat("Treatments", "${journey.treatmentBranches.length}"),
              _buildSmallStat("Appointments", "${journey.treatmentBranches.length}"),
              _buildSmallStat("Follow-ups", "${journey.treatmentBranches.fold(0, (sum, b) => sum + b.followUps.length)}"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(label, style: CustomFonts.black12w600.copyWith(color: Colors.black54)),
        SizedBox(height: context.h(4)),
        Text(value, style: CustomFonts.black14w600),
      ],
    );
  }

  Widget _buildSmallStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: CustomFonts.black18w600),
        Text(label, style: CustomFonts.black10w600.copyWith(color: Colors.black54)),
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
