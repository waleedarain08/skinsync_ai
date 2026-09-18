import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/responses/appointments_list_response.dart';
import '../../../utils/custom_fonts.dart';
import '../../../utils/color_constant.dart';
import '../../../utils/string_utils.dart';
import '../../custom_button.dart';

class DoctorDetailsDialog extends StatelessWidget {
  final AppointmentDoctor? doctor;

  const DoctorDetailsDialog({super.key, this.doctor});

  @override
  Widget build(BuildContext context) {
    if (doctor == null) return const SizedBox.shrink();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(32))),
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
                  Iconsax.user,
                  size: context.sp(32),
                  color: CustomColors.darkPurple,
                ),
              ),
            ),
            SizedBox(height: context.h(24)),
            Text("Doctor Details", style: CustomFonts.black20w600),
            SizedBox(height: context.h(24)),
            
            Row(
              children: [
                if (doctor!.image != null && doctor!.image!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(context.r(12)),
                    child: CachedNetworkImage(
                      imageUrl: doctor!.image!,
                      height: context.w(50),
                      width: context.w(50),
                      fit: BoxFit.cover,
                    ),
                  ),
                if (doctor!.image != null && doctor!.image!.isNotEmpty) SizedBox(width: context.w(16)),
                Expanded(
                  child: Text(
                    "${doctor!.title?.capitalize ?? ''} ${doctor!.name?.capitalize ?? 'N/A'}".trim(),
                    style: CustomFonts.black16w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.h(20)),
            _buildRow("Email", doctor!.email ?? "N/A", Iconsax.sms),
            _buildRow("Phone", "${doctor!.cc ?? ''} ${doctor!.phone ?? 'N/A'}".trim(), Iconsax.call),
            _buildRow("Country", doctor!.country ?? "N/A", Iconsax.global),
            
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

  Widget _buildRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: Colors.grey.shade400),
          SizedBox(width: 12.w),
          Text("$label:", style: CustomFonts.grey700_12w400),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: CustomFonts.black13w600,
            ),
          ),
        ],
      ),
    );
  }
}
