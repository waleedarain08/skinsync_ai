import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../../models/responses/appointments_list_response.dart';
import '../../models/responses/messages_response.dart';
import '../../screens/appointment_detail_screen.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../../view_models/appointment_view_model.dart';
import '../borderd_container_widget.dart';
import '../custom_button.dart';

class SessionCompletedChatBubble extends StatelessWidget {
  final Message message;

  const SessionCompletedChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    final sessionData = message.sessionCompletionData;
    final apptData = message.appointmentData;

    final apptId = sessionData?.appointmentId ??
        apptData?.id;

    final apptKey = sessionData?.appointmentKey ??
        apptData?.appointmentKey ??
        'N/A';

    final doctorName = sessionData?.doctorName ??
        apptData?.doctor?.name ??
        message.senderName ??
        'Doctor';

    final treatmentName = sessionData?.treatmentName ?? 'Treatment';
    final areaName = sessionData?.areaName ?? '';
    final durationStr = sessionData?.duration ?? '';
    final notes = sessionData?.notes ?? message.content ?? '';

    return Container(
      constraints: BoxConstraints(maxWidth: context.w(320)),
      padding: EdgeInsets.all(context.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.r(16)),
          topRight: Radius.circular(context.r(16)),
          bottomLeft: Radius.circular(isMe ? context.r(16) : context.r(2)),
          bottomRight: Radius.circular(isMe ? context.r(2) : context.r(16)),
        ),
        border: Border.all(
          color: Colors.green.shade500,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Badge
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.w(6)),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.timer_sharp,
                  size: context.sp(16),
                  color: Colors.green.shade700,
                ),
              ),
              SizedBox(width: context.w(8)),
              Expanded(
                child: Text(
                  "Session Completed",
                  style: CustomFonts.black14w700.copyWith(
                    color: Colors.green.shade900,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(8),
                  vertical: context.h(3),
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(context.r(10)),
                ),
                child: Text(
                  "RECORDED",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.sp(9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: context.h(12)),

          // Message Body Card
          BorderdContainerWidget(
            padding: EdgeInsets.all(context.w(12)),
            backgroundColor: const Color(0xFFF8F9FE),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notes.isNotEmpty
                      ? notes
                      : "Dr. $doctorName has completed the treatment session for $treatmentName ${areaName.isNotEmpty ? 'on $areaName' : ''} ${durationStr.isNotEmpty ? 'with duration ($durationStr)' : ''}.",
                  style: CustomFonts.black13w600.copyWith(
                    height: 1.35,
                  ),
                ),
                if (durationStr.isNotEmpty) ...[
                  SizedBox(height: context.h(8)),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: context.sp(14),
                        color: Colors.green.shade800,
                      ),
                      SizedBox(width: context.w(6)),
                      Text(
                        "Duration: $durationStr",
                        style: CustomFonts.black12w600.copyWith(
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                ],
                if (apptKey != 'N/A') ...[
                  SizedBox(height: context.h(6)),
                  Row(
                    children: [
                      Icon(
                        Iconsax.key,
                        size: context.sp(14),
                        color: CustomColors.darkPurple,
                      ),
                      SizedBox(width: context.w(6)),
                      Text(
                        "Ref: $apptKey",
                        style: CustomFonts.darkPurple12w600,
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: context.h(14)),

          // Interactive Action Button
          Consumer(
            builder: (_, ref, _) {
              return CustomButton(
                text: "View Session Summary",
                height: context.h(44),
                borderRadius: context.r(12),
                onPressed: () {
                  log('APPT ID: $apptId');
                  if (apptId != null && apptId > 0) {
                    ref
                        .read(appointmentProvider.notifier)
                        .getAppointmentDetail(apptId);
                    Navigator.pushNamed(
                      context,
                      AppointmentDetailScreen.routeName,
                      arguments: AppointmentItem(
                        appointmentId: apptId,
                        appointmentKey: apptKey,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
