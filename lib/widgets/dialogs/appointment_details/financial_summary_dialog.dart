import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/responses/appointment_detail_response.dart';
import '../../../utils/custom_fonts.dart';
import '../../../utils/color_constant.dart';
import '../../custom_button.dart';

class FinancialSummaryDialog extends StatelessWidget {
  final AppointmentDetailData? detail;

  const FinancialSummaryDialog({super.key, this.detail});

  @override
  Widget build(BuildContext context) {
    final isPending = detail?.paymentType?.status == 'pending';

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
                  Iconsax.wallet_money,
                  size: context.sp(32),
                  color: CustomColors.darkPurple,
                ),
              ),
            ),
            SizedBox(height: context.h(24)),
            Text("Financial Summary", style: CustomFonts.black20w600),
            SizedBox(height: context.h(24)),
            
            _buildRow("Treatment Total", "\$${detail?.treatmentTotal?.toStringAsFixed(2) ?? '0.00'}"),
            if (detail?.discount != null && detail!.discount! > 0)
              _buildRow(
                "Discount",
                "${detail!.discountType == 'percent' ? '-' : '-\$'}${detail!.discount}${detail!.discountType == 'percent' ? '%' : ''}",
                color: Colors.orange,
              ),
            _buildRow("Payment Type", detail?.paymentType?.type?.toUpperCase() ?? "N/A"),
            _buildRow(
              "Payment Status",
              detail?.paymentType?.status?.toUpperCase() ?? "N/A",
              color: detail?.paymentType?.status == 'completed' ? Colors.green : Colors.orange,
              isBold: true,
            ),
            
            SizedBox(height: context.h(32)),
            
            if (isPending) ...[
              CustomButton(
                onPressed: () {
                  // TODO: Implement Payment Logic
                  Navigator.pop(context);
                },
                text: "Pay Now",
              ),
              SizedBox(height: context.h(12)),
            ],
            
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

  Widget _buildRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: CustomFonts.grey700_12w400),
          Text(
            value, 
            style: isBold 
                ? CustomFonts.black14w700.copyWith(color: color) 
                : CustomFonts.black14w600.copyWith(color: color)
          ),
        ],
      ),
    );
  }
}
