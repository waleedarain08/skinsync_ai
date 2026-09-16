import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../models/responses/patient_treatment_request_response.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/date_time_utils.dart';
import '../view_models/patient_treatment_request_view_model.dart';
import '../widgets/app_loader.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/simulation_treatment_area_chip.widget.dart';
import 'patient_treatment_request_detail_screen.dart';

class PatientTreatmentRequestsScreen extends ConsumerStatefulWidget {
  final int clinicId;
  const PatientTreatmentRequestsScreen({super.key, required this.clinicId});

  static const String routeName = '/PatientTreatmentRequestsScreen';

  @override
  ConsumerState<PatientTreatmentRequestsScreen> createState() =>
      _PatientTreatmentRequestsScreenState();
}

class _PatientTreatmentRequestsScreenState
    extends ConsumerState<PatientTreatmentRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(patientTreatmentRequestProvider.notifier)
          .fetchRequests(clinicId: widget.clinicId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patientTreatmentRequestProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        showTitle: true,
        title: "Shared Treatment Requests",
      ),
      body: state.loading
          ? const Center(child: AppLoader())
          : state.requests.isEmpty
          ? Center(
              child: Text(
                state.errorMessage ?? "No shared treatment requests found",
                style: CustomFonts.grey16w400,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.w(24),
                    context.h(20),
                    context.w(24),
                    context.h(10),
                  ),
                  child: Text(
                    "Review shared simulation requests and their requested treatments.",
                    style: CustomFonts.grey14w400.copyWith(height: 1.4),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(24),
                      vertical: context.h(10),
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: state.requests.length,
                    itemBuilder: (context, index) {
                      final request = state.requests[index];
                      return _buildRequestSummaryCard(context, request);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRequestSummaryCard(
    BuildContext context,
    PatientTreatmentRequest request,
  ) {
    final treatments = request.treatments ?? [];
    final title = request.refId ?? "Shared Treatment Request";
    final subtitle = request.createdAt != null
        ? "Created at: ${request.createdAt!.formattedDateTime}"
        : "";

    return Container(
      margin: EdgeInsets.only(bottom: context.h(16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(24)),
        boxShadow: CustomColors.cardShadow,
        border: Border.all(
          color: CustomColors.greyColor.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            PatientTreatmentRequestDetailScreen.routeName,
            arguments: request,
          );
        },
        borderRadius: BorderRadius.circular(context.r(24)),
        child: Padding(
          padding: EdgeInsets.all(context.w(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Ref: ',
                            style: CustomFonts.black17w600,
                            children: [
                              TextSpan(
                                text: title.toString(),
                                style: CustomFonts.black16w600.copyWith(
                                  color: CustomColors.purpleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (subtitle.isNotEmpty)
                          Text(subtitle, style: CustomFonts.grey14w400),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey.shade400,
                    size: context.sp(24),
                  ),
                ],
              ),
              if (treatments.isNotEmpty) ...[
                SizedBox(height: context.h(12)),
                const Divider(height: 1),
                SizedBox(height: context.h(12)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(treatments.length, (index) {
                    final t = treatments[index];
                    final isLast = index == treatments.length - 1;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: isLast ? 0 : context.h(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: context.h(6)),
                            child: Text(
                              "Treatment - ${index + 1}",
                              style: CustomFonts.black16w600,
                            ),
                          ),
                          SimulationTreatmentAreaChip(
                            label: t.name ?? "",
                            icon: t.icon,
                            isTreatment: true,
                            imageUrl: t.image,
                          ),
                          if (t.areas != null && t.areas!.isNotEmpty) ...[
                            SizedBox(height: context.h(10)),
                            Padding(
                              padding: EdgeInsets.only(
                                left: context.w(4),
                                bottom: context.h(8),
                              ),
                              child: Text(
                                "Selected Areas",
                                style: CustomFonts.black16w600,
                              ),
                            ),
                            Wrap(
                              spacing: context.w(8),
                              runSpacing: context.h(8),
                              children: t.areas!.map((area) {
                                return SimulationTreatmentAreaChip(
                                  label: area.name ?? "",
                                  icon: area.icon,
                                  isTreatment: false,
                                  imageUrl: area.image,
                                  materials: area.materials,
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
