import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../models/responses/appointment_detail_response.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../view_models/appointment_view_model.dart';
import '../widgets/app_loader.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/dialogs/image_source_dialog.dart';
// API-driven imports, not used while instructions and milestones are static:
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import '../models/requests/instructions_request.dart';
// import '../models/responses/post_treatment_photos_response.dart';
// import '../utils/string_utils.dart';
// import '../widgets/instruction_card_widget.dart';

/// Static milestone definition (replaces PhotoMilestone from the API for now).
class _StaticMilestone {
  final String title;
  final int numberOfDays;
  final int requiredPhotos;

  const _StaticMilestone({
    required this.title,
    required this.numberOfDays,
    required this.requiredPhotos,
  });
}

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
  // ---------------- Static content ----------------

  static const String _staticInstructionsTitle = "Post-Treatment Instructions";
  static const List<String> _staticInstructions = [
    "Temporary swelling, tenderness, firmness, bruising, redness, itching, or mild discomfort may occur after treatment. Follow all aftercare instructions provided by your treating provider.",
    "Avoid applying makeup for 12 hours after treatment. For the first 24 hours, minimize strenuous exercise, extensive sun or heat exposure, and alcoholic beverages, as these may increase temporary redness, swelling, or itching.",
    "Avoid unnecessary pressure or manipulation of the treated temple area unless specifically directed by your provider. Contact your clinic if you experience symptoms that are concerning, worsening, unusual, or persistent.",
    "Seek immediate medical attention if you experience changes in vision, unusual or severe pain, whitening or blanching of the skin, or symptoms suggestive of a stroke. These can be signs of a rare but serious complication associated with dermal filler treatment.",
    "Keep all recommended follow-up appointments and submit post-treatment photos through SkinSync when requested so your provider can monitor your treatment progress.",
  ];

  // TODO: adjust days / photo counts to your clinic's real milestones.
  static const List<_StaticMilestone> _staticMilestones = [
    _StaticMilestone(
      title: "Day 2 Post-Treatment",
      numberOfDays: 2,
      requiredPhotos: 2,
    ),
    _StaticMilestone(
      title: "Day 5 Post-Treatment",
      numberOfDays: 5,
      requiredPhotos: 1,
    ),
    _StaticMilestone(
      title: "Day 14 Follow-Up Result",
      numberOfDays: 14,
      requiredPhotos: 2,
    ),
  ];

  bool _loaded = false;

  /// Photos picked + uploaded to Firebase, waiting for the Upload button.
  final Map<String, List<String>> _pending = {};

  /// Photos "submitted" locally (stands in for photos saved on the server).
  final Map<String, List<String>> _uploaded = {};

  String _milestoneKey(_StaticMilestone m) => '${m.numberOfDays}_${m.title}';

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    // Instructions and milestones are static, so nothing to fetch.
    //
    // final request = _buildRequest();
    // if (request != null) {
    //   final vm = ref.read(appointmentProvider.notifier);
    //   vm.clearTreatmentCare();
    //   await vm.postInstructions(request: request);
    //   if (!mounted) return;
    //   await vm.postTreatmentPhotos(request: request);
    // }
    if (mounted) setState(() => _loaded = true);
  }

  // InstructionsRequest? _buildRequest() {
  //   final appointmentId = ref.read(appointmentProvider).appointmentDetail?.id;
  //   if (appointmentId == null) return null;
  //
  //   final sessionIds = (widget.treatments ?? [])
  //       .map((t) => t.sessionId)
  //       .whereType<int>()
  //       .toSet()
  //       .toList();
  //
  //   return InstructionsRequest(
  //     appointmentId: appointmentId,
  //     sessionIds: sessionIds,
  //   );
  // }

  Future<void> _onPickPhoto({required String key}) async {
    final source = await showImageSourceDialog(context, showGallery: false);
    if (source == null || !mounted) return;

    final url = await ref
        .read(appointmentProvider.notifier)
        .uploadPostTreatmentImage(source: source);
    if (url == null || !mounted) return;

    setState(() => _pending.putIfAbsent(key, () => []).add(url));
  }

  Future<void> _onSubmit({required String key}) async {
    final pending = List<String>.from(_pending[key] ?? const []);
    if (pending.isEmpty) return;

    // Milestone photos API disabled for now.
    // final request = _buildRequest();
    // final ok = await ref
    //     .read(appointmentProvider.notifier)
    //     .submitMilestonePhotos(
    //       treatmentId: treatmentId,
    //       areaId: areaId,
    //       milestone: milestone,
    //       newPhotos: pending,
    //       insRequest: request,
    //     );
    // if (!ok) return;

    if (!mounted) return;
    setState(() {
      _uploaded.putIfAbsent(key, () => []).addAll(pending);
      _pending.remove(key);
    });
  }

  @override
  Widget build(BuildContext context) {
    // API-driven data, replaced by the static content above.
    // final instructions = ref.watch(
    //   appointmentProvider.select((s) => s.postInstruction),
    // );
    // final photoItems = ref.watch(
    //   appointmentProvider.select((s) => s.postTreatmentPhoto),
    // );

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
                    children: [_buildStaticInstructionsCard(context)],
                  ),
                  _buildTab(
                    banner: _buildTopBannerPhotos(context),
                    children: [
                      for (final m in _staticMilestones)
                        _buildMilestoneCard(context, milestone: m),
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

  Widget _buildTab({required Widget banner, required List<Widget> children}) {
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
        children: [banner, SizedBox(height: context.h(24)), ...children],
      ),
    );
  }

  // ---------------- Guidelines tab (static) ----------------

  Widget _buildStaticInstructionsCard(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(context.w(6)),
                decoration: BoxDecoration(
                  color: CustomColors.purpleColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.clipboard_tick,
                  color: CustomColors.darkPurple,
                  size: context.sp(18),
                ),
              ),
              SizedBox(width: context.w(10)),
              Expanded(
                child: Text(
                  _staticInstructionsTitle,
                  style: CustomFonts.black18w600,
                ),
              ),
            ],
          ),
          SizedBox(height: context.h(16)),
          for (int i = 0; i < _staticInstructions.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(vertical: context.h(12)),
                child: const Divider(color: CustomColors.greyColor, height: 1),
              ),
            Text(
              _staticInstructions[i],
              style: CustomFonts.black14w600.copyWith(
                height: 1.45,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------- Photos tab (static milestones) ----------------

  Widget _buildMilestoneCard(
    BuildContext context, {
    required _StaticMilestone milestone,
  }) {
    final requiredPhotos = milestone.requiredPhotos;
    final key = _milestoneKey(milestone);
    final uploaded = _uploaded[key] ?? const <String>[];
    final pending = _pending[key] ?? const <String>[];
    final isCompleted = requiredPhotos > 0 && uploaded.length >= requiredPhotos;

    Widget networkImage(String url) => CachedNetworkImage(
      imageUrl: url,
      height: context.w(85),
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        height: context.w(85),
        color: Colors.grey.shade100,
        child: const Center(child: CupertinoActivityIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        height: context.w(85),
        color: Colors.grey.shade100,
        child: const Icon(Icons.image_not_supported),
      ),
    );

    Widget slot(int index) {
      // 1) Already submitted
      if (index < uploaded.length) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(context.r(16)),
          child: networkImage(uploaded[index]),
        );
      }

      // 2) Uploaded to Firebase, waiting for the Upload button
      final pendingIndex = index - uploaded.length;
      if (pendingIndex < pending.length) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(context.r(16)),
              child: networkImage(pending[pendingIndex]),
            ),
            Positioned(
              top: context.h(4),
              right: context.w(4),
              child: GestureDetector(
                onTap: () =>
                    setState(() => _pending[key]?.removeAt(pendingIndex)),
                child: Container(
                  padding: EdgeInsets.all(context.w(3)),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: context.sp(14),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      }

      // 3) Empty slot: tap to pick + upload to Firebase
      return InkWell(
        onTap: () => _onPickPhoto(key: key),
        borderRadius: BorderRadius.circular(context.r(16)),
        child: Container(
          height: context.w(85),
          decoration: BoxDecoration(
            color: CustomColors.darkPurple.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(context.r(16)),
            border: Border.all(
              color: CustomColors.darkPurple.withValues(alpha: 0.3),
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
      );
    }

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
                          Text(milestone.title, style: CustomFonts.black16w700),
                          Text(
                            "Day ${milestone.numberOfDays} After Treatment • $requiredPhotos Photo(s) Required",
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
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < requiredPhotos - 1 ? context.w(10) : 0,
                  ),
                  child: slot(index),
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
              onPressed: (isCompleted || pending.isEmpty)
                  ? null
                  : () => _onSubmit(key: key),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Banners ----------------

  Widget _buildTopBanner(BuildContext context) {
    return _buildBanner(
      context,
      icon: Iconsax.clipboard_tick,
      title: "Post-Treatment Recovery Care",
      subtitle:
          "Follow these aftercare guidelines for smooth recovery and long-lasting results.",
    );
  }

  Widget _buildTopBannerPhotos(BuildContext context) {
    return _buildBanner(
      context,
      icon: Iconsax.camera,
      title: "Photo Milestone Requirements",
      subtitle:
          "Your clinic requires photo updates at specific day milestones after treatment to track recovery.",
    );
  }

  Widget _buildBanner(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
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
              icon,
              color: CustomColors.blackColor,
              size: context.sp(26),
            ),
          ),
          SizedBox(width: context.w(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: CustomFonts.black18w600),
                SizedBox(height: context.h(4)),
                Text(
                  subtitle,
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