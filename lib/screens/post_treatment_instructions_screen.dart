import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../models/responses/appointment_detail_response.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/string_utils.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';

class PostTreatmentInstructionsScreen extends StatelessWidget {
  static const String routeName = "/PostTreatmentInstructionsScreen";
  final List<DetailedAppointmentTreatment>? treatments;

  const PostTreatmentInstructionsScreen({super.key, this.treatments});

  @override
  Widget build(BuildContext context) {
    final list = treatments ?? [];

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
            // Top Summary Banner
            _buildTopBanner(context),
            SizedBox(height: context.h(24)),

            // Treatment-Wise Instructions List
            if (list.isNotEmpty)
              ...list.map((t) => _buildTreatmentCard(
                    context,
                    treatmentName: t.treatmentName ?? "Treatment Aftercare",
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

  Widget _buildTreatmentCard(
    BuildContext context, {
    required String treatmentName,
    String? areaName,
  }) {
    final instructions = _getPostInstructionsForTreatment(treatmentName);

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

  List<String> _getPostInstructionsForTreatment(String treatmentName) {
    final lower = treatmentName.toLowerCase();
    if (lower.contains('botox') ||
        lower.contains('filler') ||
        lower.contains('injectable')) {
      return [
        "Remain upright for at least 4 hours after treatment; do not lie flat or bend forward.",
        "Avoid touching, rubbing, or massaging the treated areas for 24 hours.",
        "Refrain from strenuous workouts, saunas, hot tubs, and heavy sweating for 24-48 hours.",
        "Apply cool compresses gently if minor swelling or bruising occurs at injection sites.",
      ];
    } else if (lower.contains('laser') ||
        lower.contains('peel') ||
        lower.contains('skin')) {
      return [
        "Apply Broad-Spectrum SPF 50+ daily and strictly avoid direct sun exposure.",
        "Use mild, non-scented cleansers and soothing moisturizers; do not pick or scrub skin.",
        "Avoid active exfoliants (Retinoids, AHAs/BHAs, Vitamin C) for 5-7 days after treatment.",
        "Avoid hot showers, steam rooms, and intense cardiovascular exercise for 48 hours.",
      ];
    } else {
      return [
        "Keep the treated area clean and hydrated using practitioner-recommended products.",
        "Avoid direct sun exposure and wear protective sunscreen every day.",
        "Do not apply heavy makeup or harsh cosmetics to the area for 24 hours.",
        "Contact the clinic immediately if you experience unexpected severe pain or skin discoloration.",
      ];
    }
  }
}
