import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/responses/appointment_detail_response.dart';
import '../../../utils/custom_fonts.dart';
import '../../../utils/color_constant.dart';
import '../../../utils/string_utils.dart';
import '../../custom_button.dart';

class TreatmentDetailsDialog extends StatelessWidget {
  final List<DetailedAppointmentTreatment>? treatments;

  const TreatmentDetailsDialog({super.key, this.treatments});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(32))),
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.w(24), vertical: context.h(32)),
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
                  Iconsax.mask,
                  size: context.sp(32),
                  color: CustomColors.darkPurple,
                ),
              ),
            ),
            SizedBox(height: context.h(24)),
            Text("Treatment Details", style: CustomFonts.black20w600),
            SizedBox(height: context.h(24)),
            
            if (treatments == null || treatments!.isEmpty)
              const Center(child: Text("No treatment details available"))
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: treatments!.length,
                  itemBuilder: (context, index) {
                    final t = treatments![index];
                    return _buildTreatmentItem(context, t);
                  },
                ),
              ),
            SizedBox(height: context.h(32)),
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

  Widget _buildTreatmentItem(BuildContext context, DetailedAppointmentTreatment t) {
    Color statusColor = Colors.grey;
    switch (t.treatmentStatus?.toLowerCase()) {
      case 'pending': statusColor = Colors.orange; break;
      case 'completed': statusColor = Colors.green; break;
      default: statusColor = Colors.blue; break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: context.h(16)),
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(24)),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(context.r(12)),
                child: CachedNetworkImage(
                  imageUrl: t.treatmentImage ?? "",
                  height: context.w(44),
                  width: context.w(44),
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => Container(
                    color: CustomColors.purpleColor.withValues(alpha: 0.1),
                    child: const Icon(Iconsax.mask, color: CustomColors.purpleColor)
                  ),
                ),
              ),
              SizedBox(width: context.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.treatmentName?.capitalize ?? "N/A", style: CustomFonts.black14w700),
                    Text("Area: ${t.areaName ?? 'N/A'}", style: CustomFonts.black12w600),
                  ],
                ),
              ),
              if (t.treatmentStatus != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(context.r(8)),
                  ),
                  child: Text(
                    t.treatmentStatus!.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: context.sp(8), fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          if (t.material != null) ...[
            SizedBox(height: 12.h),
            const Divider(height: 1),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Dosage", style: CustomFonts.grey700_10w400),
                Text("${t.material!.selectedQuantity} ${t.material!.name?.capitalize ?? ''}", style: CustomFonts.darkPurple10w700),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
