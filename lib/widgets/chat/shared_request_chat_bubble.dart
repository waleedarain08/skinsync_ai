import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../models/responses/messages_response.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';

class SharedRequestChatBubble extends StatelessWidget {
  final Message message;

  const SharedRequestChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final request = message.sharedRequestData;

    if (request == null) {
      return Container(
        padding: EdgeInsets.all(context.r(16)),
        decoration: BoxDecoration(
          color: CustomColors.whiteColor,
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(color: CustomColors.greyColor),
        ),
        child: Text(
          (message.content?.isNotEmpty ?? false)
              ? message.content!
              : 'Shared Treatment Request Data Unavailable',
          style: CustomFonts.black14w400,
        ),
      );
    }

    return Container(
      constraints: BoxConstraints(maxWidth: context.w(340)),
      padding: EdgeInsets.all(context.r(16)),
      decoration: BoxDecoration(
        color: CustomColors.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.r(16)),
          topRight: Radius.circular(context.r(16)),
          bottomLeft: Radius.circular(isMe ? context.r(16) : context.r(2)),
          bottomRight: Radius.circular(isMe ? context.r(2) : context.r(16)),
        ),
        border: Border.all(
          color: CustomColors.darkPurple.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(context.r(6)),
                      decoration: const BoxDecoration(
                        color: CustomColors.lightPurpleColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.assignment_outlined,
                        size: context.sp(16),
                        color: CustomColors.darkPurple,
                      ),
                    ),
                    SizedBox(width: context.w(8)),
                    Expanded(
                      child: Text(
                        request.name.isNotEmpty
                            ? request.name
                            : 'Shared Treatment Request',
                        style: CustomFonts.darkPurple12w600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(12)),
          if (message.content?.isNotEmpty ?? false) ...[
            Text(message.content!, style: CustomFonts.black14w400),
            SizedBox(height: context.h(12)),
          ],
          Container(
            padding: EdgeInsets.all(context.r(12)),
            decoration: BoxDecoration(
              color: CustomColors.greyColor,
              borderRadius: BorderRadius.circular(context.r(12)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: context.r(20),
                  backgroundColor: CustomColors.lightPurpleColor,
                  child: Text(
                    request.patientName != null &&
                        request.patientName!.isNotEmpty
                        ? request.patientName![0].toUpperCase()
                        : 'P',
                    style: TextStyle(
                      fontSize: context.sp(14),
                      fontWeight: FontWeight.bold,
                      color: CustomColors.darkPurple,
                      fontFamily: 'Degular',
                    ),
                  ),
                ),
                SizedBox(width: context.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.patientName ?? 'Jane Cooper',
                        style: CustomFonts.black14w600,
                      ),
                      if (request.patientEmail != null) ...[
                        SizedBox(height: context.h(2)),
                        Text(
                          request.patientEmail!,
                          style: CustomFonts.grey12w400,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (request.treatments.isNotEmpty) ...[
            SizedBox(height: context.h(12)),
            Text('Requested Treatments:', style: CustomFonts.black13w600),
            SizedBox(height: context.h(8)),
            ...request.treatments.map((treatment) {
              return Container(
                margin: EdgeInsets.only(bottom: context.h(8)),
                padding: EdgeInsets.all(context.r(10)),
                decoration: BoxDecoration(
                  color: CustomColors.whiteColor,
                  borderRadius: BorderRadius.circular(context.r(8)),
                  border: Border.all(color: CustomColors.greyColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      treatment.treatmentName,
                      style: TextStyle(
                        fontSize: context.sp(13),
                        fontWeight: FontWeight.bold,
                        color: CustomColors.darkPurple,
                        fontFamily: 'Degular',
                      ),
                    ),
                    if (treatment.description != null &&
                        treatment.description!.isNotEmpty) ...[
                      SizedBox(height: context.h(2)),
                      Text(
                        treatment.description!,
                        style: CustomFonts.grey12w400,
                      ),
                    ],
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
