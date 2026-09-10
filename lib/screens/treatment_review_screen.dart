import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../models/requests/preferred_slot.dart';
import '../models/responses/auth_response.dart';
import '../models/responses/get_clinic_response.dart';
import '../models/responses/simulation_history_response.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/date_time_utils.dart';
import '../view_models/auth_view_model.dart';
import '../view_models/treatment_journey_view_model.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/dialogs/success_dialogs.dart';

class TreatmentReviewScreen extends ConsumerStatefulWidget {
  final SimulationData? simulationData;
  final List<PreferredSlot> preferredSlots;
  final Clinic clinic;

  const TreatmentReviewScreen({
    super.key,
    this.simulationData,
    required this.preferredSlots,
    required this.clinic,
  });

  static const String routeName = '/TreatmentReviewScreen';

  @override
  ConsumerState<TreatmentReviewScreen> createState() =>
      _TreatmentReviewScreenState();
}

class _TreatmentReviewScreenState extends ConsumerState<TreatmentReviewScreen> {
  bool _shareMedicalHistory = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        showTitle: true,
        title: "Review Treatment Request",
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.w(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClinicInfo(context),
            SizedBox(height: context.h(24)),
            _buildPatientInfo(context),
            SizedBox(height: context.h(24)),
            if (widget.simulationData != null) ...[
              _buildTreatmentDetails(context),
              SizedBox(height: context.h(24)),
              Text("Simulation Images", style: CustomFonts.black18w600),
              SizedBox(height: context.h(12)),
              _buildSimulationImages(context),
              SizedBox(height: context.h(24)),
            ],
            if (widget.preferredSlots.isNotEmpty) ...[
              _buildSlotsSummary(context),
              SizedBox(height: context.h(24)),
            ],
            _buildMedicalHistoryCheckbox(context),
            SizedBox(height: context.h(24)),
            Text(
              "By continuing, you confirm that you are voluntarily submitting new facial images for SkinSync’s facial-analysis, simulation, treatment-planning, and progress-tracking features under your existing Facial Scan and Biometric Consent. Do not continue if you have withdrawn that consent.",
              style: CustomFonts.black14w400.copyWith(
                height: 1.5,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(120)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildMedicalHistoryCheckbox(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _shareMedicalHistory = !_shareMedicalHistory;
          });
        },
        borderRadius: BorderRadius.circular(context.r(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: context.w(22),
              height: context.w(22),
              child: Checkbox(
                value: _shareMedicalHistory,
                onChanged: (value) {
                  setState(() {
                    _shareMedicalHistory = value ?? false;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.r(4)),
                ),
                side: BorderSide(color: Colors.grey.shade400),
                activeColor: CustomColors.purpleColor,
              ),
            ),
            SizedBox(width: context.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Share Medical History", style: CustomFonts.black14w600),
                  SizedBox(height: context.h(2)),
                  Text(
                    "Allow the clinic to view your allergy & medical history.",
                    style: CustomFonts.grey12w400,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicInfo(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: context.h(60),
                width: context.h(60),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.clinic.logo ?? "",
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CupertinoActivityIndicator(),
                    errorWidget: (context, url, error) => Icon(
                      Icons.storefront_rounded,
                      size: context.h(30),
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.clinic.name ?? "Clinic Name",
                      style: CustomFonts.black18w600,
                    ),
                    SizedBox(height: context.h(2)),
                    Text("Clinic Details", style: CustomFonts.grey12w400),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(16)),
          const Divider(height: 1),
          SizedBox(height: context.h(16)),
          if (widget.clinic.address != null)
            _buildDetailRow(
              context,
              Icons.location_on_outlined,
              widget.clinic.address!,
            ),
          if (widget.clinic.phone != null) ...[
            SizedBox(height: context.h(8)),
            _buildDetailRow(
              context,
              Icons.phone_outlined,
              widget.clinic.phone!,
            ),
          ],
          if (widget.clinic.email != null) ...[
            SizedBox(height: context.h(8)),
            _buildDetailRow(
              context,
              Icons.email_outlined,
              widget.clinic.email!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPatientInfo(BuildContext context) {
    final user = ref.watch(authViewModel).authData?.user;
    final String name = (user?.name != null && user!.name!.trim().isNotEmpty)
        ? user.name!
        : "Patient Name";
    final String email = user?.primaryEmail ?? user?.email ?? "";
    final String phone = _formatPhone(user);
    final String profileImage = user?.profileImageUrl ?? "";

    return Container(
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: context.h(60),
                width: context.h(60),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: profileImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CupertinoActivityIndicator(),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade100,
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: context.h(30),
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: context.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: CustomFonts.black18w600),
                    SizedBox(height: context.h(2)),
                    Text("Patient Details", style: CustomFonts.grey12w400),
                  ],
                ),
              ),
            ],
          ),
          if (phone.isNotEmpty || email.isNotEmpty) ...[
            SizedBox(height: context.h(16)),
            const Divider(height: 1),
            SizedBox(height: context.h(16)),
            if (phone.isNotEmpty)
              _buildDetailRow(context, Icons.phone_outlined, phone),
            if (email.isNotEmpty) ...[
              if (phone.isNotEmpty) SizedBox(height: context.h(8)),
              _buildDetailRow(context, Icons.email_outlined, email),
            ],
          ],
        ],
      ),
    );
  }

  String _formatPhone(User? user) {
    if (user?.phoneNumber == null || user!.phoneNumber!.trim().isEmpty) {
      return "";
    }
    final rawPhone = user.phoneNumber!.trim();
    if (user.cc != null &&
        user.cc!.trim().isNotEmpty &&
        !rawPhone.startsWith('+') &&
        !rawPhone.startsWith(user.cc!.trim())) {
      return "${user.cc!.trim()} $rawPhone";
    }
    return rawPhone;
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: CustomColors.purpleColor),
        SizedBox(width: context.w(12)),
        Expanded(child: Text(text, style: CustomFonts.grey14w400)),
      ],
    );
  }

  Widget _buildSimulationImages(BuildContext context) {
    return Column(
      children: [
        _buildImagePair(
          context,
          "Front View",
          widget.simulationData?.frontImageBefore,
          widget.simulationData?.frontImageAfter,
        ),
        SizedBox(height: context.h(12)),
        _buildImagePair(
          context,
          "Right View",
          widget.simulationData?.rightImageBefore,
          widget.simulationData?.rightImageAfter,
        ),
        SizedBox(height: context.h(12)),
        _buildImagePair(
          context,
          "Left View",
          widget.simulationData?.leftImageBefore,
          widget.simulationData?.leftImageAfter,
        ),
      ],
    );
  }

  Widget _buildImagePair(
    BuildContext context,
    String label,
    String? before,
    String? after,
  ) {
    if (before == null && after == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: CustomFonts.black14w600),
        SizedBox(height: context.h(8)),
        Row(
          children: [
            Expanded(child: _buildSingleImage(context, "Before", before)),
            SizedBox(width: context.w(12)),
            Expanded(child: _buildSingleImage(context, "After", after)),
          ],
        ),
      ],
    );
  }

  Widget _buildSingleImage(BuildContext context, String title, String? url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: CustomFonts.grey12w400),
        SizedBox(height: context.h(4)),
        Container(
          height: context.h(120),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.r(12)),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(context.r(12)),
            child: CachedNetworkImage(
              imageUrl: url ?? "",
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const Center(child: CupertinoActivityIndicator()),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTreatmentDetails(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Iconsax.receipt,
                size: 20,
                color: CustomColors.purpleColor,
              ),
              SizedBox(width: context.w(8)),
              Text("Treatment Details", style: CustomFonts.black16w600),
            ],
          ),
          const Divider(height: 24),
          if (widget.simulationData?.treatments != null)
            ...widget.simulationData!.treatments!.map((treatment) {
              return Padding(
                padding: EdgeInsets.only(bottom: context.h(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      treatment.name ?? "N/A",
                      style: CustomFonts.black14w600,
                    ),
                    SizedBox(height: context.h(4)),
                    if (treatment.areas != null)
                      ...treatment.areas!.map((area) {
                        final material =
                            (area.materials != null &&
                                area.materials!.isNotEmpty)
                            ? area.materials!.first
                            : null;
                        return Padding(
                          padding: EdgeInsets.only(
                            left: context.w(12),
                            top: context.h(2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "• ${area.name ?? "N/A"}",
                                style: CustomFonts.grey12w400,
                              ),
                              if (material != null)
                                Text(
                                  "${material.selectedQuantity ?? 0} Syringes",
                                  style: CustomFonts.black12w600.copyWith(
                                    color: CustomColors.purpleColor,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSlotsSummary(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: CustomColors.purpleColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(
          color: CustomColors.purpleColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Iconsax.calendar_tick,
                size: 20,
                color: CustomColors.purpleColor,
              ),
              SizedBox(width: context.w(8)),
              Text("Preferred Slots", style: CustomFonts.black16w600),
            ],
          ),
          const Divider(height: 24),
          ...widget.preferredSlots.asMap().entries.map((entry) {
            final index = entry.key;
            final slot = entry.value;
            return Padding(
              padding: EdgeInsets.only(
                bottom: index != widget.preferredSlots.length - 1
                    ? context.h(10)
                    : 0,
              ),
              child: Row(
                children: [
                  Text(
                    "${index + 1}. ",
                    style: CustomFonts.darkPurple12w600.copyWith(
                      fontSize: context.sp(14),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "${DateTimeUtils.fromTimestamp(slot.date).formattedDate} at "
                      "${DateTimeUtils.fromTimestamp(slot.time).formattedTime24}",
                      style: CustomFonts.black13w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: context.w(24),
        right: context.w(24),
        bottom: MediaQuery.paddingOf(context).bottom + context.h(20),
        top: context.h(20),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: context.h(14)),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.r(30)),
                ),
              ),
              child: Text(
                "No",
                style: CustomFonts.black14w600.copyWith(color: Colors.black54),
              ),
            ),
          ),
          SizedBox(width: context.w(12)),
          Expanded(
            child: CustomButton(
              text: "Continue",
              height: context.h(52),
              onPressed: () async {
                bool? success;
                if (widget.clinic.place != null) {
                  success = await ref
                      .read(treatmentJourneyProvider.notifier)
                      .callShareMapTreatmentRequest(
                        widget.clinic,
                        widget.preferredSlots,
                        shareMedicalHistory: _shareMedicalHistory,
                      );
                } else {
                  success = await ref
                      .read(treatmentJourneyProvider.notifier)
                      .callShareTreatmentRequest(
                        widget.preferredSlots,
                        shareMedicalHistory: _shareMedicalHistory,
                      );
                }

                if (success == true) {
                  if (context.mounted) {
                    showShareJourneySuccessDialog(context);
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
