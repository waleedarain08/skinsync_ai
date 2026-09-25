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

class PlanApprovalChatBubble extends StatelessWidget {
  final Message message;

  const PlanApprovalChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final apptData = message.appointmentData;
    final apptId = apptData?.id;
    final apptKey = apptData?.appointmentKey ?? 'N/A';
    // final doctorName = apptData?.doctor?.name ?? message.senderName ?? 'Doctor';

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
        border: Border.all(color: Colors.green.shade400, width: 1.5),
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
                  Icons.check_circle_rounded,
                  size: context.sp(16),
                  color: Colors.green.shade700,
                ),
              ),
              SizedBox(width: context.w(8)),
              Expanded(
                child: Text(
                  "Treatment Plan Confirmed",
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
                  apptData?.status?.toUpperCase() ?? 'N/A',
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
                  'Patient has confirmed the treatment plan.',
                  style: CustomFonts.black13w600.copyWith(height: 1.35),
                ),
                if (apptKey != 'N/A') ...[
                  SizedBox(height: context.h(8)),
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
                text: "View Treatment Plan Details",
                height: context.h(44),
                borderRadius: context.r(12),
                onPressed: () {
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
                        status: 'awaiting_patient',
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Opening appointment details..."),
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
