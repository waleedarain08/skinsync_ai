import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/requests/instructions_request.dart';
import '../models/responses/appointment_detail_response.dart';
import '../models/responses/instructions_response.dart';
import '../models/responses/post_treatment_photos_response.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/string_utils.dart';
import '../view_models/appointment_view_model.dart';
import '../widgets/app_loader.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/dialogs/image_source_dialog.dart';

class PostTreatmentInstructionsScreen extends ConsumerStatefulWidget {
  static const String routeName = "/PostTreatmentInstructionsScreen";
  final List<DetailedAppointmentTreatment>? treatments;

  const PostTreatmentInstructionsScreen({super.key, this.treatments});

  @override
  ConsumerState<PostTreatmentInstructionsScreen> createState() =>
      _PostTreatmentInstructionsScreenState();
}

class _PostTreatmentInstructionsScreenState
    extends ConsumerState<PostTreatmentInstructionsScreen> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  InstructionsRequest? _buildRequest() {
    final appointmentId = ref.read(appointmentProvider).appointmentDetail?.id;
    if (appointmentId == null) return null;

    final sessionIds = (widget.treatments ?? [])
        .map((t) => t.sessionId) // <-- adjust to your real field name
        .whereType<int>()
        .toSet()
        .toList();

    return InstructionsRequest(
      appointmentId: appointmentId,
      sessionIds: sessionIds,
    );
  }

  Future<void> _load() async {
    final request = _buildRequest();
    if (request != null) {
      final vm = ref.read(appointmentProvider.notifier);
      vm.clearTreatmentCare();
      await vm.postInstructions(request: request);
      if (!mounted) return;
      await vm.postTreatmentPhotos(request: request);
    }
    if (mounted) setState(() => _loaded = true);
  }

  Future<void> _onUpload({
    required PostTreatmentPhotoData item,
    required PhotoMilestone milestone,
  }) async {
    final request = _buildRequest();
    final treatmentId = item.treatmentId;
    final areaId = item.areaId;
    if (request == null || treatmentId == null || areaId == null) {
      EasyLoading.showError('Missing treatment details');
      return;
    }

    final source = await showImageSourceDialog(context, showGallery: false);
    if (source == null || !mounted) return;

    await ref
        .read(appointmentProvider.notifier)
        .uploadMilestonePhoto(
          source: source,
          treatmentId: treatmentId,
          areaId: areaId,
          milestone: milestone,
          insRequest: request,
        );
  }

  List<String> _parseInstructions(String? raw) {
    if (raw == null) return [];
    return raw
        .split('\n')
        .map((l) => l.replaceFirst(RegExp(r'^\s*[•\-*]\s*'), '').trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final instructions = ref.watch(
      appointmentProvider.select((s) => s.postInstruction),
    );
    final photoItems = ref.watch(
      appointmentProvider.select((s) => s.postTreatmentPhoto),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: const CustomAppBar(title: "Post-Treatment Care"),
        body: Column(
          children: [
            SizedBox(height: context.h(8)),
            TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey.shade500,
              indicatorColor: CustomColors.darkPurple,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: CustomFonts.black16w600,
              unselectedLabelStyle: CustomFonts.grey16w500,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: "Guidelines"),
                Tab(text: "Photos"),
              ],
            ),
            SizedBox(height: context.h(8)),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTab(
                    banner: _buildTopBanner(context),
                    emptyText: "No post-treatment instructions available.",
                    children: [
                      for (final item in instructions)
                        _buildInstructionCard(context, item: item),
                    ],
                  ),
                  _buildTab(
                    banner: _buildTopBannerPhotos(context),
                    emptyText: "No photo milestones required.",
                    children: [
                      for (final item in photoItems)
                        _buildTreatmentPhotoSection(context, item: item),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(
            context.w(20),
            context.h(10),
            context.w(20),
            context.h(20) + MediaQuery.paddingOf(context).bottom,
          ),
          child: CustomButton(
            onPressed: () => Navigator.pop(context),
            text: "Got It",
          ),
        ),
      ),
    );
  }

  Widget _buildTab({
    required Widget banner,
    required String emptyText,
    required List<Widget> children,
  }) {
    if (!_loaded) return const AppLoader();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.w(20),
        context.h(10),
        context.w(20),
        context.h(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          banner,
          SizedBox(height: context.h(24)),
          if (children.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: context.h(40)),
                child: Text(emptyText, style: CustomFonts.grey16w500),
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }

  // ---------------- Photos tab ----------------

  Widget _buildTreatmentPhotoSection(
    BuildContext context, {
    required PostTreatmentPhotoData item,
  }) {
    final areaName = item.areaName;
    return Container(
      margin: EdgeInsets.only(bottom: context.h(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  (item.treatmentName ?? 'Treatment').capitalize,
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
          ...item.photoMilestone.map(
            (m) => _buildMilestoneCard(context, item: item, milestone: m),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(
    BuildContext context, {
    required PostTreatmentPhotoData item,
    required PhotoMilestone milestone,
  }) {
    final requiredPhotos = milestone.requiredPhotos ?? 0;
    final uploaded = milestone.uploadedPhotos;
    final isCompleted = requiredPhotos > 0 && uploaded.length >= requiredPhotos;

    return Container(
      margin: EdgeInsets.only(bottom: context.h(16)),
      padding: EdgeInsets.all(context.w(18)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(24)),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: CustomColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(context.w(8)),
                      decoration: BoxDecoration(
                        color: CustomColors.darkPurple.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.calendar_tick,
                        size: context.sp(18),
                        color: CustomColors.darkPurple,
                      ),
                    ),
                    SizedBox(width: context.w(10)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            milestone.title ?? 'Milestone',
                            style: CustomFonts.black16w700,
                          ),
                          Text(
                            "Day ${milestone.numberOfDays ?? 0} After Treatment • $requiredPhotos Photo(s) Required",
                            style: CustomFonts.grey12w400,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.w(8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(10),
                  vertical: context.h(4),
                ),
                decoration: BoxDecoration(
                  color: (isCompleted ? Colors.green : Colors.orange)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(context.r(12)),
                ),
                child: Text(
                  isCompleted
                      ? "COMPLETED"
                      : "${uploaded.length}/$requiredPhotos UPLOADED",
                  style: CustomFonts.blue10w700.copyWith(
                    color: isCompleted ? Colors.green : Colors.orange,
                    fontSize: context.sp(9),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(16)),
          Row(
            children: List.generate(requiredPhotos, (index) {
              final hasPhoto = index < uploaded.length;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < requiredPhotos - 1 ? context.w(10) : 0,
                  ),
                  child: hasPhoto
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(context.r(16)),
                          child: CachedNetworkImage(
                            imageUrl: uploaded[index],
                            height: context.w(85),
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: context.w(85),
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: CupertinoActivityIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: context.w(85),
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        )
                      : Container(
                          height: context.w(85),
                          decoration: BoxDecoration(
                            color: CustomColors.darkPurple.withValues(
                              alpha: 0.05,
                            ),
                            borderRadius: BorderRadius.circular(context.r(16)),
                            border: Border.all(
                              color: CustomColors.darkPurple.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo_rounded,
                                color: CustomColors.darkPurple,
                                size: context.sp(22),
                              ),
                              SizedBox(height: context.h(4)),
                              Text(
                                "Photo ${index + 1}",
                                style: CustomFonts.black12w600.copyWith(
                                  color: CustomColors.darkPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              );
            }),
          ),
          SizedBox(height: context.h(12)),
          Align(
            alignment: Alignment.bottomRight,
            child: CustomButton(
              width: context.w(110),
              height: context.h(40),
              text: 'Upload',
              backgroundColor: CustomColors.darkPurple,
              textColor: Colors.white,
              onPressed: isCompleted
                  ? null
                  : () => _onUpload(item: item, milestone: milestone),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Guidelines tab ----------------

  Widget _buildInstructionCard(
    BuildContext context, {
    required InstructionData item,
  }) {
    final instructions = _parseInstructions(item.preTreatmentInstructions);
    final areaName = item.areaName;

    return Container(
      margin: EdgeInsets.only(bottom: context.h(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  (item.treatmentName ?? 'Treatment').capitalize,
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
          Container(
            padding: EdgeInsets.all(context.w(20)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.r(24)),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              boxShadow: CustomColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < instructions.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: context.h(10)),
                      child: const Divider(
                        color: CustomColors.greyColor,
                        height: 1,
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(context.w(6)),
                        decoration: BoxDecoration(
                          color: CustomColors.darkPurple.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: CustomColors.darkPurple,
                          size: context.sp(16),
                        ),
                      ),
                      SizedBox(width: context.w(12)),
                      Expanded(
                        child: Text(
                          instructions[i],
                          style: CustomFonts.black14w600.copyWith(
                            height: 1.35,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (item.preTreatmentAttachments.isNotEmpty) ...[
                  SizedBox(height: context.h(16)),
                  const Divider(color: CustomColors.greyColor, height: 1),
                  SizedBox(height: context.h(12)),
                  Text(
                    "AFTERCARE ATTACHMENTS",
                    style: CustomFonts.darkPurple10w700.copyWith(
                      letterSpacing: 1.0,
                    ),
                  ),
                  SizedBox(height: context.h(8)),
                  Wrap(
                    spacing: context.w(8),
                    runSpacing: context.h(8),
                    children: item.preTreatmentAttachments
                        .map((att) => _buildAttachmentChip(context, att))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentChip(
    BuildContext context,
    PreTreatmentAttachment att,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final url = att.url;
          if (url != null && url.isNotEmpty) {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
        borderRadius: BorderRadius.circular(context.r(12)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.w(12),
            vertical: context.h(8),
          ),
          decoration: BoxDecoration(
            color: CustomColors.darkPurple.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(context.r(12)),
            border: Border.all(
              color: CustomColors.darkPurple.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.document_download,
                size: context.sp(16),
                color: CustomColors.darkPurple,
              ),
              SizedBox(width: context.w(6)),
              Flexible(
                child: Text(
                  att.name ?? 'Attachment',
                  style: CustomFonts.black12w600.copyWith(
                    color: CustomColors.darkPurple,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.w(20)),
      decoration: BoxDecoration(
        gradient: CustomColors.purpleBlueGradient,
        borderRadius: BorderRadius.circular(context.r(24)),
        boxShadow: CustomColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.w(12)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Icon(
              Iconsax.clipboard_tick,
              color: CustomColors.blackColor,
              size: context.sp(26),
            ),
          ),
          SizedBox(width: context.w(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Post-Treatment Recovery Care",
                  style: CustomFonts.black18w600,
                ),
                SizedBox(height: context.h(4)),
                Text(
                  "Follow these aftercare guidelines for smooth recovery and long-lasting results.",
                  style: CustomFonts.black12w600.copyWith(
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBannerPhotos(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.w(20)),
      decoration: BoxDecoration(
        gradient: CustomColors.purpleBlueGradient,
        borderRadius: BorderRadius.circular(context.r(24)),
        boxShadow: CustomColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(context.w(12)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.35),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Icon(
              Iconsax.camera,
              color: CustomColors.blackColor,
              size: context.sp(26),
            ),
          ),
          SizedBox(width: context.w(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Photo Milestone Requirements",
                  style: CustomFonts.black18w600,
                ),
                SizedBox(height: context.h(4)),
                Text(
                  "Your clinic requires photo updates at specific day milestones after treatment to track recovery.",
                  style: CustomFonts.black12w600.copyWith(
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
