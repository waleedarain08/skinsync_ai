import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/responses/appointment_detail_response.dart';
import '../../../models/responses/appointments_list_response.dart';
import '../../../utils/custom_fonts.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/string_utils.dart';
import '../../../utils/color_constant.dart';
import '../../custom_button.dart';

class AppointmentInfoDialog extends StatelessWidget {
  final AppointmentDetailData? detail;
  final AppointmentItem? appointment;

  const AppointmentInfoDialog({super.key, this.detail, this.appointment});

  @override
  Widget build(BuildContext context) {
    final type = detail?.appointmentType?.title ?? appointment?.appointmentType ?? "consultation";
    final dateVal = detail?.date ?? appointment?.date;
    final dateStr = dateVal != null ? DateTimeUtils.formatTimestampToDayDate(dateVal) : "N/A";

    final startTimeVal = detail?.startTime ?? appointment?.slot?.startTime;
    final endTimeVal = detail?.endTime ?? appointment?.slot?.endTime;
    final startTime = startTimeVal != null ? DateTimeUtils.formatTimestampToTime(startTimeVal) : "--:--";
    final endTime = endTimeVal != null ? DateTimeUtils.formatTimestampToTime(endTimeVal) : "--:--";
    final timeString = "$startTime - $endTime";

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(32))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.w(24), vertical: context.h(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: context.w(72),
              width: context.w(72),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomColors.darkPurple.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Icon(
                  Iconsax.calendar_tick,
                  size: context.sp(32),
                  color: CustomColors.darkPurple,
                ),
              ),
            ),
            SizedBox(height: context.h(24)),
            Text("Appointment Info", style: CustomFonts.black20w600),
            SizedBox(height: context.h(24)),
            
            _buildRow("Key", detail?.appointmentKey ?? appointment?.appointmentKey ?? "N/A"),
            _buildRow("Type", type.capitalize),
            _buildRow("Date", dateStr),
            _buildRow("Time Slot", timeString),
            _buildRow("Status", detail?.status ?? appointment?.status ?? "Confirmed"),
            if (detail?.bookingType != null) _buildRow("Booking Type", detail!.bookingType!),
            
            SizedBox(height: context.h(32)),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: () => Navigator.pop(context),
                text: "Close",
                isBorder: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: CustomFonts.grey700_12w400),
          Text(value, style: CustomFonts.black14w600),
        ],
      ),
    );
  }
}
