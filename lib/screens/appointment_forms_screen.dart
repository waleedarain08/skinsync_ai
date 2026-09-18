import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../models/responses/appointment_detail_response.dart';
import '../models/responses/consent_form_response.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/string_utils.dart';
import '../view_models/forms_view_model.dart';
import '../widgets/custom_app_bar.dart';
import 'legal_document_screen.dart';

class AppointmentFormsScreen extends ConsumerStatefulWidget {
  static const String routeName = "/AppointmentFormsScreen";
  final AppointmentDetailData? detail;

  const AppointmentFormsScreen({super.key, this.detail});

  @override
  ConsumerState<AppointmentFormsScreen> createState() =>
      _AppointmentFormsScreenState();
}

class _AppointmentFormsScreenState
    extends ConsumerState<AppointmentFormsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(formsViewModel.notifier).fetchForms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formsState = ref.watch(formsViewModel);
    final signedDocs = formsState.signDocument;
    final unsignedDocs = formsState.unSignDocument;

    final signedCount = signedDocs.length;
    final unsignedCount = unsignedDocs.length;
    final totalCount = signedCount + unsignedCount;

    // Extract treatments from appointment detail
    final treatments = widget.detail?.treatments ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: const CustomAppBar(title: "Appointment Forms"),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          context.w(20),
          context.h(10),
          context.w(20),
          context.h(40),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Summary Banner Card
            _buildSummaryBanner(
              context,
              signedCount: signedCount > 0 ? signedCount : 2,
              unsignedCount: unsignedCount > 0 ? unsignedCount : 1,
              totalCount: totalCount > 0 ? totalCount : 3,
            ),
            SizedBox(height: context.h(24)),

            // Treatment-Wise Forms List
            if (treatments.isNotEmpty)
              ...treatments.map((treatment) {
                return _buildTreatmentSection(
                  context,
                  treatmentName: treatment.treatmentName ?? "Treatment Form",
                  areaName: treatment.areaName,
                  signedDocs: signedDocs,
                  unsignedDocs: unsignedDocs,
                );
              })
            else ...[
              // Fallback Treatment Sections for Appointment
              _buildTreatmentSection(
                context,
                treatmentName: "Botox & Dermal Fillers",
                areaName: "Cheeks & Forehead",
                signedDocs: signedDocs,
                unsignedDocs: unsignedDocs,
              ),
              _buildTreatmentSection(
                context,
                treatmentName: "Skin Consultation & Analysis",
                areaName: "Full Face",
                signedDocs: signedDocs,
                unsignedDocs: unsignedDocs,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBanner(
    BuildContext context, {
    required int signedCount,
    required int unsignedCount,
    required int totalCount,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.w(20)),
      decoration: BoxDecoration(
        gradient: CustomColors.purpleBlueGradient,
        borderRadius: BorderRadius.circular(context.r(24)),
        boxShadow: CustomColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.w(10)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  Iconsax.document_text,
                  color: CustomColors.blackColor,
                  size: context.sp(22),
                ),
              ),
              SizedBox(width: context.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Required Consent & Forms",
                      style: CustomFonts.black18w600,
                    ),
                    SizedBox(height: context.h(2)),
                    Text(
                      "Please review and sign all required forms before your visit.",
                      style: CustomFonts.black12w600.copyWith(
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(16)),
          const Divider(color: Colors.black12, height: 1),
          SizedBox(height: context.h(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, "Total Forms", "$totalCount"),
              Container(width: 1, height: context.h(24), color: Colors.black12),
              _buildStatItem(context, "Signed", "$signedCount", isSigned: true),
              Container(width: 1, height: context.h(24), color: Colors.black12),
              _buildStatItem(context, "Unsigned", "$unsignedCount", isUnsigned: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String count, {
    bool isSigned = false,
    bool isUnsigned = false,
  }) {
    Color textColor = CustomColors.blackColor;
    if (isSigned) textColor = Colors.green.shade900;
    if (isUnsigned) textColor = Colors.deepOrange.shade900;

    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            color: textColor,
            fontSize: context.sp(18),
            fontWeight: FontWeight.bold,
            fontFamily: 'Degular',
          ),
        ),
        SizedBox(height: context.h(2)),
        Text(
          label,
          style: CustomFonts.black12w600.copyWith(color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildTreatmentSection(
    BuildContext context, {
    required String treatmentName,
    String? areaName,
    required List<Document> signedDocs,
    required List<Document> unsignedDocs,
  }) {
    // Generate form list for this treatment
    final formItems = <_FormItemData>[];

    // Map unsigned docs
    for (var doc in unsignedDocs) {
      formItems.add(
        _FormItemData(
          title: doc.title ?? "Informed Consent Form",
          type: doc.type ?? "Consent Form",
          isSigned: false,
          document: doc,
        ),
      );
    }

    // Map signed docs
    for (var doc in signedDocs) {
      formItems.add(
        _FormItemData(
          title: doc.title ?? "Medical History Clearance",
          type: doc.type ?? "Signed Agreement",
          isSigned: true,
          document: doc,
        ),
      );
    }

    // Default dummy items if backend list is empty
    if (formItems.isEmpty) {
      formItems.addAll([
        _FormItemData(
          title: "$treatmentName Informed Consent Form",
          type: "Treatment Consent • Required",
          isSigned: true,
        ),
        _FormItemData(
          title: "Medical History & Allergy Clearance",
          type: "Patient Intake • Required",
          isSigned: true,
        ),
        _FormItemData(
          title: "Post-Treatment Care & Compliance",
          type: "Compliance Form • Optional",
          isSigned: false,
        ),
      ]);
    }

    return Container(
      margin: EdgeInsets.only(bottom: context.h(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Treatment Section Heading
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.w(6)),
                decoration: BoxDecoration(
                  color: CustomColors.purpleColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.mask,
                  color: CustomColors.darkPurple,
                  size: context.sp(18),
                ),
              ),
              SizedBox(width: context.w(10)),
              Expanded(
                child: Text(
                  treatmentName.capitalize,
                  style: CustomFonts.black18w600,
                ),
              ),
              if (areaName != null && areaName.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.w(10),
                    vertical: context.h(4),
                  ),
                  decoration: BoxDecoration(
                    color: CustomColors.darkPurple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(context.r(12)),
                  ),
                  child: Text(
                    areaName,
                    style: CustomFonts.black12w600.copyWith(
                      color: CustomColors.darkPurple,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: context.h(12)),

          // Clinic Container Style Box for Forms
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.r(24)),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: CustomColors.cardShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.r(24)),
              child: Column(
                children: [
                  for (int i = 0; i < formItems.length; i++) ...[
                    if (i > 0) const Divider(color: CustomColors.greyColor, height: 1),
                    _buildFormTile(context, formItems[i]),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormTile(BuildContext context, _FormItemData item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (item.document != null) {
            Navigator.pushNamed(
              context,
              LegalDocumentScreen.routeName,
              arguments: LegalDocumentArgs(
                title: item.title,
                url: item.document!.url,
                storageFileName: 'signed_form_${item.document!.id}.pdf',
                formId: item.document!.id,
                isAlreadySigned: item.isSigned,
                type: item.document!.type,
                globalSku: item.document!.globalSku,
              ),
            );
          } else {
            Navigator.pushNamed(
              context,
              LegalDocumentScreen.routeName,
              arguments: LegalDocumentArgs(
                title: item.title,
                assetPath: 'assets/pdf/privacy_policy.pdf',
                storageFileName: 'dummy_${item.title.replaceAll(' ', '_')}.pdf',
                isAlreadySigned: item.isSigned,
              ),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(18),
            vertical: context.h(16),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.w(10)),
                decoration: BoxDecoration(
                  color: item.isSigned
                      ? Colors.green.withValues(alpha: 0.1)
                      : CustomColors.purpleColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isSigned ? Iconsax.document_text_1 : Iconsax.document_code,
                  color: item.isSigned ? Colors.green : CustomColors.darkPurple,
                  size: context.sp(20),
                ),
              ),
              SizedBox(width: context.w(14)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: CustomFonts.black16w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.h(4)),
                    Text(
                      item.type,
                      style: CustomFonts.black12w600.copyWith(
                        color: Colors.black54,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.w(10)),

              // Status Badge (Signed / Unsigned)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(10),
                  vertical: context.h(4),
                ),
                decoration: BoxDecoration(
                  color: item.isSigned
                      ? Colors.green.withValues(alpha: 0.12)
                      : Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(context.r(20)),
                  border: Border.all(
                    color: item.isSigned
                        ? Colors.green.withValues(alpha: 0.4)
                        : Colors.orange.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  item.isSigned ? "SIGNED" : "UNSIGNED",
                  style: TextStyle(
                    color: item.isSigned ? Colors.green.shade900 : Colors.deepOrange.shade900,
                    fontSize: context.sp(9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: context.w(8)),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: context.sp(20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormItemData {
  final String title;
  final String type;
  final bool isSigned;
  final Document? document;

  _FormItemData({
    required this.title,
    required this.type,
    required this.isSigned,
    this.document,
  });
}
