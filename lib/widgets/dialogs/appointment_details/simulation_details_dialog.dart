import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/responses/appointment_detail_response.dart';
import '../../../utils/custom_fonts.dart';
import '../../../utils/color_constant.dart';
import '../../custom_button.dart';

class SimulationDetailsDialog extends StatelessWidget {
  final Simulations simulations;

  const SimulationDetailsDialog({super.key, required this.simulations});

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
                  Iconsax.magicpen,
                  size: context.sp(32),
                  color: CustomColors.darkPurple,
                ),
              ),
            ),
            SizedBox(height: context.h(24)),
            Text("Simulations", style: CustomFonts.black20w600),
            SizedBox(height: context.h(24)),
            
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildPair(context, "Front View", simulations.frontImageBefore, simulations.frontImageAfter),
                    _buildPair(context, "Right View", simulations.rightImageBefore, simulations.rightImageAfter),
                    _buildPair(context, "Left View", simulations.leftImageBefore, simulations.leftImageAfter),
                  ],
                ),
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

  Widget _buildPair(BuildContext context, String label, String? before, String? after) {
    if ((before == null || before.isEmpty) && (after == null || after.isEmpty)) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: CustomFonts.black14w700),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _buildImage(context, "Before", before)),
            SizedBox(width: 12.w),
            Expanded(child: _buildImage(context, "After", after)),
          ],
        ),
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildImage(BuildContext context, String label, String? url) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: url != null && url.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: url,
                  height: 110.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    color: Colors.grey.shade50,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  ),
                  errorWidget: (_, _, _) => Container(
                    color: Colors.grey.shade100, 
                    height: 110.h, 
                    child: const Icon(Iconsax.image, color: Colors.grey)
                  ),
                )
              : Container(
                  color: Colors.grey.shade100, 
                  height: 110.h, 
                  child: const Icon(Iconsax.image, color: Colors.grey)
                ),
        ),
        SizedBox(height: 4.h),
        Text(label, style: CustomFonts.grey700_10w400),
      ],
    );
  }
}
