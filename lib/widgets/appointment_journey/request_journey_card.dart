import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../../models/appointment_journey/appointment_journey_model.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../../utils/date_time_utils.dart';

class RequestJourneyCard extends StatelessWidget {
  final PatientRequestStep request;

  const RequestJourneyCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(24)),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: CustomColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Patient Request", style: CustomFonts.black18w600),
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.w(10), vertical: context.h(4)),
                decoration: BoxDecoration(
                  color: CustomColors.blueColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.r(20)),
                ),
                child: Text(
                  request.status.toUpperCase(),
                  style: CustomFonts.blue10w700.copyWith(fontSize: context.sp(9)),
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(12)),
          Text("Treatments Requested:", style: CustomFonts.grey14w400),
          SizedBox(height: context.h(4)),
          Wrap(
            spacing: context.w(8),
            runSpacing: context.h(4),
            children: request.treatments.map((t) => Container(
              padding: EdgeInsets.symmetric(horizontal: context.w(8), vertical: context.h(4)),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(context.r(8)),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(t, style: CustomFonts.black12w600),
            )).toList(),
          ),
          SizedBox(height: context.h(12)),
          const Divider(height: 1, color: Colors.black12),
          SizedBox(height: context.h(12)),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: context.sp(14), color: Colors.grey),
              SizedBox(width: context.w(6)),
              Text(request.requestedAt.formattedDayDate, style: CustomFonts.grey14w400),
              const Spacer(),
              Icon(Icons.access_time_rounded, size: context.sp(14), color: Colors.grey),
              SizedBox(width: context.w(6)),
              Text(request.requestedAt.formattedTime, style: CustomFonts.grey14w400),
            ],
          ),
        ],
      ),
    );
  }
}
