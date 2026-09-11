import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../models/responses/treatment_list_response.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../view_models/treatment_view_model.dart';
import '../widgets/app_loader.dart';
import '../widgets/custom_app_bar.dart';

class TreatmentDetailScreen extends ConsumerStatefulWidget {
  final TreatmentData treatments;

  const TreatmentDetailScreen({super.key, required this.treatments});

  static const String routeName = '/TreatmentDetailScreen';

  @override
  ConsumerState<TreatmentDetailScreen> createState() =>
      _TreatmentDetailScreenState();
}

class _TreatmentDetailScreenState
    extends ConsumerState<TreatmentDetailScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.treatments.id != null) {
        ref
            .read(treatmentViewModel.notifier)
            .calltreatmentDetail(id: widget.treatments.id!);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(treatmentViewModel).loading;
    final detail = ref.watch(treatmentViewModel).treatmentDetail;

    if (loading) {
      return Scaffold(
        backgroundColor: CustomColors.whiteColor,
        appBar: CustomAppBar(
          showTitle: true,
          title: widget.treatments.name ?? "Treatment Details",
        ),
        body: const Center(child: AppLoader()),
      );
    }

    if (detail == null) {
      return Scaffold(
        backgroundColor: CustomColors.whiteColor,
        appBar: CustomAppBar(
          showTitle: true,
          title: widget.treatments.name ?? "Treatment Details",
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(32)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: context.w(80),
                  width: context.w(80),
                  decoration: BoxDecoration(
                    color: CustomColors.purpleColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: context.sp(40),
                    color: CustomColors.purpleColor,
                  ),
                ),
                SizedBox(height: context.h(20)),
                Text(
                  "No Details Found",
                  style: CustomFonts.black20w600,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.h(8)),
                Text(
                  "We couldn't load the details for this treatment. Please try again later.",
                  style: CustomFonts.grey14w400,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.h(28)),
                SizedBox(
                  width: context.w(160),
                  child: OutlinedButton(
                    onPressed: () {
                      if (widget.treatments.id != null) {
                        ref
                            .read(treatmentViewModel.notifier)
                            .calltreatmentDetail(id: widget.treatments.id!);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.h(12)),
                      side: const BorderSide(color: CustomColors.purpleColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.r(24)),
                      ),
                    ),
                    child: Text(
                      "Retry",
                      style: CustomFonts.darkPurple14w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final String displayName =
        detail.name ?? detail.patientDisplayName ?? widget.treatments.name ?? "Treatment Details";

    return Scaffold(
      extendBody: true,
      backgroundColor: CustomColors.whiteColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Premium Curved Image Banner with Overlays
            Stack(
              children: [
                Hero(
                  tag: 'treatment_image_${detail.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(context.r(32)),
                    ),
                    child: Container(
                      height: context.h(310),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: CachedNetworkImage(
                        imageUrl: (detail.image != null && detail.image!.isNotEmpty)
                            ? detail.image!
                            : (widget.treatments.image ?? ''),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          decoration: const BoxDecoration(
                            gradient: CustomColors.purpleBlueGradient,
                          ),
                          child: const Center(
                            child: CupertinoActivityIndicator(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: const BoxDecoration(
                            gradient: CustomColors.purpleBlueGradient,
                          ),
                          child: const Icon(
                            Icons.broken_image_rounded,
                            color: Colors.white38,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Translucent Top & Bottom Gradients for Button readability
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(context.r(32)),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.45),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Floating Actions (Back Button)
                Positioned(
                  top: MediaQuery.paddingOf(context).top + context.h(10),
                  left: context.w(24),
                  right: context.w(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: context.w(42),
                          width: context.w(42),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.35),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              CupertinoIcons.arrow_left,
                              size: context.sp(20),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: context.h(24)),

            // 2. Title & Icon Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (detail.icon != null && detail.icon!.isNotEmpty)
                        CachedNetworkImage(
                          height: context.h(30),
                          width: context.w(30),
                          imageUrl: detail.icon!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            decoration: const BoxDecoration(
                              gradient: CustomColors.purpleBlueGradient,
                            ),
                            child: const Center(
                              child: CupertinoActivityIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: const BoxDecoration(
                              gradient: CustomColors.purpleBlueGradient,
                            ),
                            child: const Icon(
                              Icons.broken_image_rounded,
                              color: Colors.white38,
                              size: 40,
                            ),
                          ),
                        ),
                      if (detail.icon != null && detail.icon!.isNotEmpty)
                        SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          displayName,
                          style: CustomFonts.black28w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (detail.shortDescription != null && detail.shortDescription!.trim().isNotEmpty) ...[
              SizedBox(height: context.h(16)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                child: Text(
                  detail.shortDescription!.trim(),
                  style: CustomFonts.textGrey16w400.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],

            if (detail.description != null && detail.description!.trim().isNotEmpty) ...[
              SizedBox(height: context.h(20)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("About Treatment", style: CustomFonts.black18w600),
                    SizedBox(height: context.h(8)),
                    Text(
                      detail.description!.trim(),
                      style: CustomFonts.textGrey16w400.copyWith(
                        height: 1.5,
                        fontSize: context.sp(14),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (detail.selectedAreas != null && detail.selectedAreas!.isNotEmpty) ...[
              SizedBox(height: context.h(24)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Treatment Areas", style: CustomFonts.black18w600),
                    SizedBox(height: context.h(12)),
                    Wrap(
                      spacing: context.w(8),
                      runSpacing: context.h(8),
                      children: detail.selectedAreas!.map((area) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.w(12),
                            vertical: context.h(8),
                          ),
                          decoration: BoxDecoration(
                            color: CustomColors.purpleColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(context.r(20)),
                            border: Border.all(
                              color: CustomColors.purpleColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (area.icon != null && area.icon!.isNotEmpty) ...[
                                CachedNetworkImage(
                                  imageUrl: area.icon!,
                                  width: context.w(18),
                                  height: context.w(18),
                                  errorWidget: (context, url, error) => const Icon(
                                    Icons.spa_outlined,
                                    size: 16,
                                    color: CustomColors.purpleColor,
                                  ),
                                ),
                                SizedBox(width: context.w(6)),
                              ],
                              Text(
                                area.name ?? '',
                                style: CustomFonts.black13w600.copyWith(
                                  color: CustomColors.purpleColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],

            if (detail.preTreatmentInstructions != null &&
                detail.preTreatmentInstructions!.trim().isNotEmpty) ...[
              SizedBox(height: context.h(24)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                child: Container(
                  padding: EdgeInsets.all(context.w(16)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(context.r(16)),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.assignment_outlined, color: CustomColors.purpleColor),
                          SizedBox(width: context.w(8)),
                          Text("Pre-Treatment Instructions", style: CustomFonts.black16w600),
                        ],
                      ),
                      SizedBox(height: context.h(8)),
                      Text(
                        detail.preTreatmentInstructions!.trim(),
                        style: CustomFonts.textGrey16w400.copyWith(
                          fontSize: context.sp(13),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (detail.postTreatmentInstructions != null &&
                detail.postTreatmentInstructions!.trim().isNotEmpty) ...[
              SizedBox(height: context.h(16)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(24)),
                child: Container(
                  padding: EdgeInsets.all(context.w(16)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(context.r(16)),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.health_and_safety_outlined, color: CustomColors.purpleColor),
                          SizedBox(width: context.w(8)),
                          Text("Post-Treatment Instructions", style: CustomFonts.black16w600),
                        ],
                      ),
                      SizedBox(height: context.h(8)),
                      Text(
                        detail.postTreatmentInstructions!.trim(),
                        style: CustomFonts.textGrey16w400.copyWith(
                          fontSize: context.sp(13),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: context.h(40)),
          ],
        ),
      ),
    );
  }
}
