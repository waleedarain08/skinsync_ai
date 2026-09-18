import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../models/responses/appointment_detail_response.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/string_utils.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';

class PreTreatmentInstructionsScreen extends StatelessWidget {
  static const String routeName = "/PreTreatmentInstructionsScreen";
  final List<DetailedAppointmentTreatment>? treatments;

  const PreTreatmentInstructionsScreen({super.key, this.treatments});

  @override
  Widget build(BuildContext context) {
    final list = treatments ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: const CustomAppBar(title: "Pre-Treatment Instructions"),
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
            // Top Summary Banner
            _buildTopBanner(context),
            SizedBox(height: context.h(24)),

            // Treatment-Wise Instructions List
            if (list.isNotEmpty)
              ...list.map((t) => _buildTreatmentCard(
                    context,
                    treatmentName: t.treatmentName ?? "Treatment Care",
                    areaName: t.areaName,
                  ))
            else ...[
              _buildTreatmentCard(
                context,
                treatmentName: "Botox & Dermal Fillers",
                areaName: "Cheeks & Lips",
              ),
              _buildTreatmentCard(
                context,
                treatmentName: "Skin Rejuvenation & Laser",
                areaName: "Full Face",
              ),
            ],
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
              Iconsax.clipboard_text,
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
                  "Pre-Treatment Guidelines",
                  style: CustomFonts.black18w600,
                ),
                SizedBox(height: context.h(4)),
                Text(
                  "Follow these essential care guidelines prior to your visit for optimal results.",
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

  Widget _buildTreatmentCard(
    BuildContext context, {
    required String treatmentName,
    String? areaName,
  }) {
    final instructions = _getInstructionsForTreatment(treatmentName);

    return Container(
      margin: EdgeInsets.only(bottom: context.h(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
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
                  treatmentName.capitalize,
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

          // Clinic Container Style Card Box
          Container(
            padding: EdgeInsets.all(context.w(20)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.r(24)),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: CustomColors.cardShadow,
            ),
            child: Column(
              children: [
                for (int i = 0; i < instructions.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: context.h(10)),
                      child: const Divider(color: CustomColors.greyColor, height: 1),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(context.w(6)),
                        decoration: BoxDecoration(
                          color: CustomColors.darkPurple.withValues(alpha: 0.1),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getInstructionsForTreatment(String treatmentName) {
    final lower = treatmentName.toLowerCase();
    if (lower.contains('botox') ||
        lower.contains('filler') ||
        lower.contains('injectable')) {
      return [
        "Avoid alcohol, aspirin, ibuprofen, and blood thinners 24-48 hours before treatment.",
        "Arrive with clean skin free of makeup, moisturizers, or sunscreen.",
        "Notify your practitioner if you have a history of cold sores or active skin infections.",
        "Ensure you are well-hydrated and have eaten a light meal prior to your visit.",
      ];
    } else if (lower.contains('laser') ||
        lower.contains('peel') ||
        lower.contains('skin')) {
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
