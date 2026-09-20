import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/responses/treatment_progress_detail_response.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../../utils/date_time_utils.dart';

class TreatmentProgressTimelineWidget extends StatelessWidget {
  final List<TreatmentProgressDetailItem> events;

  const TreatmentProgressTimelineWidget({super.key, required this.events});

  // ASSUMPTION: 'completed' status string — confirm against backend values
  bool _isCompleted(TreatmentProgressDetailItem e) =>
      e.status?.toLowerCase() == 'completed';

  String _title(TreatmentProgressDetailItem e) {
    if (e.sessionName != null && e.sessionName!.isNotEmpty) {
      return e.sessionName!;
    }
    switch (e.appointmentType) {
      case AppointmentType.consultation:
        return 'Consultation';
      case AppointmentType.followUp:
        return 'Follow-up';
      case AppointmentType.treatment:
        return 'Treatment Session';
      case null:
        return 'Appointment';
    }
  }

  // ASSUMPTION: epoch seconds — confirm units with backend
  DateTime? _date(TreatmentProgressDetailItem e) {
    final raw = e.sessionDate ?? e.date;
    if (raw == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
  }

  // ASSUMPTION: epoch seconds, formatted as a clock time — confirm units
  String? _timeLabel(TreatmentProgressDetailItem e) {
    final raw = e.sessionTime ?? e.time;
    if (raw == null) return null;
    final dt = DateTime.fromMillisecondsSinceEpoch(raw * 1000);
    return dt.formattedTime; // ASSUMPTION: this extension exists — swap for whatever your date_time_utils actually exposes
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isLast = index == events.length - 1;
        final isCompleted = _isCompleted(event);
        final date = _date(event);
        final timeLabel = _timeLabel(event);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: context.w(24),
                  height: context.w(24),
                  decoration: BoxDecoration(
                    color: isCompleted ? CustomColors.darkPurple : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? CustomColors.darkPurple
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? Icon(Icons.check, size: context.sp(14), color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: context.h(80),
                    color: Colors.grey.shade200,
                  ),
              ],
            ),
            SizedBox(width: context.w(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title(event),
                    style: isCompleted
                        ? CustomFonts.black16w600
                        : CustomFonts.grey16w500,
                  ),
                  if (date != null)
                    Text(
                      date.formattedFullDate,
                      style: CustomFonts.grey14w400,
                    ),
                  if (timeLabel != null)
                    Padding(
                      padding: EdgeInsets.only(top: context.h(4)),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.clock,
                            size: context.sp(14),
                            color: CustomColors.darkPurple,
                          ),
                          SizedBox(width: context.w(4)),
                          Text(timeLabel, style: CustomFonts.darkPurple12w600),
                        ],
                      ),
                    ),
                  if (event.doctorName != null || event.clinicName != null)
                    Padding(
                      padding: EdgeInsets.only(top: context.h(8)),
                      child: Container(
                        padding: EdgeInsets.all(context.w(10)),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(context.r(12)),
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (event.doctorName != null)
                              Row(
                                children: [
                                  Icon(Iconsax.user, size: context.sp(12), color: Colors.black54),
                                  SizedBox(width: context.w(6)),
                                  Text(event.doctorName!, style: CustomFonts.black12w500),
                                ],
                              ),
                            if (event.clinicName != null)
                              Padding(
                                padding: EdgeInsets.only(top: context.h(4)),
                                child: Row(
                                  children: [
                                    Icon(Iconsax.hospital, size: context.sp(12), color: Colors.black54),
                                    SizedBox(width: context.w(6)),
                                    Text(event.clinicName!, style: CustomFonts.black12w500),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  SizedBox(height: context.h(24)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}