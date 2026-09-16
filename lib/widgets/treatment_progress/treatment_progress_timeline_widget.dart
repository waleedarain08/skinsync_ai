import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/treatment_progress/treatment_event.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../../utils/date_time_utils.dart';

class TreatmentProgressTimelineWidget extends StatelessWidget {
  final List<TreatmentEvent> events;

  const TreatmentProgressTimelineWidget({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isLast = index == events.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Indicator
            Column(
              children: [
                Container(
                  width: context.w(24),
                  height: context.w(24),
                  decoration: BoxDecoration(
                    color: event.isCompleted
                        ? CustomColors.darkPurple
                        : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: event.isCompleted
                          ? CustomColors.darkPurple
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: event.isCompleted
                      ? Icon(
                          Icons.check,
                          size: context.sp(14),
                          color: Colors.white,
                        )
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
            // Right Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: event.isCompleted
                        ? CustomFonts.black16w600
                        : CustomFonts.grey16w500,
                  ),
                  if (event.date != null)
                    Text(
                      event.date!.formattedFullDate,
                      style: CustomFonts.grey14w400,
                    ),
                  if (event.appointmentTime != null)
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
                          Text(
                            event.appointmentTime!,
                            style: CustomFonts.darkPurple12w600,
                          ),
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
                                  Icon(
                                    Iconsax.user,
                                    size: context.sp(12),
                                    color: Colors.black54,
                                  ),
                                  SizedBox(width: context.w(6)),
                                  Text(
                                    event.doctorName!,
                                    style: CustomFonts.black12w500,
                                  ),
                                ],
                              ),
                            if (event.clinicName != null)
                              Padding(
                                padding: EdgeInsets.only(top: context.h(4)),
                                child: Row(
                                  children: [
                                    Icon(
                                      Iconsax.hospital,
                                      size: context.sp(12),
                                      color: Colors.black54,
                                    ),
                                    SizedBox(width: context.w(6)),
                                    Text(
                                      event.clinicName!,
                                      style: CustomFonts.black12w500,
                                    ),
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
