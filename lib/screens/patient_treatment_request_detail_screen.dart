import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../models/responses/patient_treatment_request_response.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/date_time_utils.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/medical_disclaimer_banner.dart';
import '../widgets/simulation_card.dart';

class PatientTreatmentRequestDetailScreen extends StatefulWidget {
  final PatientTreatmentRequest request;
  const PatientTreatmentRequestDetailScreen({super.key, required this.request});

  static const String routeName = '/PatientTreatmentRequestDetailScreen';

  @override
  State<PatientTreatmentRequestDetailScreen> createState() =>
      _PatientTreatmentRequestDetailScreenState();
}

class _PatientTreatmentRequestDetailScreenState
    extends State<PatientTreatmentRequestDetailScreen> {
  String _selectedSubTab = "Simulation";

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final sim = request;

    final title = request.refId;
    final subtitle = request.createdAt?.formattedDateTime ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        showTitle: true,
        title: "Request Details",
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(24),
          vertical: context.h(20),
        ),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MedicalDisclaimerBanner(),
            Padding(
              padding: EdgeInsets.only(
                top: context.h(10),
                bottom: context.h(20),
              ),
              child: Row(
                children: [
                  _buildSubTabButton("Simulation"),
                  SizedBox(width: context.w(12)),
                  _buildSubTabButton("Treatments"),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: context.h(20),
                left: context.w(4),
              ),
              child: Row(
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
                        if (subtitle.isNotEmpty) ...[
                          SizedBox(height: context.h(4)),
                          Text(
                            "Created at: $subtitle",
                            style: CustomFonts.grey14w400,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SimulationCard(
              sim: sim,
              showActionButton: false,
              showImages: _selectedSubTab == "Simulation",
              showTreatments: _selectedSubTab == "Treatments",
              showCreatedAt: false,
            ),
            SizedBox(height: context.h(30)),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTabButton(String title) {
    final isSelected = _selectedSubTab == title;

    return Expanded(
      child: CustomButton(
        text: title,
        onPressed: () {
          setState(() {
            _selectedSubTab = title;
          });
        },
        height: context.h(45),
        borderRadius: context.r(100),
        isBorder: !isSelected,
      ),
    );
  }
}
