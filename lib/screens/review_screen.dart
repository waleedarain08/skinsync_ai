import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/date_time_utils.dart';
import '../view_models/checkout_view_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import 'payment_screen.dart';

class ReviewScreen extends ConsumerWidget {
  static const routeName = '/review_screen';

  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(checkoutViewModel);
    final clinic = checkoutState.selectedClinic;
    final doctor =
        checkoutState.selectedDoctorObject ?? checkoutState.selectedDoctor;
    final date = checkoutState.selectedDate;
    final slot = checkoutState.selectedSlot;

    // Standard high-end mock consultation price
    const double consultationFee = 150.00;

    final totalTreatmentCost = checkoutState.checkoutTreatmentsList.fold<int>(
      0,
      (sum, item) => sum + item.treatmentCost,
    );
    final totalBookingPrice = consultationFee + totalTreatmentCost;

    return Scaffold(
      backgroundColor: CustomColors.whiteColor,
      appBar: const CustomAppBar(showTitle: true, title: "Review Booking"),
      body: Container(
        decoration: const BoxDecoration(
          gradient: CustomColors.whiteBlueGradient,
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(24),
                  vertical: context.h(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Appointment Summary", style: CustomFonts.black16w600),
                    SizedBox(height: context.h(16)),

                    // 1. Doctor & Specialization Details
                    if (doctor != null) ...[
                      Container(
                        padding: EdgeInsets.all(context.w(16)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(context.r(20)),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                context.r(12),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: doctor.doctorImage ?? '',
                                height: context.w(60),
                                width: context.w(60),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade50,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.person),
                              ),
                            ),
                            SizedBox(width: context.w(16)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doctor.doctorName ?? 'Unknown Specialist',
                                    style: CustomFonts.black14w600,
                                  ),
                                  SizedBox(height: context.h(4)),
                                  Text(
                                    doctor.specialization ??
                                        'Aesthetic Medicine',
                                    style: CustomFonts.grey12w400,
                                  ),
                                  SizedBox(height: context.h(4)),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                      SizedBox(width: context.w(2)),
                                      Text(
                                        doctor.doctorRating?.toString() ??
                                            "4.5",
                                        style: CustomFonts.black10w600,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: context.h(16)),
                    ],

                    // 2. Clinic Details
                    Container(
                      padding: EdgeInsets.all(context.w(16)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(context.r(20)),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(context.w(8)),
                            decoration: BoxDecoration(
                              color: CustomColors.lightPurpleColor.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.business_rounded,
                              color: CustomColors.purpleColor,
                            ),
                          ),
                          SizedBox(width: context.w(16)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doctor?.clinic?.clinicName ??
                                      clinic?.name ??
                                      "Standard Clinic Name",
                                  style: CustomFonts.black14w600,
                                ),
                                SizedBox(height: context.h(4)),
                                Text(
                                  clinic?.address ?? "Standard Clinic Location",
                                  style: CustomFonts.grey12w400,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.h(16)),

                    // 3. Appointment Date & Slot
                    Container(
                      padding: EdgeInsets.all(context.w(16)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(context.r(20)),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow(
                            context,
                            Icons.calendar_today_rounded,
                            "Date",
                            date != null
                                ? date.formattedDayDate
                                : "Not Selected",
                          ),
                          const Divider(height: 24),
                          _buildSummaryRow(
                            context,
                            Icons.access_time_rounded,
                            "Time Slot",
                            slot ?? "Not Selected",
                          ),
                          const Divider(height: 24),
                          _buildSummaryRow(
                            context,
                            Icons.medical_services_outlined,
                            "Appointment Type",
                            checkoutState.selectedAppointmentType?.title ??
                                "Not Selected",
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.h(24)),

                    // Selected Treatments & Areas Section
                    if (checkoutState.checkoutTreatmentsList.isNotEmpty) ...[
                      Text(
                        "Selected Treatments & Areas",
                        style: CustomFonts.black16w600,
                      ),
                      SizedBox(height: context.h(16)),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(context.w(16)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(context.r(24)),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...checkoutState.checkoutTreatmentsList.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final selection = entry.value;
                              final isLast =
                                  index ==
                                  checkoutState.checkoutTreatmentsList.length -
                                      1;

                              final materialInfo =
                                  (selection.material != null &&
                                          selection.material!.selectedQuantity > 0)
                                      ? " (${selection.material!.selectedQuantity} ${selection.material!.name})"
                                      : "";

                              return Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: context.h(4),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(
                                            context.w(10),
                                          ),
                                          decoration: BoxDecoration(
                                            color: CustomColors.purpleColor
                                                .withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(
                                              context.r(14),
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.auto_awesome_rounded,
                                            color: CustomColors.purpleColor,
                                            size: context.sp(18),
                                          ),
                                        ),
                                        SizedBox(width: context.w(16)),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    selection.treatmentName,
                                                    style:
                                                        CustomFonts.black14w600,
                                                  ),
                                                  Text(
                                                    "\$${selection.treatmentCost}",
                                                    style:
                                                        CustomFonts.black14w600,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: context.h(2)),
                                              Text(
                                                "${selection.areaName}$materialInfo",
                                                style: CustomFonts.grey12w400
                                                    .copyWith(
                                                      color: CustomColors
                                                          .darkPurple,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isLast)
                                    Padding(
                                      padding: EdgeInsets.only(
                                        left: context.w(52),
                                      ),
                                      child: Divider(
                                        height: context.h(20),
                                        thickness: 1,
                                        color: Colors.grey.shade50,
                                      ),
                                    ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      SizedBox(height: context.h(24)),
                    ],

                    // 4. Pricing Details Section
                    Text("Payment Summary", style: CustomFonts.black16w600),
                    SizedBox(height: context.h(16)),
                    Container(
                      padding: EdgeInsets.all(context.w(18)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(context.r(20)),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Consultation standard fee",
                                style: CustomFonts.grey14w400,
                              ),
                              Text(
                                "\$${consultationFee.toStringAsFixed(2)}",
                                style: CustomFonts.black14w600,
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total treatment fee",
                                style: CustomFonts.grey14w400,
                              ),
                              Text(
                                "\$${totalTreatmentCost.toStringAsFixed(2)}",
                                style: CustomFonts.black14w600,
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total booking price",
                                style: CustomFonts.black16w600,
                              ),
                              Text(
                                "\$${totalBookingPrice.toStringAsFixed(2)}",
                                style: CustomFonts.black16w600.copyWith(
                                  color: CustomColors.pinkColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Continuous to payments selection screen using CustomButton
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(24),
                vertical: context.h(20),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(context.r(24)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: CustomButton(
                text: "Proceed to Payment",
                borderRadius: context.r(26),

                onPressed: () {
                  Navigator.pushNamed(context, PaymentScreen.routeName);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade400, size: context.sp(20)),
        SizedBox(width: context.w(12)),
        Text(label, style: CustomFonts.grey13w400),
        const Spacer(),
        Text(value, style: CustomFonts.black14w600),
      ],
    );
  }
}
