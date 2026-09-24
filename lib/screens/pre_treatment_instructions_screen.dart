import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../models/requests/instructions_request.dart';
import '../models/responses/appointment_detail_response.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../view_models/appointment_view_model.dart';
import '../widgets/app_loader.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/dialogs/image_source_dialog.dart';
import '../widgets/instruction_card_widget.dart';

class PreTreatmentInstructionsScreen extends ConsumerStatefulWidget {
  static const String routeName = "/PreTreatmentInstructionsScreen";

  final List<DetailedAppointmentTreatment>? treatments;

  const PreTreatmentInstructionsScreen({super.key, this.treatments});

  @override
  ConsumerState<PreTreatmentInstructionsScreen> createState() =>
      _PreTreatmentInstructionsScreenState();
}

class _PreTreatmentInstructionsScreenState
    extends ConsumerState<PreTreatmentInstructionsScreen> {
  static const int _maxPhotos = 3;

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
        .map((t) => t.sessionId)
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
      await Future.wait([
        vm.preInstructions(request: request),
        vm.getPerTreatmentPhotos(appointmentId: request.appointmentId),
      ]);
    }
    if (mounted) setState(() => _loaded = true);
  }

  /// Pick -> upload to Firebase -> savePerTreatmentPhotos (all in the VM).
  Future<void> _addPhoto() async {
    final request = _buildRequest();
    if (request == null) {
      EasyLoading.showError('Appointment not found');
      return;
    }

    final source = await showImageSourceDialog(context,showGallery: false);
    if (source == null || !mounted) return;

    await ref
        .read(appointmentProvider.notifier)
        .addPerTreatmentPhoto(
          appointmentId: request.appointmentId,
          source: source,
        );
  }

  @override
  Widget build(BuildContext context) {
    final instructions = ref.watch(
      appointmentProvider.select((s) => s.preInstruction),
    );
    final photos = ref.watch(
      appointmentProvider.select((s) => s.perTreatmentPhotos),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        appBar: const CustomAppBar(title: "Pre-Treatment Care"),
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
                Tab(text: "Doctor Photos"),
              ],
            ),
            SizedBox(height: context.h(8)),
            Expanded(
              child: TabBarView(
                children: [
                  // ---------------------------------------------------------
                  // TAB 1 - GUIDELINES
                  // ---------------------------------------------------------
                  !_loaded
                      ? const AppLoader()
                      : SingleChildScrollView(
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
                              _buildTopBanner(context),
                              SizedBox(height: context.h(24)),
                              if (instructions.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: context.h(40),
                                    ),
                                    child: Text(
                                      "No instructions available.",
                                      style: CustomFonts.grey16w500,
                                    ),
                                  ),
                                )
                              else
                                ...instructions.map(
                                  (item) => InstructionCard(
                                    item: item,
                                    rawInstructions: item.instructions,
                                  ),
                                ),
                            ],
                          ),
                        ),

                  // ---------------------------------------------------------
                  // TAB 2 - DOCTOR PHOTOS
                  // ---------------------------------------------------------
                  !_loaded
                      ? const AppLoader()
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            context.w(20),
                            context.h(10),
                            context.w(20),
                            context.h(20),
                          ),
                          child: _buildDoctorPhotos(context, photos),
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

 Widget _buildDoctorPhotos(BuildContext context, List<String> photos) {
  // Always show at least 3 boxes; if the server ever returns more, show them all.
  final slotCount = photos.length > _maxPhotos ? photos.length : _maxPhotos;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildDoctorPhotoBanner(context),
      SizedBox(height: context.h(24)),
      Text("Your Photos", style: CustomFonts.black18w600),
      SizedBox(height: context.h(6)),
      Text(
        "Add up to $_maxPhotos photos for your treatment record.",
        style: CustomFonts.grey12w400,
      ),
      SizedBox(height: context.h(16)),
      GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: context.w(10),
        crossAxisSpacing: context.w(10),
        children: [
          for (int i = 0; i < slotCount; i++)
            i < photos.length
                ? _buildPhotoTile(context, url: photos[i], index: i)
                : _buildAddTile(context, index: i),
        ],
      ),
    ],
  );
}

Widget _buildAddTile(BuildContext context, {required int index}) {
  return InkWell(
    onTap: _addPhoto,
    borderRadius: BorderRadius.circular(context.r(16)),
    child: Container(
      decoration: BoxDecoration(
        color: CustomColors.darkPurple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(
          color: CustomColors.darkPurple.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo_rounded,
            color: CustomColors.darkPurple,
            size: context.sp(28),
          ),
          SizedBox(height: context.h(6)),
          Text(
            "Photo ${index + 1}",
            style: CustomFonts.black12w600.copyWith(
              color: CustomColors.darkPurple,
            ),
          ),
          SizedBox(height: context.h(2)),
          Text("Add", style: CustomFonts.grey12w400),
        ],
      ),
    ),
  );
}
 
  Widget _buildPhotoTile(
    BuildContext context, {
    required String url,
    required int index,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.r(16)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: Colors.grey.shade100,
              child: const Center(child: CupertinoActivityIndicator()),
            ),
            errorWidget: (_, __, ___) => Container(
              color: Colors.grey.shade100,
              child: const Icon(Icons.image_not_supported),
            ),
          ),
          Positioned(
            left: context.w(6),
            bottom: context.h(6),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.w(7),
                vertical: context.h(3),
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(context.r(8)),
              ),
              child: Text(
                "Photo ${index + 1}",
                style: CustomFonts.white10w600,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTopBanner(BuildContext context) {
    return _buildBanner(
      context,
      icon: Iconsax.clipboard_text,
      title: "Pre-Treatment Guidelines",
      subtitle:
          "Follow these essential care guidelines prior to your visit for optimal results.",
    );
  }

  Widget _buildDoctorPhotoBanner(BuildContext context) {
    return _buildBanner(
      context,
      icon: Iconsax.camera,
      title: "Doctor Photos",
      subtitle: "Upload photos as requested by your practitioner.",
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