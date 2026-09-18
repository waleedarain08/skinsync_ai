import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/responses/appointment_detail_response.dart';
import '../../../models/responses/appointments_list_response.dart';
import '../../../utils/color_constant.dart';
import '../../../utils/custom_fonts.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/string_utils.dart';
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

    final clinicName = detail?.clinic?.name ?? appointment?.clinic?.clinicName ?? "N/A";
    final clinicAddress = detail?.clinic?.address ?? "N/A";
    final clinicPhone = detail?.clinic?.phone ?? "N/A";

    final doctorName = detail?.doctor?.name ?? appointment?.doctor?.doctorName ?? "N/A";
    final doctorTitle = detail?.doctor?.title ?? "Specialist";

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(32))),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.w(24), vertical: context.h(28)),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
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
              SizedBox(height: context.h(20)),
              Text("Appointment Details", style: CustomFonts.black20w600),
              SizedBox(height: context.h(20)),
              
              // Section 1: Appointment Info
              _buildSectionHeader(context, "Appointment Info", Iconsax.key),
              SizedBox(height: context.h(8)),
              _buildRow("Key", detail?.appointmentKey ?? appointment?.appointmentKey ?? "N/A"),
              _buildRow("Type", type.capitalize),
              _buildRow("Date", dateStr),
              _buildRow("Time Slot", timeString),
              _buildRow("Status", detail?.status ?? appointment?.status ?? "Confirmed"),

              SizedBox(height: context.h(16)),
              const Divider(height: 1, color: CustomColors.greyColor),
              SizedBox(height: context.h(16)),

              // Section 2: Clinic Info
              _buildSectionHeader(context, "Clinic Details", Iconsax.hospital),
              SizedBox(height: context.h(8)),
              _buildRow("Clinic Name", clinicName.capitalize),
              if (clinicAddress != "N/A") _buildRow("Address", clinicAddress),
              if (clinicPhone != "N/A") _buildRow("Phone", clinicPhone),

              SizedBox(height: context.h(16)),
              const Divider(height: 1, color: CustomColors.greyColor),
              SizedBox(height: context.h(16)),

              // Section 3: Doctor Info
              _buildSectionHeader(context, "Doctor Details", Iconsax.user),
              SizedBox(height: context.h(8)),
              _buildRow("Doctor Name", doctorName.capitalize),
              if (doctorTitle != "Specialist") _buildRow("Specialization", doctorTitle),

              SizedBox(height: context.h(28)),
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
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: context.sp(16), color: CustomColors.darkPurple),
        SizedBox(width: context.w(8)),
        Text(title, style: CustomFonts.black16w700),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: CustomFonts.black13w600),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: CustomFonts.black13w600,
            ),
          ),
        ],
      ),
    );
  }
}
