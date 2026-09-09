import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../utils/assets.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/secure_storage_service.dart';
import '../view_models/checkout_view_model.dart';
import '../view_models/treatment_view_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/treatment_container.dart';
import 'ar_face_model_preview_screen.dart';
import 'bottom_nav_screens/face_detection_screen.dart';

class FacePoseCaptureScreen extends ConsumerStatefulWidget {
  static const String routeName = '/FacePoseCaptureScreen';

  const FacePoseCaptureScreen({super.key});

  @override
  ConsumerState<FacePoseCaptureScreen> createState() => _FacePoseCaptureScreenState();
}

class _FacePoseCaptureScreenState extends ConsumerState<FacePoseCaptureScreen> {
  @override
  void initState() {
    super.initState();
    SecureStorage().clearCaptureMode();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(treatmentViewModel);

    final bool allCaptured =
        state.frontPoseImage != null &&
        state.leftPoseImage != null &&
        state.rightPoseImage != null;

    return PopScope(
      onPopInvokedWithResult: (_, _) {
        ref.read(checkoutViewModel.notifier).clearState();
        ref
            .read(treatmentViewModel.notifier)
            .clearAllSelectedTreatments(capturedImage: true);
        ref.read(treatmentViewModel.notifier).clearAiImage();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(
          showTitle: true,
          title: "Capture Your Profile",
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.h(20)),
                    Text(
                      "Clear photos from multiple angles ensure our AI provides the most precise treatment recommendations for your unique features.",
                      style: CustomFonts.grey14w400.copyWith(height: 1.4),
                    ),
                    SizedBox(height: context.h(24)),
                    Row(
                      children: [
                        _buildIndicator(
                          context: context,
                          active: true,
                          color: CustomColors.purpleColor,
                        ),
                        SizedBox(width: context.w(8)),
                        _buildIndicator(
                          context: context,
                          active: state.frontPoseImage != null,
                          color: CustomColors.purpleColor,
                        ),
                        SizedBox(width: context.w(8)),
                        _buildIndicator(
                          context: context,
                          active:
                              state.leftPoseImage != null &&
                              state.rightPoseImage != null,
                          color: CustomColors.purpleColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: context.h(24)),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                  children: [
                    _buildPoseContainer(
                      context: context,
                      title: "Front Profile",
                      subtitle: "Look straight into the camera",
                      image: state.frontPoseImage,
                      onTap: () => _handlePoseTap(context, 'front'),
                    ),
                    _buildPoseContainer(
                      context: context,
                      title: "Left Profile",
                      subtitle: "Turn your face to the right",
                      image: state.leftPoseImage,
                      onTap: () => _handlePoseTap(context, 'left'),
                    ),
                    _buildPoseContainer(
                      context: context,
                      title: "Right Profile",
                      subtitle: "Turn your face to the left",
                      image: state.rightPoseImage,
                      onTap: () => _handlePoseTap(context, 'right'),
                    ),
                    SizedBox(height: context.h(40)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(context.w(24)),
                child: CustomButton(
                  text: "Proceed to AI Preview",
                  onPressed: allCaptured
                      ? () {
                          ref.read(treatmentViewModel.notifier).clearAiImage();
                          Navigator.pushNamed(
                            context,
                            ArFaceModelPreviewScreen.routeName,
                          );
                        }
                      : null,
                  // textColor: allCaptured ? Colors.white : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator({
    required BuildContext context,
    required bool active,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: context.h(3),
        decoration: BoxDecoration(
          color: active ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(context.r(2)),
        ),
      ),
    );
  }

  void _handlePoseTap(BuildContext context, String pose) {
    _capturePose(context, pose);
  }

  void _capturePose(BuildContext context, String pose) {
    Navigator.pushNamed(
      context,
      FaceDetectionScreen.routeName,
      arguments: pose,
    );
  }

  Widget _buildPoseContainer({
    required BuildContext context,
    required String title,
    required String subtitle,
    required XFile? image,
    required VoidCallback onTap,
  }) {
    final String poseLabel = title.toLowerCase().contains("front")
        ? "front pose"
        : title.toLowerCase().contains("left")
        ? "side pose (left)"
        : "side pose (right)";

    final String placeholderAsset = title.toLowerCase().contains("front")
        ? PngAssets.frontFace
        : title.toLowerCase().contains("left")
        ? PngAssets.leftFace
        : PngAssets.rightFace;

    return TreatmentContainer(
      imageHeight: context.h(300),
      customTitle: title,
      customSubtitle: subtitle,
      customOnTap: onTap,
      backgroundWidget: image != null
          ? Image.file(File(image.path), fit: BoxFit.cover)
          : Image.asset(placeholderAsset, fit: BoxFit.cover),
      topRightWidget: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(10),
          vertical: context.h(4),
        ),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(context.r(4)),
        ),
        child: Text(
          poseLabel,
          style: CustomFonts.white10w600.copyWith(fontSize: context.sp(10)),
        ),
      ),
    );
  }
}
