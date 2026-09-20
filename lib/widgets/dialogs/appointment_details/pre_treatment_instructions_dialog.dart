import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/responses/appointment_detail_response.dart';
import '../../../models/responses/pre_treatment_instruction_model.dart';
import '../../../utils/color_constant.dart';
import '../../../utils/custom_fonts.dart';
import '../../../utils/string_utils.dart';
import '../../../view_models/pre_treatment_instruction_view_model.dart';
import '../../custom_button.dart';

class PreTreatmentInstructionsDialog extends ConsumerWidget {
  final List<DetailedAppointmentTreatment>? treatments;

  const PreTreatmentInstructionsDialog({super.key, this.treatments});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final instructionState = ref.watch(preTreatmentInstructionProvider);
    final allInstructions = instructionState.instructions;

    final itemsToShow = <PreTreatmentInstructionItem>[];
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
          orElse: () => PreTreatmentInstructionItem(
            treatmentId: t.treatmentId ?? 0,
            treatmentName: t.treatmentName ?? "Treatment Care",
            areaName: t.areaName,
            preTreatmentInstructions:
                "• Avoid blood thinners and alcohol 24-48 hours before.\n• Keep treatment area clean and unblemished prior to arrival.",
          ),
        );
        itemsToShow.add(match);
      }
    } else {
      itemsToShow.addAll(allInstructions);
    }

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.r(32)),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.w(20),
        vertical: context.h(40),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(24),
          vertical: context.h(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: context.w(72),
              width: context.w(72),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomColors.darkPurple.withValues(alpha: 0.1),
              ),
              child: Center(
                child: Icon(
                  Iconsax.clipboard_text,
                  size: context.sp(32),
                  color: CustomColors.darkPurple,
                ),
              ),
            ),
            SizedBox(height: context.h(20)),
            Text("Pre-Treatment Instructions", style: CustomFonts.black20w600),
            SizedBox(height: context.h(6)),
            Text(
              "Please follow these guidelines prior to your appointment for optimal results.",
              textAlign: TextAlign.center,
              style: CustomFonts.black12w600.copyWith(color: Colors.black87),
            ),
            SizedBox(height: context.h(24)),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: itemsToShow
                      .map(
                        (item) => _buildTreatmentInstructionCard(
                          context,
                          item: item,
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            SizedBox(height: context.h(24)),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: () => Navigator.pop(context),
                text: "Close",
                isBorder: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentInstructionCard(
    BuildContext context, {
    required PreTreatmentInstructionItem item,
  }) {
    final instructions = item.parsedPreInstructions;

    return Container(
      margin: EdgeInsets.only(bottom: context.h(16)),
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(20)),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: CustomColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.w(8)),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.treatmentName.capitalize,
                      style: CustomFonts.black16w700,
                    ),
                    if (item.areaName != null && item.areaName!.isNotEmpty)
                      Text(
                        "Target Area: ${item.areaName}",
                        style: CustomFonts.black12w600.copyWith(
                          color: CustomColors.darkPurple,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(12)),
          const Divider(height: 1, color: CustomColors.greyColor),
          SizedBox(height: context.h(12)),
          Column(
            children: instructions
                .map((text) => Padding(
                      padding: EdgeInsets.only(bottom: context.h(8)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: CustomColors.darkPurple,
                            size: context.sp(16),
                          ),
                          SizedBox(width: context.w(10)),
                          Expanded(
                            child: Text(
                              text,
                              style: CustomFonts.black13w600.copyWith(
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
          if (item.preTreatmentAttachments.isNotEmpty) ...[
            SizedBox(height: context.h(12)),
            const Divider(height: 1, color: CustomColors.greyColor),
            SizedBox(height: context.h(10)),
            Text(
              "ATTACHMENTS",
              style: CustomFonts.darkPurple10w700.copyWith(
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: context.h(6)),
            Wrap(
              spacing: context.w(8),
              runSpacing: context.h(8),
              children: item.preTreatmentAttachments
                  .map((att) => _buildAttachmentChip(context, att))
                  .toList(),
            ),
          ],
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
            horizontal: context.w(10),
            vertical: context.h(6),
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
                size: context.sp(14),
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
