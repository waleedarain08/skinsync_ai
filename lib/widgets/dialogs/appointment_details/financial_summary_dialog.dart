import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/responses/appointment_detail_response.dart';
import '../../../utils/color_constant.dart';
import '../../../utils/custom_fonts.dart';
import '../../../utils/enums.dart';
import '../../custom_button.dart';

class FinancialSummaryDialog extends StatelessWidget {
  final AppointmentDetailData? detail;

  const FinancialSummaryDialog({super.key, this.detail});

  @override
  Widget build(BuildContext context) {
    final detailData = detail;

    final double total = detailData?.treatmentTotal ?? 0.0;
    final double discountVal = detailData?.discount ?? 0.0;
    final String discountType = (detailData?.discountType ?? 'flat')
        .toLowerCase();
    final bool isPercentage =
        discountType == 'percentage' || discountType == 'percent';

    final double amountPaid = detailData?.amountPaid ?? 0.0;
    final double payable = detailData?.payable ?? (total - amountPaid);

    final String methodStr = (detailData?.paymentType?.type ?? 'N/A')
        .toUpperCase();
    final String bookingStr = (detailData?.bookingType ?? 'N/A').toUpperCase();

    // Checked using PaymentStatus enum
    final paymentStatus = PaymentStatus.fromValue(
      detailData?.paymentType?.status,
    );

    Color statusColor = Colors.redAccent;
    if (paymentStatus.isPaid) {
      statusColor = Colors.green.shade700;
    } else if (paymentStatus.isHalfPayment) {
      statusColor = Colors.blue.shade700;
    } else {
      statusColor = Colors.redAccent;
    }



    final String discountDisplay = isPercentage
        ? "-$discountVal%"
        : "-\$${discountVal.toStringAsFixed(2)}";

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.r(32)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(24),
          vertical: context.h(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: context.w(68),
              width: context.w(68),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomColors.purpleColor.withValues(alpha: 0.12),
              ),
              child: Center(
                child: Icon(
                  Iconsax.wallet_money,
                  size: context.sp(30),
                  color: CustomColors.darkPurple,
                ),
              ),
            ),
            SizedBox(height: context.h(16)),
            Text("Financial Summary", style: CustomFonts.black20w600),
            SizedBox(height: context.h(20)),

            // Rows Container Box
            Container(
              padding: EdgeInsets.all(context.w(16)),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FE),
                borderRadius: BorderRadius.circular(context.r(20)),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildRow("Treatment Total", "\$${total.toStringAsFixed(2)}"),
                  _buildDivider(),
                  _buildRow(
                    "Discount (${discountType.toUpperCase()})",
                    discountDisplay,
                    color: Colors.orange.shade800,
                  ),
                  _buildDivider(),
                  _buildRow(
                    "Amount Paid",
                    "\$${amountPaid.toStringAsFixed(2)}",
                    color: Colors.green.shade700,
                  ),
                  _buildDivider(),
                  _buildRow(
                    "Remaining Payable",
                    "\$${payable.toStringAsFixed(2)}",
                    isBold: true,
                    color: CustomColors.darkPurple,
                  ),
                  _buildDivider(),
                  _buildRow("Payment Method", methodStr),
                  _buildDivider(),
                  _buildRow("Booking Channel", bookingStr),
                  _buildDivider(),
                  _buildRow(
                    "Payment Status",
                    paymentStatus.label.toUpperCase(),
                    color: statusColor,
                    isBold: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: context.h(28)),

            SizedBox(
              width: double.infinity,
              height: context.h(50),
              child: CustomButton(
                onPressed: () => Navigator.pop(context),
                text: "Pay Now",
                isBorder: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: CustomFonts.grey700_12w400),
          Text(
            value,
            style: isBold
                ? CustomFonts.black14w700.copyWith(color: color)
                : CustomFonts.black14w600.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: const Divider(height: 1, color: Colors.black12),
    );
  }
}
