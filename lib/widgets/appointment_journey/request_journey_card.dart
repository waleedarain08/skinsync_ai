import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
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
      padding: EdgeInsets.all(context.w(18)),
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
              Text("Original Request", style: CustomFonts.black18w600),
              _buildBadge(context, request.status.toUpperCase(), CustomColors.blueColor),
            ],
          ),
          SizedBox(height: context.h(16)),
          
          Text("Treatments:", style: CustomFonts.grey14w400),
          SizedBox(height: context.h(8)),
          Wrap(
            spacing: context.w(8),
            runSpacing: context.h(8),
            children: request.treatments.map((t) => _buildTreatmentChip(context, t)).toList(),
          ),
          
          if (request.preferredClinic != null) ...[
            SizedBox(height: context.h(16)),
            Row(
              children: [
                Icon(Iconsax.hospital, size: context.sp(14), color: Colors.grey),
                SizedBox(width: context.w(8)),
                Text(request.preferredClinic!, style: CustomFonts.black12w600.copyWith(color: Colors.black54)),
              ],
            ),
          ],
          
          SizedBox(height: context.h(16)),
          const Divider(height: 1, color: Colors.black12),
          SizedBox(height: context.h(16)),
          
          Row(
            children: [
              _buildMiniInfo(context, Iconsax.calendar, request.requestedAt.formattedDayDate),
              const Spacer(),
              _buildMiniInfo(context, Iconsax.clock, request.requestedAt.formattedTime),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(10), vertical: context.h(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(context.r(20)),
      ),
      child: Text(
        text,
        style: CustomFonts.blue10w700.copyWith(fontSize: context.sp(9), color: color),
      ),
    );
  }

  Widget _buildTreatmentChip(BuildContext context, String name) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(10), vertical: context.h(6)),
      decoration: BoxDecoration(
        color: CustomColors.greyColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(context.r(12)),
      ),
      child: Text(name, style: CustomFonts.black12w600),
    );
  }

  Widget _buildMiniInfo(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: context.sp(14), color: Colors.grey),
        SizedBox(width: context.w(6)),
        Text(text, style: CustomFonts.grey12w400),
      ],
    );
  }
}
