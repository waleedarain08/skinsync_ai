import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/responses/instructions_response.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/string_utils.dart';

class InstructionCard extends StatelessWidget {
  final InstructionData item;
  final String? rawInstructions;
  final String attachmentsLabel;

  const InstructionCard({
    super.key,
    required this.item,
    required this.rawInstructions,
    this.attachmentsLabel = "ATTACHMENTS & GUIDES",
  });

  List<String> _parse(String? raw) {
    if (raw == null) return [];
    return raw
        .split('\n')
        .map((l) => l.replaceFirst(RegExp(r'^\s*[•\-*]\s*'), '').trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final instructions = _parse(rawInstructions);
    final areaName = item.areaName;

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
                  (item.treatmentName ?? 'Treatment').capitalize,
                  style: CustomFonts.black18w600,
                ),
              ),
              if (areaName != null && areaName.isNotEmpty)
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
                    areaName,
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
                // ---- Instructions ----
                if (instructions.isEmpty)
                  Text(
                    "No instructions available",
                    style: CustomFonts.grey12w400,
                  )
                else
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(context.w(6)),
                          decoration: BoxDecoration(
                            color: CustomColors.darkPurple.withValues(
                              alpha: 0.1,
                            ),
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
                            instructions[i].capitalize,
                            style: CustomFonts.black16w600.copyWith(
                              height: 1.35,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                // ---- Attachments ----
                SizedBox(height: context.h(16)),
                const Divider(color: CustomColors.greyColor, height: 1),
                SizedBox(height: context.h(12)),
                Text(
                  attachmentsLabel,
                  style: CustomFonts.darkPurple10w700.copyWith(
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: context.h(8)),
                if (item.attachments.isEmpty)
                  Text(
                    "No attachments available",
                    style: CustomFonts.grey15w400,
                  )
                else
                  Wrap(
                    spacing: context.w(8),
                    runSpacing: context.h(8),
                    children: item.attachments
                        .map((att) => _AttachmentChip(att: att))
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentChip extends StatelessWidget {
  final PreTreatmentAttachment att;
  const _AttachmentChip({required this.att});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final url = att.url;
          if (url == null || url.isEmpty) return;
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
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
                  att.name?.capitalize ?? 'Attachment',
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

