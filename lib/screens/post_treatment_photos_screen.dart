import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../models/responses/appointment_detail_response.dart';
import '../models/responses/post_treatment_photo_model.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/string_utils.dart';
import '../view_models/post_treatment_photo_view_model.dart';
import '../widgets/dialogs/image_source_dialog.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';

class PostTreatmentPhotosScreen extends ConsumerWidget {
  static const String routeName = "/PostTreatmentPhotosScreen";
  final List<DetailedAppointmentTreatment>? treatments;

  const PostTreatmentPhotosScreen({super.key, this.treatments});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoState = ref.watch(postTreatmentPhotoProvider);
    final allPhotoItems = photoState.photoItems;

    final itemsToShow = <PostTreatmentPhotoItem>[];
    if (treatments != null && treatments!.isNotEmpty) {
      for (var t in treatments!) {
        final match = allPhotoItems.firstWhere(
          (item) {
            final tNameMatch =
                item.treatmentName.toLowerCase().contains(
                      (t.treatmentName ?? '').toLowerCase(),
                    ) ||
                (t.treatmentName ?? '').toLowerCase().contains(
                      item.treatmentName.toLowerCase(),
                    );
            final areaMatch = t.areaName == null ||
                t.areaName!.isEmpty ||
                (item.areaName ?? '').toLowerCase().contains(
                      t.areaName!.toLowerCase(),
                    ) ||
                t.areaName!.toLowerCase().contains(
                      (item.areaName ?? '').toLowerCase(),
                    );
            return tNameMatch && areaMatch;
          },
          orElse: () => PostTreatmentPhotoItem(
            treatmentId: t.treatmentId ?? 0,
            treatmentName: t.treatmentName ?? "Treatment",
            areaName: t.areaName,
            requirePostTreatmentPhotos: true,
            photoMilestones: [
              PhotoMilestoneItem(
                numberOfDays: 3,
                requiredPhotos: 2,
                title: "Day 3 Recovery Check",
              ),
              PhotoMilestoneItem(
                numberOfDays: 7,
                requiredPhotos: 2,
                title: "Day 7 Progress Check",
              ),
            ],
          ),
        );
        itemsToShow.add(match);
      }
    } else {
      itemsToShow.addAll(allPhotoItems);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: const CustomAppBar(title: "Post-Treatment Photos"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(10),
          context.w(20),
          context.h(40),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBanner(context),
            SizedBox(height: context.h(24)),
            ...itemsToShow.map(
              (item) => _buildTreatmentPhotoSection(context, ref, item: item),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(10),
          context.w(20),
          context.h(20) + MediaQuery.paddingOf(context).bottom,
        ),
        child: CustomButton(
          onPressed: () => Navigator.pop(context),
          text: "Done",
        ),
      ),
    );
  }

  Widget _buildTopBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.w(20)),
      decoration: BoxDecoration(
        gradient: CustomColors.purpleBlueGradient,
        borderRadius: BorderRadius.circular(context.r(24)),
        boxShadow: CustomColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.w(12)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Icon(
              Iconsax.camera,
              color: CustomColors.blackColor,
              size: context.sp(26),
            ),
          ),
          SizedBox(width: context.w(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Photo Milestone Requirements",
                  style: CustomFonts.black18w600,
                ),
                SizedBox(height: context.h(4)),
                Text(
                  "Your clinic requires photo updates at specific day milestones after treatment to track recovery.",
                  style: CustomFonts.black12w600.copyWith(
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentPhotoSection(
    BuildContext context,
    WidgetRef ref, {
    required PostTreatmentPhotoItem item,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: context.h(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.w(6)),
                decoration: BoxDecoration(
                  color: CustomColors.purpleColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.mask,
                  color: CustomColors.darkPurple,
                  size: context.sp(18),
                ),
              ),
              SizedBox(width: context.w(10)),
              Expanded(
                child: Text(
                  item.treatmentName.capitalize,
                  style: CustomFonts.black18w600,
                ),
              ),
              if (item.areaName != null && item.areaName!.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(10),
                    vertical: context.h(4),
                  ),
                  decoration: BoxDecoration(
                    color: CustomColors.darkPurple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(context.r(12)),
                  ),
                  child: Text(
                    item.areaName!,
                    style: CustomFonts.black12w600.copyWith(
                      color: CustomColors.darkPurple,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.h(12)),
          ...item.photoMilestones.map(
            (m) => _buildMilestoneCard(
              context,
              ref,
              treatmentId: item.treatmentId,
              milestone: m,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(
    BuildContext context,
    WidgetRef ref, {
    required int treatmentId,
    required PhotoMilestoneItem milestone,
  }) {
    final isCompleted = milestone.isCompleted;

    return Container(
      margin: EdgeInsets.only(bottom: context.h(16)),
      padding: EdgeInsets.all(context.w(18)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(24)),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: CustomColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(context.w(8)),
                    decoration: BoxDecoration(
                      color: CustomColors.darkPurple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.calendar_tick,
                      size: context.sp(18),
                      color: CustomColors.darkPurple,
                    ),
                  ),
                  SizedBox(width: context.w(10)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        milestone.title,
                        style: CustomFonts.black16w700,
                      ),
                      Text(
                        "Day ${milestone.numberOfDays} After Treatment • ${milestone.requiredPhotos} Photo(s) Required",
                        style: CustomFonts.grey12w400,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(10),
                  vertical: context.h(4),
                ),
                decoration: BoxDecoration(
                  color: (isCompleted ? Colors.green : Colors.orange)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.r(12)),
                ),
                child: Text(
                  isCompleted
                      ? "COMPLETED"
                      : "${milestone.uploadedPhotos.length}/${milestone.requiredPhotos} UPLOADED",
                  style: CustomFonts.blue10w700.copyWith(
                    color: isCompleted ? Colors.green : Colors.orange,
                    fontSize: context.sp(9),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(16)),

          Row(
            children: [
              ...milestone.uploadedPhotos.map(
                (photo) => Padding(
                  padding: EdgeInsets.only(right: context.w(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(context.r(16)),
                        child: photo.url.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: photo.url,
                                height: context.w(80),
                                width: context.w(80),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  height: context.w(80),
                                  width: context.w(80),
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  height: context.w(80),
                                  width: context.w(80),
                                  color: Colors.grey.shade100,
                                  child: const Icon(Icons.image_not_supported),
                                ),
                              )
                            : Image.file(
                                File(photo.url),
                                height: context.w(80),
                                width: context.w(80),
                                fit: BoxFit.cover,
                              ),
                      ),
                      if (photo.label != null) ...[
                        SizedBox(height: context.h(4)),
                        Text(
                          photo.label!,
                          style: CustomFonts.black12w600.copyWith(
                            color: Colors.grey,
                            fontSize: context.sp(10),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (!isCompleted)
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final source = await showImageSourceDialog(context);
                      if (source != null) {
                        ref
                            .read(postTreatmentPhotoProvider.notifier)
                            .addPhotoToMilestone(
                              treatmentId: treatmentId,
                              milestoneTitle: milestone.title,
                              source: source,
                            );
                      }
                    },
                    borderRadius: BorderRadius.circular(context.r(16)),
                    child: Container(
                      height: context.w(80),
                      decoration: BoxDecoration(
                        color: CustomColors.darkPurple.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(context.r(16)),
                        border: Border.all(
                          color: CustomColors.darkPurple.withValues(alpha: 0.3),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_rounded,
                            color: CustomColors.darkPurple,
                            size: context.sp(22),
                          ),
                          SizedBox(height: context.h(4)),
                          Text(
                            "Add Photo",
                            style: CustomFonts.black12w600.copyWith(
                              color: CustomColors.darkPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
