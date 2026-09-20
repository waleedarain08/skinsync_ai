import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/responses/appointment_detail_response.dart';
import '../models/responses/post_treatment_instruction_model.dart';
import '../models/responses/pre_treatment_instruction_model.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/string_utils.dart';
import '../view_models/post_treatment_instruction_view_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';

class PostTreatmentInstructionsScreen extends ConsumerWidget {
  static const String routeName = "/PostTreatmentInstructionsScreen";
  final List<DetailedAppointmentTreatment>? treatments;

  const PostTreatmentInstructionsScreen({super.key, this.treatments});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructionState = ref.watch(postTreatmentInstructionProvider);
    final allInstructions = instructionState.instructions;

    final itemsToShow = <PostTreatmentInstructionItem>[];
    if (treatments != null && treatments!.isNotEmpty) {
      for (var t in treatments!) {
        final match = allInstructions.firstWhere(
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
          orElse: () => PostTreatmentInstructionItem(
            treatmentId: t.treatmentId ?? 0,
            treatmentName: t.treatmentName ?? "Aftercare Care",
            areaName: t.areaName,
            postTreatmentInstructions:
                "• Keep treatment area clean.\n• Avoid direct sun exposure and strenuous exercise for 24-48 hours.",
          ),
        );
        itemsToShow.add(match);
      }
    } else {
      itemsToShow.addAll(allInstructions);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: const CustomAppBar(title: "Post-Treatment Instructions"),
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
              (item) => _buildInstructionCard(context, item: item),
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
          text: "Got It",
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
              Iconsax.clipboard_tick,
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
                  "Post-Treatment Recovery Care",
                  style: CustomFonts.black18w600,
                ),
                SizedBox(height: context.h(4)),
                Text(
                  "Follow these aftercare guidelines for smooth recovery and long-lasting results.",
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

  Widget _buildInstructionCard(
    BuildContext context, {
    required PostTreatmentInstructionItem item,
  }) {
    final instructions = item.parsedPostInstructions;

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
          Container(
            padding: EdgeInsets.all(context.w(20)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.r(24)),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: CustomColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < instructions.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: context.h(10)),
                      child: const Divider(
                        color: CustomColors.greyColor,
                        height: 1,
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(context.w(6)),
                        decoration: BoxDecoration(
                          color:
                              CustomColors.darkPurple.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: CustomColors.darkPurple,
                          size: context.sp(16),
                        ),
                      ),
                      SizedBox(width: context.w(12)),
                      Expanded(
                        child: Text(
                          instructions[i],
                          style: CustomFonts.black14w600.copyWith(
                            height: 1.35,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (item.postTreatmentAttachments.isNotEmpty) ...[
                  SizedBox(height: context.h(16)),
                  const Divider(color: CustomColors.greyColor, height: 1),
                  SizedBox(height: context.h(12)),
                  Text(
                    "AFTERCARE ATTACHMENTS",
                    style: CustomFonts.darkPurple10w700.copyWith(
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: context.h(8)),
                  Wrap(
                    spacing: context.w(8),
                    runSpacing: context.h(8),
                    children: item.postTreatmentAttachments
                        .map((att) => _buildAttachmentChip(context, att))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentChip(
    BuildContext context,
    InstructionAttachment att,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (att.url.isNotEmpty) {
            final uri = Uri.parse(att.url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
        borderRadius: BorderRadius.circular(context.r(12)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(12),
            vertical: context.h(8),
          ),
          decoration: BoxDecoration(
            color: CustomColors.darkPurple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(context.r(12)),
            border: Border.all(
              color: CustomColors.darkPurple.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.document_download,
                size: context.sp(16),
                color: CustomColors.darkPurple,
              ),
              SizedBox(width: context.w(6)),
              Flexible(
                child: Text(
                  att.name,
                  style: CustomFonts.black12w600.copyWith(
                    color: CustomColors.darkPurple,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
