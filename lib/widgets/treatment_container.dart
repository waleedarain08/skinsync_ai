import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import '../screens/face_pose_capture_screen.dart';
import '../screens/consent_forms/face_consent_screen.dart';
import '../screens/treatment_detail_screen.dart';
import '../screens/treatment_area_screen.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../view_models/treatment_view_model.dart';
import 'app_network_image.dart';

import '../main.dart';
import '../models/responses/treatment_list_response.dart';
import '../view_models/checkout_view_model.dart';

class TreatmentContainer extends StatelessWidget {
  final double? imageHeight;
  final double? width;
  final TreatmentData? treatments;

  // Custom Adaptive Fields for Selection Screen Reusability
  final String? customTitle;
  final String? customSubtitle;
  final String? customImageUrl;
  final String? customIcon;
  final VoidCallback? customOnTap;
  final Widget? backgroundWidget;
  final Widget? topRightWidget;

  const TreatmentContainer({
    super.key,
    this.treatments,
    this.imageHeight,
    this.width,
    this.customTitle,
    this.customSubtitle,
    this.customImageUrl,
    this.customIcon,
    this.customOnTap,
    this.backgroundWidget,
    this.topRightWidget,
  });

  Widget? _buildLeftIcon(BuildContext context, String? iconKey) {
    // 1. If it's a network image URL, render it cleanly via AppNetworkImage
    return Container(
      margin: EdgeInsets.only(bottom: context.h(4)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(10)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
        ],
      ),
      child: AppNetworkImage(
        imageUrl: iconKey ?? '',
        width: context.w(38),
        height: context.w(38),
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(context.r(10)),
        errorIcon: Icons.broken_image,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isTreatmentData = treatments is TreatmentData;
        final treatmentData = isTreatmentData
            ? treatments as TreatmentData
            : null;

        final titleText = customTitle ?? treatments?.name ?? "";
        final subtitleText =
            customSubtitle ??
            treatmentData?.shortDescription ??
            "";
        final bgImage =
            customImageUrl ??
            treatmentData?.image ??
            treatments?.imageUrl ??
            "";
        final iconKey = customIcon ?? treatments?.icon;
        final iconWidget = iconKey != null && iconKey != '' ? _buildLeftIcon(context, iconKey) : null;
        final globalSku = treatmentData?.globalSku ?? "";
        final useInAiSimulator = treatmentData?.useInAiSimulator ?? false;

        return GestureDetector(
          onTap:
              customOnTap ??
              () {
                if (treatments == null) return;
                ref.read(checkoutViewModel.notifier).clearSelectedTreatments();
                ref
                    .read(checkoutViewModel.notifier)
                    .addSelectedTreatment(treatments!);
                if (treatments!.isArea == true) {
                  ref
                      .read(treatmentViewModel.notifier)
                      .onTapTreatment(
                        treatmentModel: treatments!,
                        isCallPredictAPI: false,
                      );
                }
                if (useInAiSimulator) {
                  // showMScanFaceDialog(context);
                  FaceConsentScreen.checkAndProceed(
                    context: context,
                    ref: ref,
                    onProceed: () {
                      Navigator.of(
                        context,
                      ).pushNamed(FacePoseCaptureScreen.routeName);
                    },
                  );
                } else {
                  Navigator.pushNamed(
                    context,
                    TreatmentAreaScreen.routeName,
                    arguments: {
                      'title': treatments!.name ?? 'Focus Areas',
                      'treatmentId': treatments!.id,
                    },
                  );
                }
              },
          child: Container(
            height: imageHeight ?? context.h(250),
            width: width ?? MediaQuery.sizeOf(context).width,
            margin: EdgeInsets.only(bottom: context.h(16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.r(20)),
              boxShadow: CustomColors.cardShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.r(20)),
              child: Stack(
                children: [
                  // 1. Full-Cover Image Background via AppNetworkImage or custom widget
                  Positioned.fill(
                    child: backgroundWidget ??
                        AppNetworkImage(
                          imageUrl: bgImage,
                          fit: BoxFit.cover,
                          placeholderColor: Colors
                              .transparent, // Keeps overlay visual hierarchy clean
                        ),
                  ),

                  // 2. Translucent Premium White Mask Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.20),
                              Colors.white,
                            ],
                          ),
                        ),
                      ),
                    ),

                  // 3. MedSpa Elegant Glow Layer on Left
                  /*
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: context.w(220),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            CustomColors.purpleColor.withValues(alpha: 0.15),
                            CustomColors.lightBlueColor.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
*/

                  // 4. Elegant Content Layer (Title, Description, and Chevron aligned to bottom)
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(context.w(22), context.h(12), context.w(22), context.h(16)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  titleText,
                                  style: CustomFonts.black22w600,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (subtitleText.isNotEmpty) ...[
                                  SizedBox(height: context.h(6)),
                                  Text(
                                    subtitleText,
                                    style: CustomFonts.grey12w400,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                if (globalSku.isNotEmpty) ...[
                                  SizedBox(height: context.h(6)),
                                  Text(
                                    "SKU: $globalSku",
                                    style: CustomFonts.grey12w400.copyWith(
                                      fontSize: context.sp(10),
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(width: context.w(10)),

                          // Translucent Circular Action Arrow
                          Container(
                            padding: EdgeInsets.all(context.w(10)),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.black87,
                              size: context.sp(22),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 5. Left-hand Icon on Top Left
                  if (iconWidget != null)
                    Positioned(top: context.h(12), left: context.w(12), child: iconWidget),

                  // Custom Top Right Widget (e.g. Pose Label)
                  if (topRightWidget != null)
                    Positioned(top: context.h(12), right: context.w(12), child: topRightWidget!),

                  // AI Compatible Badge
                 
                    Positioned(
                      top: context.h(12),
                      right: (treatments != null && !isDeploymentMode)
                          ? context.w(44)
                          : context.w(12),
                      child: Row(
                        children: [
                           if (useInAiSimulator)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: context.w(10),
                              vertical: context.h(5),
                            ),
                            decoration: BoxDecoration(
                              color: CustomColors.purpleColor.withValues(
                                alpha: 0.9,
                              ),
                              borderRadius: BorderRadius.circular(context.r(12)),
                              boxShadow: [
                                BoxShadow(
                                  color: CustomColors.purpleColor.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white,
                                  size: context.sp(10),
                                ),
                                SizedBox(width: context.w(4)),
                                Text(
                                  "AI Compatible",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: context.sp(9),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Degular',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width:4.w),
                          if (treatments != null)
                          GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            TreatmentDetailScreen.routeName,
                            arguments: treatments,
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: EdgeInsets.all(context.w(6)),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: context.sp(16),
                          ),
                        ),
                      ),
                   
                        ],
                      ),
                    ),

                  
                  
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
