import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import '../../models/clinical_journey/clinical_journey_model.dart';
import '../../utils/color_constant.dart';
import '../../utils/custom_fonts.dart';
import '../../utils/date_time_utils.dart';

class FinalizedJourneyCard extends StatelessWidget {
  final DoctorFinalizedStep finalized;

  const FinalizedJourneyCard({super.key, required this.finalized});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(18)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(24)),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: CustomColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Doctor Finalized", style: CustomFonts.black18w600),
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.w(10), vertical: context.h(4)),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.r(20)),
                ),
                child: Text(
                  "FINALIZED",
                  style: CustomFonts.black10w600.copyWith(color: Colors.green, fontSize: context.sp(9)),
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(16)),
          
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: CustomColors.purpleColor.withValues(alpha: 0.3), width: 2),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: finalized.doctorImage ?? "",
                    height: context.w(44),
                    width: context.w(44),
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade100,
                      child: const Icon(Iconsax.user, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(finalized.doctorName, style: CustomFonts.black14w600),
                    Text(finalized.finalizedAt.formattedFullDate, style: CustomFonts.grey12w400),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: context.h(16)),
          Container(
            padding: EdgeInsets.all(context.w(14)),
            decoration: BoxDecoration(
              color: CustomColors.lightBlueBackground.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(context.r(16)),
              border: Border.all(color: CustomColors.lightBlueColor.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Iconsax.info_circle, size: context.sp(16), color: CustomColors.darkPurple),
                SizedBox(width: context.w(10)),
                Expanded(
                  child: Text(
                    finalized.note,
                    style: CustomFonts.black14w400.copyWith(
                      fontSize: context.sp(13), 
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
