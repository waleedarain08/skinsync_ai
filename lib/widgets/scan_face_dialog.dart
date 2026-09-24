import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../screens/face_pose_capture_screen.dart';
import '../screens/consent_forms/face_consent_screen.dart';
import '../screens/treatment_request_detail_screen.dart';
import '../screens/treatment_requests_screen.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../view_models/treatment_requests_view_model.dart';
import 'custom_button.dart';
import 'dialogs/save_option_confirmation_dialog.dart';

void showMScanFaceDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true, // tap outside to close
    builder: (dialogContext) {
      return Consumer(
        builder: (context, ref, _) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.r(24)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(24),
                vertical: context.h(32),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Beautiful Branded Icon Badge
                  Container(
                    height: context.w(72),
                    width: context.w(72),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CustomColors.purpleColor.withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.face_retouching_natural_rounded,
                        size: context.sp(32),
                        color: CustomColors.darkPurple,
                      ),
                    ),
                  ),
                  SizedBox(height: context.h(24)),

                  Text("Get Started", style: CustomFonts.black24w600),
                  SizedBox(height: context.h(12)),

                  // Description
                  Text(
                    "Scan your face to get personalized skin analysis or explore nearby clinics for professional treatments.",
                    textAlign: TextAlign.center,
                    style: CustomFonts.textGrey14w400,
                  ),
                  SizedBox(height: context.h(28)),

                  // Button 1: Scan Face (Primary Black Button)
                  CustomButton(
                    text: "Scan Your Face",
                    borderRadius: context.r(26),
                   
                    onPressed: () {
                      Navigator.pop(dialogContext); // close dialog
                      FaceConsentScreen.checkAndProceed(
                        context: context,
                        ref: ref,
                        onProceed: () {
                          Navigator.of(
                            context,
                          ).pushNamed(FacePoseCaptureScreen.routeName);
                        },
                      );
                    },
                  ),
                 SizedBox(height: context.h(12)),

                  // Button 2: Select Treatment Areas (Secondary Button)
                  Consumer(
                    builder: (consumerContext, ref, _) {
                      return CustomButton(
                        isBorder: true,
                        text: "Save Option",
                       
                        borderRadius: context.r(26),
                        onPressed: () {
                         final journeyState = ref.read(treatmentRequestsProvider);
    final selectedGroup = journeyState.selectedGroup;

    if (selectedGroup == null) {
      Navigator.pushNamed(
        context,
        TreatmentRequestsScreen.routeName,
        arguments: false,
      );
    } else {
      showSaveOptionConfirmationDialog(
        screenContext: context,
        groupName: selectedGroup.name ?? 'Unknown Group',
        onConfirm: () async {
          final result = await ref
              .read(treatmentRequestsProvider.notifier)
              .createTjOptions();
          if (result == true) {
            final result2 = await ref
                .read(treatmentRequestsProvider.notifier)
                .fetchOptions(selectedGroup.id ?? 0);
            if (result2 == true) {
              Navigator.popUntil(
                context,
                ModalRoute.withName(TreatmentRequestDetailScreen.routeName),
              );
            }
            // rootScaffoldMessengerKey.currentState?.showSnackBar(
            //         SnackBar(
            //           content: const Text(
            //             'Your journey is ready! Tap the Journey button in the top-right corner to view it.',
            //           ),
            //           duration: const Duration(seconds: 3),
            //           persist: false,
            //           behavior: SnackBarBehavior.floating,
            //           margin: EdgeInsets.only(
            //             left: context.w(16),
            //             right: context.w(16),
            //             bottom: context.h(80),
            //           ),
            //           action: SnackBarAction(
            //             label: '✕',
            //             onPressed: () {
            //               rootScaffoldMessengerKey.currentState
            //                   ?.hideCurrentSnackBar();
            //             },
            //           ),
            //         ),
            //       );
            final groupId = ref
                .read(treatmentRequestsProvider)
                .selectedGroup
                ?.id;
            if (groupId != null) {
              await ref
                  .read(treatmentRequestsProvider.notifier)
                  .fetchOptions(groupId, showloading: false);
            }
          }
        },
      );
    }
                        },
                      );
                    },
                  ),
               
                ],
              ),
            ),
          );
        }
      );
    },
  );

  
}
