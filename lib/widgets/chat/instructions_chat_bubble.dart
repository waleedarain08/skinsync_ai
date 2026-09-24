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

class InstructionsChatBubble extends StatelessWidget {
  final Message message;

  const InstructionsChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final apptData = message.appointmentData;
    final apptId = apptData?.id;
    final apptKey = apptData?.appointmentKey ?? 'N/A';
    final contentText = message.content ?? '';

    final isPost = contentText.toLowerCase().contains('post-treatment') ||
        contentText.toLowerCase().contains('aftercare');

    final title = isPost
        ? "Post-Care Guidelines"
        : "Pre-Care Guidelines";

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
          color: CustomColors.purpleColor.withValues(alpha: 0.5),
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
                decoration: const BoxDecoration(
                  color: CustomColors.lightPurpleColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPost ? Iconsax.clipboard_tick : Iconsax.clipboard_text,
                  size: context.sp(16),
                  color: CustomColors.darkPurple,
                ),
              ),
              SizedBox(width: context.w(8)),
              Expanded(
                child: Text(
                  title,
                  style: CustomFonts.black14w700.copyWith(
                    color: CustomColors.darkPurple,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(8),
                  vertical: context.h(3),
                ),
                decoration: BoxDecoration(
                  color: CustomColors.lightPurpleColor,
                  borderRadius: BorderRadius.circular(context.r(10)),
                ),
                child: Text(
                  isPost ? "POST-CARE" : "PRE-CARE",
                  style: TextStyle(
                    color: CustomColors.darkPurple,
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
            child: Text(
              contentText.isNotEmpty
                  ? contentText
                  : "Care instructions have been updated for your session. Kindly review them in your appointment details.",
              style: CustomFonts.black13w600.copyWith(
                height: 1.35,
              ),
            ),
          ),

          SizedBox(height: context.h(14)),

          // Interactive Action Button
          Consumer(
            builder: (_, ref, _) {
              return CustomButton(
                text: "View Care Instructions",
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
