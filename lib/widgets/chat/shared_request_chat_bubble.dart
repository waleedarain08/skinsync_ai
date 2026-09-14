import 'dart:io';

import 'package:before_after/before_after.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../../models/responses/messages_response.dart';
import '../../screens/patient_treatment_request_detail_screen.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';

class SharedRequestChatBubble extends StatefulWidget {
  final Message message;

  const SharedRequestChatBubble({super.key, required this.message});

  @override
  State<SharedRequestChatBubble> createState() =>
      _SharedRequestChatBubbleState();
}

class _SharedRequestChatBubbleState extends State<SharedRequestChatBubble> {
  String _selectedPose = 'front';
  double _sliderValue = 0.5;

  @override
  Widget build(BuildContext context) {
    final isMe = widget.message.isMe;
    final request = widget.message.sharedRequestData;

    if (request == null) {
      return Container(
        constraints: BoxConstraints(maxWidth: context.w(340)),
        padding: EdgeInsets.all(context.r(16)),
        decoration: BoxDecoration(
          color: CustomColors.whiteColor,
          borderRadius: BorderRadius.circular(context.r(16)),
          border: Border.all(color: CustomColors.greyColor),
        ),
        child: Text(
          (widget.message.content?.isNotEmpty ?? false)
              ? widget.message.content!
              : 'Shared Treatment Request Data Unavailable',
          style: CustomFonts.black14w400,
        ),
      );
    }

    // Determine available image poses
    final hasFront = (request.frontImageBefore?.isNotEmpty ?? false) ||
        (request.frontImageAfter?.isNotEmpty ?? false);
    final hasLeft = (request.leftImageBefore?.isNotEmpty ?? false) ||
        (request.leftImageAfter?.isNotEmpty ?? false);
    final hasRight = (request.rightImageBefore?.isNotEmpty ?? false) ||
        (request.rightImageAfter?.isNotEmpty ?? false);

    final hasAnyImage = hasFront || hasLeft || hasRight;

    // Active pose images
    String? beforeUrl;
    String? afterUrl;

    if (_selectedPose == 'left' && hasLeft) {
      beforeUrl = request.leftImageBefore;
      afterUrl = request.leftImageAfter;
    } else if (_selectedPose == 'right' && hasRight) {
      beforeUrl = request.rightImageBefore;
      afterUrl = request.rightImageAfter;
    } else {
      beforeUrl = request.frontImageBefore;
      afterUrl = request.frontImageAfter;
    }

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          PatientTreatmentRequestDetailScreen.routeName,
          arguments: request.toSimulationData(),
        );
      },
      child: Container(
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
            // Header Row
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

            // Optional text/content (display only if human text, not raw JSON)
            if (request.text != null &&
                request.text!.isNotEmpty &&
                !request.text!.trim().startsWith('{') &&
                !request.text!.trim().startsWith('[')) ...[
              Text(request.text!, style: CustomFonts.black14w400),
              SizedBox(height: context.h(12)),
            ] else if (widget.message.content != null &&
                widget.message.content!.isNotEmpty &&
                !widget.message.content!.trim().startsWith('{') &&
                !widget.message.content!.trim().startsWith('[')) ...[
              Text(widget.message.content!, style: CustomFonts.black14w400),
              SizedBox(height: context.h(12)),
            ],

            // Patient Info Box
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

            // --- BEFORE / AFTER IMAGE SLIDER VIEW SECTION ---
            if (hasAnyImage) ...[
              SizedBox(height: context.h(12)),
              // Pose Selection Chips
              Row(
                children: [
                  if (hasFront) _buildPoseChip('Front', 'front'),
                  if (hasLeft) _buildPoseChip('Left', 'left'),
                  if (hasRight) _buildPoseChip('Right', 'right'),
                ],
              ),
              SizedBox(height: context.h(8)),

              // Image Slider Card
              ClipRRect(
                borderRadius: BorderRadius.circular(context.r(12)),
                child: Container(
                  height: context.h(200),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(context.r(12)),
                    border: Border.all(color: CustomColors.greyColor),
                  ),
                  child: Stack(
                    children: [
                      if (beforeUrl != null && afterUrl != null)
                        BeforeAfter(
                          value: _sliderValue,
                          onValueChanged: (v) => setState(() => _sliderValue = v),
                          before: _buildImageWidget(afterUrl),
                          after: _buildImageWidget(beforeUrl),
                          trackColor: Colors.white,
                          trackWidth: 2,
                        )
                      else if (beforeUrl != null)
                        _buildImageWidget(beforeUrl)
                      else if (afterUrl != null)
                        _buildImageWidget(afterUrl)
                      else
                        const Center(
                          child: Text(
                            'Image not available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),

                      // BEFORE Badge
                      if (beforeUrl != null)
                        Positioned(
                          top: context.h(8),
                          left: context.w(8),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(8),
                              vertical: context.h(3),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(context.r(4)),
                            ),
                            child: Text(
                              'BEFORE',
                              style: CustomFonts.white10w600,
                            ),
                          ),
                        ),

                      // AFTER Badge
                      if (afterUrl != null)
                        Positioned(
                          top: context.h(8),
                          right: context.w(8),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(8),
                              vertical: context.h(3),
                            ),
                            decoration: BoxDecoration(
                              color: CustomColors.darkPurple.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(context.r(4)),
                            ),
                            child: Text(
                              'AFTER',
                              style: CustomFonts.white10w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],

            // Requested Treatments List
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
      ),
    );
  }

  Widget _buildPoseChip(String label, String value) {
    final isSelected = _selectedPose == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPose = value),
      child: Container(
        margin: EdgeInsets.only(right: context.w(6)),
        padding: EdgeInsets.symmetric(
          horizontal: context.w(12),
          vertical: context.h(4),
        ),
        decoration: BoxDecoration(
          color: isSelected ? CustomColors.darkPurple : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(context.r(16)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: context.sp(11),
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black87,
            fontFamily: 'Degular',
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String pathOrUrl) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: pathOrUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } else {
      return Image.file(
        File(pathOrUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    }
  }
}
