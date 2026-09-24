import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../../models/responses/appointment_detail_response.dart';
import '../../models/responses/messages_response.dart';
import '../../screens/appointment_forms_screen.dart';
import '../../utils/custom_fonts.dart';
import '../../view_models/appointment_view_model.dart';
import '../borderd_container_widget.dart';
import '../custom_button.dart';

class ConsentFormChatBubble extends StatelessWidget {
  final Message message;

  const ConsentFormChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final apptData = message.appointmentData;
    final apptId = apptData?.id;
    final apptKey = apptData?.appointmentKey?? 'N/A';
    final doctorName = apptData?.doctor?.name ?? message.senderName ?? 'Doctor';
    final contentText = message.content ?? '';

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
          color: Colors.amber.shade700,
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
                  color: Colors.amber.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.document_text_1,
                  size: context.sp(16),
                  color: Colors.amber.shade900,
                ),
              ),
              SizedBox(width: context.w(8)),
              Expanded(
                child: Text(
                  "Consent Form Required",
                  style: CustomFonts.black14w700.copyWith(
                    color: Colors.amber.shade900,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(8),
                  vertical: context.h(3),
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade700,
                  borderRadius: BorderRadius.circular(context.r(10)),
                ),
                child: Text(
                  "SIGN FORM",
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
            backgroundColor: const Color(0xFFFFFBEB),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contentText.isNotEmpty
                      ? contentText
                      : "Dr. $doctorName has shared a new consent form. Please sign this form to complete your appointment requirements.",
                  style: CustomFonts.black13w600.copyWith(
                    height: 1.35,
                  ),
                ),
                SizedBox(height: context.h(6)),
                Text(
                  "Digital signature required prior to session execution.",
                  style: CustomFonts.grey12w400.copyWith(
                    fontSize: context.sp(11),
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: context.h(14)),

          // Interactive Action Button
          Consumer(
            builder: (_, ref, _) {
              return CustomButton(
                text: "Sign Form & View Details",
                height: context.h(44),
                borderRadius: context.r(12),
                onPressed: () {
                  if (apptData != null) {
                    Navigator.pushNamed(
                      context,
                      AppointmentFormsScreen.routeName,
                      arguments: apptData,
                    );
                  } else if (apptId != null && apptId > 0) {
                    ref
                        .read(appointmentProvider.notifier)
                        .getAppointmentDetail(apptId);
                    Navigator.pushNamed(
                      context,
                      AppointmentFormsScreen.routeName,
                      arguments: AppointmentDetailData(id: apptId, appointmentKey: apptKey),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Opening consent forms..."),
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
