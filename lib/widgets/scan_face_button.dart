import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../screens/face_pose_capture_screen.dart';
import '../screens/consent_forms/face_consent_screen.dart';
import '../utils/assets.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../view_models/checkout_view_model.dart';
import '../view_models/treatment_requests_view_model.dart';
import '../view_models/treatment_view_model.dart';

class ScanFaceButton extends ConsumerWidget {
  // final VoidCallback onTap;
  const ScanFaceButton({
    super.key,
    //  required this.onTap
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        FaceConsentScreen.checkAndProceed(
          context: context,
          ref: ref,
          onProceed: () {
            ref.read(checkoutViewModel.notifier).clearState();
            ref.read(treatmentViewModel.notifier).clearAllSelectedTreatments();
            ref.read(treatmentViewModel.notifier).clearAiImage();
            ref.read(treatmentRequestsProvider.notifier).clearSelectedGroup();
            Navigator.of(context).pushNamed(FacePoseCaptureScreen.routeName);
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(22),
          vertical: context.h(14),
        ),
        decoration: BoxDecoration(
          // color: CustomColors.lightBlueColor,
          gradient: CustomColors.purpleBlueGradient,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            // Outer glow
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 3,
            ),
            // Soft white diffuse glow
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              SvgAssets.faceId,
              colorFilter: const ColorFilter.mode(
                CustomColors.blackColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text("Scan Your Face", style: CustomFonts.black18w600),
          ],
        ),
      ),
    );
  }
}
