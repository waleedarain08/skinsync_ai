import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../models/responses/appointments_list_response.dart';
import '../screens/appointment_detail_screen.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/date_time_utils.dart';

class AppointmentCard extends StatelessWidget {
  final AppointmentItem appointment;
  final VoidCallback? onTap;
  final bool isTreatmentListHorizontal;

  const AppointmentCard({
    super.key,
    required this.appointment,
    this.onTap,
    this.isTreatmentListHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final type = appointment.appointmentType ?? "consultation";
    Color typeColor = _getTypeColor(type);
    TextStyle timeStyle = _getTimeStyle(type);

    final dateStr = appointment.date != null
        ? DateTimeUtils.formatTimestampToDayDate(appointment.date!)
        : "N/A";

    final startTime = appointment.slot?.startTime != null
        ? DateTimeUtils.formatTimestampToTime(appointment.slot!.startTime!)
        : "--:--";
    final endTime = appointment.slot?.endTime != null
        ? DateTimeUtils.formatTimestampToTime(appointment.slot!.endTime!)
        : "--:--";
    final timeString = "$startTime - $endTime";

    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.pushNamed(
              context,
              AppointmentDetailScreen.routeName,
              arguments: appointment,
            );
          },
      child: Container(
        margin: EdgeInsets.only(
          bottom: isTreatmentListHorizontal ? context.h(20) : context.h(22),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(24)),
          border: Border.all(color: Colors.grey.shade100, width: 1.5),
          boxShadow: CustomColors.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Top Section: Date, Slot & Status (Gradient background)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(18),
                vertical: context.h(27),
              ),
              decoration: BoxDecoration(
                gradient: CustomColors.purpleBlueGradient,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(context.r(24)),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: context.sp(16),
                                  color: Colors.black,
                                ),
                                SizedBox(width: context.w(8)),
                                Text(dateStr, style: CustomFonts.black14w600),
                              ],
                            ),
                            if (appointment.appointmentKey != null) ...[
                              SizedBox(height: context.h(4)),
                              Text(
                                appointment.appointmentKey!,
                                style: CustomFonts.black10w600,
                              ),
                            ],
                            SizedBox(height: context.h(10)),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_filled_rounded,
                                  size: context.sp(14),
                                  color: Colors.black,
                                ),
                                SizedBox(width: context.w(8)),
                                Text(
                                  timeString,
                                  style: CustomFonts.black14w600.copyWith(
                                    fontSize: context.sp(13),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildTypeBadge(
                            context,
                            type,
                            Colors.white,
                            timeStyle.copyWith(color: typeColor),
                          ),
                          if (appointment.status != null) ...[
                            SizedBox(height: context.h(10)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.w(12),
                                vertical: context.h(5),
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                  context.r(20),
                                ),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                appointment.status!.toUpperCase(),
                                style: CustomFonts.black10w600.copyWith(
                                  letterSpacing: 1.2,
                                  fontSize: context.sp(8.5),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Middle Section: Clinic & Doctor
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(18),
                vertical: context.h(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor & Clinic Row
                  Row(
                    children: [
                      // Clinic Info
                      if (appointment.clinic != null)
                        Expanded(
                          child: Row(
                            children: [
                              ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl:
                                      appointment.clinic?.clinicImage ?? "",
                                  height: context.w(32),
                                  width: context.w(32),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Container(color: Colors.grey.shade100),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: Colors.grey.shade100,
                                        child: const Icon(
                                          Icons.business,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),
                              SizedBox(width: context.w(10)),
                              Expanded(
                                child: Text(
                                  appointment.clinic!.clinicName ?? "N/A",
                                  style: CustomFonts.black14w600.copyWith(
                                    fontSize: context.sp(12),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(width: context.w(12)),
                      // Doctor Info
                      if (appointment.doctor != null)
                        Expanded(
                          child: Row(
                            children: [
                              ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl:
                                      appointment.doctor?.doctorImage ?? "",
                                  height: context.w(32),
                                  width: context.w(32),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Container(color: Colors.grey.shade100),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        color: Colors.grey.shade100,
                                        child: const Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                              ),
                              SizedBox(width: context.w(10)),
                              Expanded(
                                child: Text(
                                  appointment.doctor!.doctorName ?? "N/A",
                                  style: CustomFonts.black14w600.copyWith(
                                    fontSize: context.sp(12),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  if (appointment.treatments != null &&
                      appointment.treatments!.isNotEmpty) ...[
                    SizedBox(height: context.h(12)),
                    const Divider(height: 1, color: Colors.black12),
                    SizedBox(height: context.h(12)),

                    // Condition passed in via isTreatmentListHorizontal param.
                    // - Vertical, or only 1 treatment: expand full width.
                    // - Horizontal with multiple treatments: single line,
                    //   filling the width evenly, no scroll/wrap.
                    (!isTreatmentListHorizontal ||
                            appointment.treatments!.length == 1)
                        ? Column(
                            children: [
                              for (var t in appointment.treatments!)
                                _buildTreatmentTile(
                                  context,
                                  t,
                                  isHorizontal: false,
                                ),
                            ],
                          )
                        :
                          // Row(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           for (
                          //             var i = 0;
                          //             i < appointment.treatments!.length;
                          //             i++
                          //           ) ...[
                          Row(
                            spacing: context.w(10),
                            children: [
                              Expanded(
                                child: _buildTreatmentTile(
                                  context,
                                  appointment.treatments![0],
                                  isHorizontal: true,
                                  // width: context.w(300),
                                ),
                              ),
                              CircleAvatar(
                                child: Padding(
                                  padding: .all(5.w),
                                  child: Text(
                                    '+${appointment.treatments!.length - 1}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                    //       if (i != appointment.treatments!.length - 1)
                    //         SizedBox(width: context.w(12)),
                    //     ],
                    //   ],
                    // ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentTile(
    BuildContext context,
    AppointmentTreatment t, {
    required bool isHorizontal,
    double? width,
  }) {
    return Container(
      width: width,
      margin: isHorizontal
          ? EdgeInsets.zero
          : EdgeInsets.only(bottom: context.h(12)),
      padding: EdgeInsets.symmetric(
        horizontal: context.w(12),
        vertical: context.h(10),
      ),
      decoration: BoxDecoration(
        image: DecorationImage(
          colorFilter: ColorFilter.mode(
            Colors.white.withValues(alpha: 0.35),
            BlendMode.modulate,
          ),
          image: CachedNetworkImageProvider(t.treatmentImage ?? ""),
          fit: BoxFit.cover,
        ),
        color: CustomColors.lightPurpleColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(
          color: CustomColors.lightPurpleColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // ClipRRect(
          //   borderRadius: BorderRadius.circular(
          //     context.r(12),
          //   ),
          //   child: CachedNetworkImage(
          //     imageUrl: t.treatmentImage ?? "",
          //     height: context.w(40),
          //     width: context.w(40),
          //     fit: BoxFit.cover,
          //     placeholder: (context, url) => Container(
          //       color: Colors.white,
          //       child: const Center(
          //         child: CupertinoActivityIndicator(
          //           radius: 8,
          //         ),
          //       ),
          //     ),
          //     errorWidget: (context, url, error) => Container(
          //       color: Colors.white,
          //       padding: EdgeInsets.all(context.w(8)),
          //       child: Icon(
          //         Icons.auto_awesome_rounded,
          //         size: context.sp(14),
          //         color: CustomColors.purpleColor,
          //       ),
          //     ),
          //   ),
          // ),
          SizedBox(width: context.w(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.treatmentName ?? "N/A",
                        style: CustomFonts.black14w600.copyWith(
                          fontSize: context.sp(13),
                        ),
                      ),
                    ),
                    if (t.status != null)
                      Text(
                        t.status!.toUpperCase(),
                        style: TextStyle(
                          color: _getTreatmentStatusColor(t.status!),
                          fontSize: context.sp(9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: context.h(4)),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        "Area: ${t.areaName ?? 'N/A'}",
                        style: CustomFonts.grey900_10w400.copyWith(
                          fontSize: context.sp(11),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (t.material != null) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: context.w(6)),
                        child: Text(
                          "•",
                          style: TextStyle(
                            color: Colors.grey.shade300,
                            fontSize: context.sp(10),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.w(6),
                            vertical: context.h(2),
                          ),
                          decoration: BoxDecoration(
                            color: CustomColors.darkPurple.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(context.r(4)),
                          ),
                          child: Text(
                            "${t.material!.selectedQuantity} ${t.material!.name}",
                            style: CustomFonts.darkPurple10w700.copyWith(
                              fontSize: context.sp(10),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (t.startTime != null || t.endTime != null) ...[
                  SizedBox(height: context.h(4)),
                  Text(
                    "${t.startTime != null ? DateTimeUtils.formatTimestampToTime(t.startTime!) : '--:--'} - ${t.endTime != null ? DateTimeUtils.formatTimestampToTime(t.endTime!) : '--:--'}",
                    style: CustomFonts.grey700_10w400.copyWith(
                      fontSize: context.sp(10),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            size: context.sp(18),
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  Color _getTreatmentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'start':
        return Colors.blue;
      case 'end':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case "consultation":
        return CustomColors.blueColor;
      case "treatment session":
        return CustomColors.pinkColor;
      default:
        return CustomColors.purpleColor;
    }
  }

  TextStyle _getTimeStyle(String type) {
    switch (type.toLowerCase()) {
      case "consultation":
        return CustomFonts.blue10w700;
      case "treatment session":
        return CustomFonts.pink10w700;
      default:
        return CustomFonts.blue10w700;
    }
  }

  Widget _buildTypeBadge(
    BuildContext context,
    String type,
    Color color,
    TextStyle textStyle,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(8),
        vertical: context.h(3),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Text(type, style: textStyle.copyWith(fontSize: context.sp(10))),
    );
  }
}
