import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../models/requests/preferred_slot.dart';
import '../models/responses/get_clinic_response.dart';
import '../models/responses/practitioner_list_response.dart';
import '../utils/date_time_utils.dart';
import '../utils/string_utils.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../view_models/checkout_view_model.dart';
import '../view_models/treatment_journey_view_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import 'select_date_time_screen.dart';
import 'treatment_review_screen.dart';

class DoctorDetailScreen extends ConsumerWidget {
  static const routeName = '/doctor_detail_screen';
  final Clinic? clinic;
  final PractitionerDoctor doctor;

  const DoctorDetailScreen({super.key, required this.doctor, this.clinic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(checkoutViewModel);
    final bool hasDateTime =
        checkoutState.selectedDate != null &&
        checkoutState.selectedSlot != null;

    return Scaffold(
      backgroundColor: CustomColors.whiteColor,
      appBar: const CustomAppBar(showTitle: true, title: "Specialist Profile"),
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
                  vertical: context.h(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Profile Card with large image
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(context.r(24)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(
                          color: CustomColors.greyColor.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(context.r(24)),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: doctor.doctorImage ?? '',
                              height: context.h(200),
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade50,
                                child: const Center(
                                  child: CupertinoActivityIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade50,
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(context.w(18)),
                            child: Column(
                              children: [
                                Text(
                                  doctor.doctorName?.capitalize ?? '',
                                  style: CustomFonts.black22w600,
                                ),
                                SizedBox(height: context.h(6)),
                                Text(
                                  doctor.specialization ?? '',
                                  style: CustomFonts.grey14w400.copyWith(
                                    color: CustomColors.pinkColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: context.h(10)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    SizedBox(width: context.w(4)),
                                    Text(
                                      doctor.doctorRating?.toString() ?? "4.5",
                                      style: CustomFonts.black14w600,
                                    ),
                                    SizedBox(width: context.w(16)),
                                    Container(
                                      width: context.w(1),
                                      height: context.h(16),
                                      color: Colors.grey.shade300,
                                    ),
                                    SizedBox(width: context.w(16)),
                                    const Icon(
                                      Icons.verified_user_rounded,
                                      color: CustomColors.blueColor,
                                      size: 18,
                                    ),
                                    SizedBox(width: context.w(4)),
                                    Text(
                                      "Board Certified",
                                      style: CustomFonts.grey12w400.copyWith(
                                        fontWeight: FontWeight.bold,
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
                    SizedBox(height: context.h(24)),

                    // Biography Section
                    Text("About Specialist", style: CustomFonts.black18w600),
                    SizedBox(height: context.h(10)),
                    Text(
                      "${doctor.doctorName ?? 'Specialist'} is a highly qualified specialist in clinical dermatology and non-surgical facial enhancements. With over 12 years of hands-on experience and continuous contribution to aesthetic research, they provide bespoke luxury care using state-of-the-art diagnostic algorithms and premium injection materials.",
                      style: CustomFonts.textGrey14w400,
                    ),
                    SizedBox(height: context.h(20)),

                    // Professional Qualifications Card
                    Text("Qualifications", style: CustomFonts.black18w600),
                    SizedBox(height: context.h(10)),
                    _buildQualificationItem(
                      context,
                      Icons.school_rounded,
                      "MD in Aesthetic & Clinical Dermatology",
                      "Stanford University School of Medicine",
                    ),
                    _buildQualificationItem(
                      context,
                      Icons.workspace_premium_rounded,
                      "Board of Facial Plastic & Reconstructive Surgery",
                      "Active Premium Member",
                    ),
                    _buildQualificationItem(
                      context,
                      Icons.business_center_rounded,
                      "Resident MedSpa Specialist",
                      doctor.clinic?.clinicName ??
                          clinic?.name ??
                          "Premium Clinic",
                    ),
                  ],
                ),
              ),
            ),
            // Premium Floating Booking Button Container
            if (clinic != null || doctor.clinic != null)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(24),
                  vertical: context.h(20),
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
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
                  text: hasDateTime
                      ? "Review Consultation Booking"
                      : "Select Date & Time Slot",
                  onPressed: () {
                    final targetClinic =
                        clinic ??
                        Clinic(
                          id: doctor.clinic?.clinicId,
                          name: doctor.clinic?.clinicName,
                        );

                    if (hasDateTime) {
                      final checkoutState = ref.read(checkoutViewModel);
                      final simulations = ref
                          .read(treatmentJourneyProvider)
                          .simulations;
                      final preferredSlots = [
                        PreferredSlot(
                          date: checkoutState.selectedDate!.secondsSinceEpoch,
                          time: checkoutState
                              .selectedSlotObject!
                              .startTime
                              .secondsSinceEpoch,
                        ),
                      ];
                      Navigator.pushNamed(
                        context,
                        TreatmentReviewScreen.routeName,
                        arguments: {
                          'simulationData': simulations,
                          'preferredSlots': preferredSlots,
                          'clinic': targetClinic,
                        },
                      );
                    } else {
                      Navigator.pushNamed(
                        context,
                        SelectDateTimeScreen.routeName,
                        arguments: targetClinic,
                      );
                    }
                  },

                  borderRadius: context.r(26),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualificationItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: context.h(12)),
      padding: EdgeInsets.all(context.w(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.w(8)),
            decoration: BoxDecoration(
              color: CustomColors.lightPurpleColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: CustomColors.purpleColor,
              size: context.sp(20),
            ),
          ),
          SizedBox(width: context.w(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.capitalize, style: CustomFonts.black13w600),
                SizedBox(height: context.h(2)),
                Text(subtitle, style: CustomFonts.grey12w400),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
