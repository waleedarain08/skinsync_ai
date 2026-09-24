import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../models/responses/messages_response.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../../utils/date_time_utils.dart';
import 'appointment_chat_bubble.dart';
import 'consent_form_chat_bubble.dart';
import 'document_chat_bubble.dart';
import 'instructions_chat_bubble.dart';
import 'media_chat_bubble.dart';
import 'normal_chat_bubble.dart';
import 'plan_approval_chat_bubble.dart';
import 'session_completed_chat_bubble.dart';
import 'shared_request_chat_bubble.dart';

class ChatMessageBubble extends StatelessWidget {
  final Message message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: context.h(16)),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: context.h(4)),
              child: Text(
                '${message.senderName}, ${message.createdAt?.formattedDateTime ?? ''}',
                style: CustomFonts.grey12w400,
              ),
            ),
            _buildTypedBubble(context),
            if (isMe) ...[
              SizedBox(height: context.h(4)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    message.isRead
                        ? Icons.done_all_rounded
                        : Icons.check_rounded,
                    size: context.sp(14),
                    color: CustomColors.darkPurple,
                  ),
                  SizedBox(width: context.w(4)),
                  Text(
                    message.isRead ? 'Read' : 'Sent',
                    style: TextStyle(
                      fontSize: context.sp(11),
                      fontWeight: FontWeight.w600,
                      color: CustomColors.darkPurple,
                      fontFamily: 'Degular',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypedBubble(BuildContext context) {

    return switch (message.type) {
      .media => MediaChatBubble(message: message),
      .document => DocumentChatBubble(message: message),
      .sharedRequest => SharedRequestChatBubble(message: message),
      .appointment => AppointmentChatBubble(message: message),
      .normal => NormalChatBubble(message: message),
      .text => NormalChatBubble(message: message),
      .planApproval => PlanApprovalChatBubble(message: message),
      .treatmentInstructions => InstructionsChatBubble(message: message),
      .sessionCompleted => SessionCompletedChatBubble(message: message),
      .consentForm => ConsentFormChatBubble(message: message),
      null => throw UnimplementedError(),
    };
  }
}
