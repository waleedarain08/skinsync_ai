import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/responses/appointment_detail_response.dart';
import '../../../utils/color_constant.dart';
import '../../../utils/custom_fonts.dart';
import '../../../utils/string_utils.dart';
import '../../custom_button.dart';

class PreTreatmentInstructionsDialog extends StatelessWidget {
  final List<DetailedAppointmentTreatment>? treatments;

  const PreTreatmentInstructionsDialog({super.key, this.treatments});

  @override
  Widget build(BuildContext context) {
    final list = treatments ?? [];

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
            // Branded Header Icon Badge
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

            // Treatment-Wise Instructions List
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    if (list.isNotEmpty)
                      ...list.map((t) => _buildTreatmentInstructionCard(
                            context,
                            treatmentName: t.treatmentName ?? "Treatment Care",
                            areaName: t.areaName,
                          ))
                    else ...[
                      _buildTreatmentInstructionCard(
                        context,
                        treatmentName: "Botox & Dermal Fillers",
                        areaName: "Cheeks & Lips",
                      ),
                      _buildTreatmentInstructionCard(
                        context,
                        treatmentName: "Skin Rejuvenation & Laser",
                        areaName: "Full Face",
                      ),
                    ],
                  ],
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
    required String treatmentName,
    String? areaName,
  }) {
    final instructions = _getInstructionsForTreatment(treatmentName);

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
          // Header: Treatment Title & Area
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
                      treatmentName.capitalize,
                      style: CustomFonts.black16w700,
                    ),
                    if (areaName != null && areaName.isNotEmpty)
                      Text(
                        "Target Area: $areaName",
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

          // Instruction Bullet Points
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
        ],
      ),
    );
  }

  List<String> _getInstructionsForTreatment(String treatmentName) {
    final lower = treatmentName.toLowerCase();
    if (lower.contains('botox') || lower.contains('filler') || lower.contains('injectable')) {
      return [
        "Avoid alcohol, aspirin, ibuprofen, and blood thinners 24-48 hours before treatment.",
        "Arrive with clean skin free of makeup, moisturizers, or sunscreen.",
        "Notify your practitioner if you have a history of cold sores or skin infections.",
        "Ensure you are well-hydrated and have eaten a light meal prior to your visit.",
      ];
    } else if (lower.contains('laser') || lower.contains('peel') || lower.contains('skin')) {
      return [
        "Avoid direct sun exposure, tanning beds, and self-tanners for 2 weeks prior.",
        "Discontinue retinoids, AHAs, BHAs, and active exfoliating serums 3-5 days before.",
        "Do not wax, shave, or perform chemical depilatory treatments on the area 48 hours prior.",
        "Inform your clinician of any oral medications, antibiotics, or skin sensitivity.",
      ];
    } else {
      return [
        "Avoid blood-thinning supplements, alcohol, and anti-inflammatory drugs 24 hours prior.",
        "Keep the treatment area clean and unblemished before arrival.",
        "Stay hydrated and avoid strenuous workouts immediately before your visit.",
        "Arrive 10-15 minutes early to complete any remaining intake or consent forms.",
      ];
    }
  }
}
