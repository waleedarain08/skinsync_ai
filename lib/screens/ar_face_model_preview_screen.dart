import 'dart:async';
import 'dart:io';

import 'package:before_after/before_after.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/responses/materials_response.dart';
import '../models/responses/treatment_area_list_response.dart';
import '../models/responses/treatment_list_response.dart';
import '../models/selected_treatment_and_areas_model.dart';
import '../utils/assets.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/enums.dart';
import '../utils/secure_storage_service.dart';
import '../view_models/checkout_view_model.dart';
import '../view_models/subscription_view_model.dart';
import '../view_models/treatment_area_view_model.dart';
import '../view_models/treatment_journey_view_model.dart';
import '../view_models/treatment_view_model.dart';
import '../widgets/app_loader.dart';
import '../widgets/bottom_sheets/material_level_sheet.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/dialogs/save_option_confirmation_dialog.dart';
import '../widgets/dialogs/upgrade_plan_dialog.dart';
import '../widgets/medical_disclaimer_banner.dart';
import '../widgets/message_cycler.dart';
import '../widgets/selected_treatment_and_areas_widget.dart';
import '../widgets/selected_treatments_summary_card.dart';
import '../widgets/service_type_button.dart';
import 'bottom_nav_screens/face_detection_screen.dart';
import 'consent_forms/ai_transparency_policy_screen.dart';
import 'treatment_journey_detail_screen.dart';
import 'treatment_journey_screen.dart';

class ArFaceModelPreviewScreen extends ConsumerStatefulWidget {
  const ArFaceModelPreviewScreen({super.key});

  static const String routeName = '/ArFaceModelPreviewScreen';

  @override
  ConsumerState<ArFaceModelPreviewScreen> createState() =>
      _ArFaceModelPreviewScreenState();
}

class _ArFaceModelPreviewScreenState
    extends ConsumerState<ArFaceModelPreviewScreen>
    with SingleTickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // State Variables & Controllers
  // ---------------------------------------------------------------------------

  bool _hasInitialized = false;
  double _sliderValue = 0.5;
  String _selectedPose = 'front';

  late final ScrollController _scrollController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  late final PagingController<int, TreatmentData> _pagingController =
      PagingController<int, TreatmentData>(
        getNextPageKey: (state) {
          final lastPageLength = state.pages?.lastOrNull?.length;
          if (lastPageLength == null) return 1;
          return lastPageLength < 10 ? null : state.nextIntPageKey;
        },
        fetchPage: (nextPage) async {
          final data = await ref
              .read(treatmentViewModel.notifier)
              .loadTreatments(page: nextPage, isSimulator: true);
          return data ?? [];
        },
      );

  // ---------------------------------------------------------------------------
  // Lifecycle Methods
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // showMedicalDisclaimerDialog(context: context);
      final selectedTreatment = ref.read(checkoutViewModel).selectedTreatments;
      final treatmentState = ref.read(treatmentViewModel);

      // Only run auto-initialization if we don't already have an AI result (e.g. not restored from history)
      if (selectedTreatment != null && treatmentState.aiImagesNull) {
        ref
            .read(checkoutViewModel.notifier)
            .addSelectedTreatment(selectedTreatment);
        await ref
            .read(treatmentViewModel.notifier)
            .onTapTreatment(
              treatmentModel: selectedTreatment,
              isCallPredictAPI: false,
            );
        await ref
            .read(treatmentAreaProvider.notifier)
            .fetchAreasByTreatment(selectedTreatment.id ?? 0);
      }
    });
  }

  Future<void> _onSaveOptionPressed() async {
    final journeyState = ref.read(treatmentJourneyProvider);
    final selectedGroup = journeyState.selectedGroup;

    if (selectedGroup == null) {
      Navigator.pushNamed(
        context,
        TreatmentJourneyScreen.routeName,
        arguments: false,
      );
    } else {
      showSaveOptionConfirmationDialog(
        screenContext: context,
        groupName: selectedGroup.name ?? 'Unknown Group',
        onConfirm: () async {
          final result = await ref
              .read(treatmentJourneyProvider.notifier)
              .createTjOptions();
          if (result == true) {
            final result2 = await ref
                .read(treatmentJourneyProvider.notifier)
                .fetchOptions(selectedGroup.id ?? 0);
            if (result2 == true) {
              Navigator.popUntil(
                context,
                ModalRoute.withName(TreatmentJourneyDetailScreen.routeName),
              );
            }
            // rootScaffoldMessengerKey.currentState?.showSnackBar(
            //         SnackBar(
            //           content: const Text(
            //             'Your journey is ready! Tap the Journey button in the top-right corner to view it.',
            //           ),
            //           duration: const Duration(seconds: 3),
            //           persist: false,
            //           behavior: SnackBarBehavior.floating,
            //           margin: EdgeInsets.only(
            //             left: context.w(16),
            //             right: context.w(16),
            //             bottom: context.h(80),
            //           ),
            //           action: SnackBarAction(
            //             label: '✕',
            //             onPressed: () {
            //               rootScaffoldMessengerKey.currentState
            //                   ?.hideCurrentSnackBar();
            //             },
            //           ),
            //         ),
            //       );
            final groupId = ref
                .read(treatmentJourneyProvider)
                .selectedGroup
                ?.id;
            if (groupId != null) {
              await ref
                  .read(treatmentJourneyProvider.notifier)
                  .fetchOptions(groupId, showloading: false);
            }
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pagingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Build Method
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    _handleInitialState();

    ref.listen(treatmentViewModel.select((s) => s.isAiImageGenerated), (
      prev,
      next,
    ) {
      if (next == true && prev != true) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });

    final isLoading = ref.watch(
      treatmentViewModel.select((state) => state.loading),
    );

    // Extracted helper method so both PopScope and AppBar use the exact same logic
    Future<void> handleBackNavigation() async {
      if (isLoading) return;

      final shouldLeave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Discard Simulation?', style: CustomFonts.black18w600),
          content: Text(
            'If you go back, you will lose all your simulation changes.',
            style: CustomFonts.black13w400,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Leave', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (shouldLeave == true && context.mounted) {
        ref.read(checkoutViewModel.notifier).clearState();
        ref
            .read(treatmentViewModel.notifier)
            .clearAllSelectedTreatments(capturedImage: true);
        ref.read(treatmentViewModel.notifier).clearAiImage();
        Navigator.of(context).pop();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await handleBackNavigation();
      },
      child: AbsorbPointer(
        absorbing: isLoading,
        child: Scaffold(
          appBar: CustomAppBar(
            showTitle: true,
            title: "AR Face Model Preview",
            onBackTap: handleBackNavigation, // Intercept AppBar back button tap
            actions: [
              IconButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  TreatmentJourneyScreen.routeName,
                ),
                icon: const FaIcon(FontAwesomeIcons.route),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: context.h(20)),
                        _buildPoseSelector(),
                        SizedBox(height: context.h(12)),
                        _buildFacePreview(),
                        const MedicalDisclaimerBanner(),
                        SelectedTreatmentAndAreasWidget(
                          margin: EdgeInsets.only(top: context.h(8)),
                          padding: EdgeInsets.symmetric(
                            horizontal: context.w(20),
                          ),
                        ),
                        SizedBox(height: context.h(20)),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.w(20),
                          ),
                          child: _buildTreatmentHeader(),
                        ),
                        SizedBox(height: context.h(8)),
                        _buildTreatmentsList(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.w(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: context.h(30)),
                              _buildAreaSelectionSection(),
                              SizedBox(height: context.h(20)),
                              _buildSummarySection(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildBottomActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Initialization Logic
  // ---------------------------------------------------------------------------

  void _handleInitialState() {
    if (!_hasInitialized) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final state = ref.read(treatmentViewModel);
        if (!state.isBefore) {
          ref.read(treatmentViewModel.notifier).toggleIsBefore();
        }
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Widget Builders
  // ---------------------------------------------------------------------------

  Widget _buildTreatmentHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Treatment Selection', style: CustomFonts.black16w600),
            InkWell(
              onTap: () {
                ref.read(checkoutViewModel.notifier).clearState();
                ref.read(treatmentViewModel.notifier).clearAiImage();
                ref
                    .read(treatmentViewModel.notifier)
                    .clearAllSelectedTreatments();
              },
              child: Text(
                "Reset",
                style: CustomFonts.black14w500Underline.copyWith(
                  color: CustomColors.textGreyColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(4)),
        Text(
          "Long press on treatment or areas to view details",
          style: CustomFonts.grey12w400.copyWith(
            color: CustomColors.textGreyColor,
            fontSize: context.sp(11),
          ),
        ),
      ],
    );
  }

  Widget _buildTreatmentsList() {
    return SizedBox(
      height: context.h(50),
      child: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) {
          return AnimationLimiter(
            key: const ValueKey('treatments_list_horizontal'),
            child: PagedListView<int, TreatmentData>(
              state: state,
              fetchNextPage: fetchNextPage,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: context.w(20)),
              physics: const BouncingScrollPhysics(),
              builderDelegate: PagedChildBuilderDelegate(
                newPageProgressIndicatorBuilder: (_) =>
                    AppLoader(size: context.h(50)),
                firstPageProgressIndicatorBuilder: (_) =>
                    AppLoader(size: context.h(40)),
                itemBuilder: (context, treatment, index) {
                  final isSelected = ref
                      .watch(checkoutViewModel)
                      .selectedTreatmentsAndAreas
                      .any((item) => item.treatment.id == treatment.id);

                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 600),
                    child: FlipAnimation(
                      child: FadeInAnimation(
                        child: Padding(
                          padding: EdgeInsets.only(right: context.w(12)),
                          child: ScaleTransition(
                            scale:
                                (!isSelected &&
                                    ref
                                        .watch(checkoutViewModel)
                                        .selectedTreatmentsAndAreas
                                        .isEmpty)
                                ? _pulseAnimation
                                : const AlwaysStoppedAnimation<double>(1.0),
                            child: ServiceTypeButton(
                              imageUrl: treatment.image ?? treatment.imageUrl,
                              icon: treatment.icon ?? PngAssets.syringe,
                              text: treatment.name ?? '-',
                              selected: isSelected,
                              description: treatment.shortDescription,
                              onPressed: () async {
                                ref
                                    .read(treatmentViewModel.notifier)
                                    .onTapTreatment(
                                      treatmentModel: treatment,
                                      isCallPredictAPI: !isSelected,
                                    );
                                ref
                                    .read(checkoutViewModel.notifier)
                                    .addSelectedTreatment(treatment);
                                await ref
                                    .read(treatmentAreaProvider.notifier)
                                    .fetchAreasByTreatment(treatment.id ?? 0);
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAreaSelectionSection() {
    return Consumer(
      builder: (context, ref, _) {
        final checkoutState = ref.watch(checkoutViewModel);
        final selectedTreatment = checkoutState.selectedTreatments;

        if (selectedTreatment == null) return const SizedBox.shrink();

        final areaState = ref.watch(treatmentAreaProvider);
        if (areaState.loading) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(color: CustomColors.purpleColor),
            ),
          );
        }

        final treatmentsArea = areaState.areas;
        if (treatmentsArea.isEmpty) return const SizedBox.shrink();

        final currentEntry = _entryForTreatment(
          checkoutState.selectedTreatmentsAndAreas,
          selectedTreatment.id,
        );

        final selectedAreaIds =
            currentEntry?.selectedAreas.map((e) => e.target.id ?? 0).toSet() ??
            <int>{};

        return _buildFlatAreas(
          rootAreas: treatmentsArea,
          selectedAreaIds: selectedAreaIds,
          treatment: selectedTreatment,
        );
      },
    );
  }

  Widget _buildSummarySection() {
    return Consumer(
      builder: (context, ref, _) {
        final selectedTreatmentsAndAreas = ref
            .watch(checkoutViewModel)
            .selectedTreatmentsAndAreas;

        return SelectedTreatmentsSummaryCard(
          selectedTreatmentsAndAreas: selectedTreatmentsAndAreas,
          onRemoveTreatment: (item) {
            ref
                .read(checkoutViewModel.notifier)
                .removeTreatment(item.treatment.id ?? 0);
          },
          onRemoveArea: (item, areaItem) {
            ref
                .read(checkoutViewModel.notifier)
                .removeArea(areaItem.target.id ?? 0);
          },
        );
      },
    );
  }

  Widget _buildBottomActions() {
    return Consumer(
      builder: (context, ref, _) {
        final selectedTreatmentsAndAreas = ref
            .watch(checkoutViewModel)
            .selectedTreatmentsAndAreas;
        final hasAnySelectedArea = selectedTreatmentsAndAreas.any(
          (item) => item.selectedAreas.isNotEmpty,
        );

        if (!hasAnySelectedArea) return const SizedBox.shrink();

        final subscriptionState = ref.watch(subscriptionProvider);
        final currentPlan = subscriptionState.currentPlan;

        bool isLimitReached = false;
        if (currentPlan != null) {
          final isUnlimited = currentPlan.unlimitedSimulation ?? false;
          final simCount = currentPlan.simulationCount ?? 0;
          final usedCount = currentPlan.usedSimulationCount ?? 0;

          if (!isUnlimited && simCount != 0 && usedCount >= simCount) {
            isLimitReached = true;
          }
        }

        return Container(
          padding: EdgeInsets.fromLTRB(
            context.w(20),
            context.h(16),
            context.w(20),
            MediaQuery.paddingOf(context).bottom + context.h(16),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: CustomButton(
                    text: "Generate Ai Image",
                    isBorder: true,
                    borderRadius: context.r(30),
                    textColor: CustomColors.blackColor,
                    height: context.h(58),
                    onPressed: () async {
                      if (isLimitReached) {
                        showUpgradePlanDialog(context);
                        return;
                      }

                      final bool hasAccepted = await SecureStorage()
                          .getAiPolicyAccepted();

                      if (!hasAccepted) {
                        if (!context.mounted) return;
                        final result = await Navigator.pushNamed(
                          context,
                          AiTransparencyPolicyScreen.routeName,
                        );
                        if (result != true) return;
                      }

                      // Show non-dismissible dialog that cycles messages every 2 seconds
                      if (context.mounted) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) => const MessageCycler(),
                        );
                      }

                      bool success = false;
                      try {
                        success = await ref
                            .read(treatmentViewModel.notifier)
                            .callPredictAPI();
                      } finally {
                        // Dismiss the dialog if still visible
                        if (context.mounted) {
                          try {
                            Navigator.of(context, rootNavigator: true).pop();
                          } catch (_) {}
                        }
                      }

                      if (success && currentPlan?.id != null) {
                        await ref
                            .read(subscriptionProvider.notifier)
                            .recordUsage(
                              usageType: UsageType.simulation,
                              subscriptionId: currentPlan!.id!,
                            );
                      }
                    },
                  ),
                ),
              ),
              context.horizontalSpace(10),
              Consumer(
                builder: (context, ref, _) {
                  final afterImage = ref.watch(
                    treatmentViewModel.select(
                      (state) =>
                          state.frontAiImage ??
                          state.leftAiImage ??
                          state.rightAiImage,
                    ),
                  );
                  if (afterImage == null) return const SizedBox.shrink();

                  return Expanded(
                    child: ScaleTransition(
                      scale: _pulseAnimation,
                      child: CustomButton(
                        onPressed: _onSaveOptionPressed,
                        isBorder: true,
                        text: "Save Option",
                        borderRadius: context.r(30),
                        textColor: CustomColors.blackColor,
                        height: context.h(58),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFacePreview() {
    const cardRadius = 20.0;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(10)),
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(cardRadius.r),
              child: Consumer(
                builder: (context, ref, _) {
                  final state = ref.watch(treatmentViewModel);

                  XFile? beforeImage;
                  XFile? afterImage;

                  if (_selectedPose == 'left') {
                    beforeImage = state.leftPoseImage;
                    afterImage = state.leftAiImage;
                  } else if (_selectedPose == 'right') {
                    beforeImage = state.rightPoseImage;
                    afterImage = state.rightAiImage;
                  } else {
                    beforeImage = state.frontPoseImage;
                    afterImage = state.frontAiImage;
                  }

                  debugPrint(
                    'PREVIEW: pose=$_selectedPose, before=${beforeImage?.path}, after=${afterImage?.path}',
                  );

                  final errorMessage = state.errorMessage;

                  if (errorMessage != null && beforeImage == null) {
                    return _buildErrorState(errorMessage, cardRadius);
                  }

                  if (beforeImage != null && afterImage != null) {
                    return BeforeAfter(
                      key: ValueKey(
                        'preview_${_selectedPose}_${beforeImage.path}_${afterImage.path}',
                      ),
                      value: _sliderValue,
                      onValueChanged: (value) =>
                          setState(() => _sliderValue = value),
                      before: _buildPreviewImage(afterImage.path),
                      after: _buildPreviewImage(beforeImage.path),
                      trackColor: Colors.white,
                      trackWidth: context.w(2),
                      thumbDecoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(PngAssets.customMarker),
                          fit: BoxFit.contain,
                        ),
                      ),
                      thumbWidth: context.w(32),
                      thumbHeight: context.w(32),
                    );
                  }

                  if (beforeImage != null) {
                    return _buildPreviewImage(beforeImage.path);
                  }

                  return _buildNoImageState();
                },
              ),
            ),

            _buildAfterLabel(),
            _buildBeforeLabel(),
            _buildEditButton(),
            //  _buildDownloadButton(),
          ],
        ),
      ),
    );
  }
Widget _buildEditButton() {
    return Positioned(
      bottom: context.h(12),
      right: context.w(12),
      child: Material(
        color: Colors.white.withValues(alpha: 0.9),
        shape: const CircleBorder(),
        child: IconButton(
          tooltip: 'Edit',
          icon: Icon(
            Icons.edit_outlined,
            color: Colors.black,
            size: context.sp(20),
          ),
          onPressed: () async {
            final stateBefore = ref.read(treatmentViewModel);

            final oldImagePath = switch (_selectedPose) {
              'left' => stateBefore.leftPoseImage?.path,
              'right' => stateBefore.rightPoseImage?.path,
              _ => stateBefore.frontPoseImage?.path,
            };

            await Navigator.pushNamed(
              context,
              FaceDetectionScreen.routeName,
              arguments: _selectedPose,
            );

            if (!mounted) return;

            final stateAfter = ref.read(treatmentViewModel);

            final newImagePath = switch (_selectedPose) {
              'left' => stateAfter.leftPoseImage?.path,
              'right' => stateAfter.rightPoseImage?.path,
              _ => stateAfter.frontPoseImage?.path,
            };

            if (newImagePath != null && newImagePath != oldImagePath) {
              ref.read(treatmentViewModel.notifier).clearAiImage();
            }
          },
        ),
      ),
    );
  }
 
  Widget _buildPoseSelector() {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(treatmentViewModel);

        return Container(
          margin: EdgeInsets.symmetric(horizontal: context.w(15)),
          padding: EdgeInsets.all(context.w(12)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.r(24)),
            border: Border.all(
              color: CustomColors.lightBlueColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: context.w(4),
                  bottom: context.h(12),
                ),
                child: Text(
                  "Choose a face view below to compare your before and after results",
                  style: CustomFonts.black14w600.copyWith(
                    color: Colors.black,
                    letterSpacing: 0.2,
                    height: 1.2,
                  ),
                ),
              ),
              Row(
                children: [
                  _poseChip(
                    "Front View",
                    'front',
                    state.frontPoseImage != null,
                  ),
                  SizedBox(width: context.w(10)),
                  _poseChip("Left View", 'left', state.leftPoseImage != null),
                  SizedBox(width: context.w(10)),
                  _poseChip(
                    "Right View",
                    'right',
                    state.rightPoseImage != null,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _poseChip(String label, String value, bool hasImage) {
    final isSelected = _selectedPose == value;
    final bool canTap = hasImage;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            text: label,
            onPressed: canTap
                ? () => setState(() => _selectedPose = value)
                : null,
            height: context.h(42),
            borderRadius: context.r(100),
            isBorder: !isSelected,
            textColor: Colors.black,
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.only(top: context.h(8)),
            height: context.h(3),
            width: isSelected ? context.w(30) : 0,
            decoration: BoxDecoration(
              color: CustomColors.lightBlueColor,
              borderRadius: BorderRadius.circular(context.r(2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewImage(String path) {
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      width: double.infinity,
      height: context.h(326),
    );
  }

  Widget _buildErrorState(String message, double radius) {
    return Container(
      width: double.infinity,
      height: context.h(326),
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(radius.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: context.sp(48)),
            SizedBox(height: context.h(16)),
            Text('Error', style: CustomFonts.red20w600),
            SizedBox(height: context.h(8)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(16)),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: CustomFonts.red16w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoImageState() {
    return Container(
      width: double.infinity,
      height: context.h(326),
      color: CustomColors.greyColor.withValues(alpha: 0.3),
      child: Center(
        child: Text('No image available', style: CustomFonts.black16w400),
      ),
    );
  }

  Widget _buildAfterLabel() {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(treatmentViewModel);
        XFile? afterImage;
        if (_selectedPose == 'left') {
          afterImage = state.leftAiImage;
        } else if (_selectedPose == 'right') {
          afterImage = state.rightAiImage;
        } else {
          afterImage = state.frontAiImage;
        }

        if (afterImage == null) return const SizedBox.shrink();

        return Positioned(
          top: context.h(12),
          right: context.w(12),
          child: _buildBadge("AFTER", Colors.black.withValues(alpha: 0.6)),
        );
      },
    );
  }

  Widget _buildBeforeLabel() {
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(treatmentViewModel);
        XFile? beforeImage;
        if (_selectedPose == 'left') {
          beforeImage = state.leftPoseImage;
        } else if (_selectedPose == 'right') {
          beforeImage = state.rightPoseImage;
        } else {
          beforeImage = state.frontPoseImage;
        }

        if (beforeImage == null) return const SizedBox.shrink();

        return Positioned(
          top: context.h(12),
          left: context.w(12),
          child: _buildBadge("BEFORE", Colors.black.withValues(alpha: 0.6)),
        );
      },
    );
  }

  Widget _buildBadge(String text, Color bgColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(10),
        vertical: context.h(4),
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(context.r(4)),
      ),
      child: Text(
        text,
        style: CustomFonts.white12w600.copyWith(
          letterSpacing: 0.8,
          fontSize: context.sp(10),
        ),
      ),
    );
  }

  // Widget _buildDownloadButton() {
  //   return Positioned(
  //     bottom: context.h(12),
  //     right: context.w(12),
  //     child: Consumer(
  //       builder: (context, ref, _) {
  //         final afterImage = ref.watch(
  //           treatmentViewModel.select(
  //             (state) =>
  //                 state.frontAiImage ?? state.leftAiImage ?? state.rightAiImage,
  //           ),
  //         );
  //         if (afterImage == null) return const SizedBox.shrink();

  //         return GestureDetector(
  //           onTap: () => ref.read(treatmentViewModel.notifier).saveAiImage(),
  //           child: Container(
  //             padding: EdgeInsets.all(context.w(8)),
  //             decoration: BoxDecoration(
  //               color: Colors.white.withValues(alpha: 0.9),
  //               shape: BoxShape.circle,
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withValues(alpha: 0.1),
  //                   blurRadius: 8,
  //                   offset: const Offset(0, 2),
  //                 ),
  //               ],
  //             ),
  //             child: Icon(
  //               Icons.file_download_outlined,
  //               color: Colors.black,
  //               size: context.sp(20),
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // ---------------------------------------------------------------------------
  // Helper Methods
  // ---------------------------------------------------------------------------

  SelectedTreatmentAndAreasModel? _entryForTreatment(
    List<SelectedTreatmentAndAreasModel> list,
    int? treatmentId,
  ) {
    if (treatmentId == null) return null;
    return list.cast<SelectedTreatmentAndAreasModel?>().firstWhere(
      (e) => e?.treatment.id == treatmentId,
      orElse: () => null,
    );
  }

  Map<String, List<AreaData>> _getGroupedLeafAreas(List<AreaData> rootAreas) {
    final Map<String, List<AreaData>> groups = {};

    void traverse(AreaData area, String parentPath) {
      if (area.subAreas == null || area.subAreas!.isEmpty) {
        final groupName = parentPath.isEmpty ? "General Selection" : parentPath;
        groups.putIfAbsent(groupName, () => []).add(area);
      } else {
        String newPath = parentPath.isEmpty
            ? (area.name ?? '')
            : "$parentPath > ${area.name}";
        for (final sub in area.subAreas!) {
          traverse(sub, newPath);
        }
      }
    }

    for (final area in rootAreas) {
      traverse(area, "");
    }
    return groups;
  }

  Widget _buildFlatAreas({
    required List<AreaData> rootAreas,
    required Set<int> selectedAreaIds,
    required TreatmentData treatment,
  }) {
    final groupedLeafs = _getGroupedLeafAreas(rootAreas);
    if (groupedLeafs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Treatment Area", style: CustomFonts.black16w600),
        SizedBox(height: context.h(4)),
        Text(
          "Long press on treatment or areas to view details",
          style: CustomFonts.grey12w400.copyWith(
            color: CustomColors.textGreyColor,
            fontSize: context.sp(11),
          ),
        ),
        ...groupedLeafs.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: context.h(24)),
              Text(
                entry.key.toUpperCase(),
                style: TextStyle(
                  fontSize: context.sp(12),
                  fontWeight: FontWeight.w600,
                  color: CustomColors.textGreyColor,
                  letterSpacing: 1.2,
                  fontFamily: 'Degular',
                ),
              ),
              SizedBox(height: context.h(12)),
              AnimationLimiter(
                child: Wrap(
                  direction: Axis.horizontal,
                  spacing: context.w(12),
                  runSpacing: context.h(12),
                  children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 600),
                    childAnimationBuilder: (widget) =>
                        FlipAnimation(child: FadeInAnimation(child: widget)),
                    children: entry.value.map((area) {
                      final isSelected = selectedAreaIds.contains(area.id);
                      return ServiceTypeButton(
                        imageUrl: area.image,
                        icon: area.icon,
                        text: area.name ?? '-',
                        selected: isSelected,
                        description: area.description,
                        infoImageUrl: area.infoImageUrl,
                        onPressed: () =>
                            _onAreaPressed(area, isSelected, treatment),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  void _onAreaPressed(AreaData area, bool isSelected, TreatmentData treatment) {
    if (isSelected) {
      ref.read(checkoutViewModel.notifier).removeArea(area.id ?? 0);
    } else {
      final treatmentSku = treatment.globalSku ?? '';
      final areaSku = area.globalSku ?? '';

      EasyLoading.show(status: 'Fetching materials...');
      ref
          .read(treatmentViewModel.notifier)
          .getMaterials(treatmentSku: treatmentSku, areaSku: areaSku)
          .then((res) {
            EasyLoading.dismiss();
            if (res != null && res.isSuccess == true) {
              bool canAutoSelectAll = true;
              if (res.data != null) {
                final m = res.data!;
                final min = m.minQty ?? 0;
                final max = m.maxQty ?? 0;
                canAutoSelectAll = (min == max) || (max == 0);
              }

              if (canAutoSelectAll || res.data == null) {
                SelectedMaterialModel? selectedMaterial;
                if (res.data != null) {
                  final m = res.data!;
                  final max = m.maxQty ?? 0;
                  selectedMaterial = SelectedMaterialModel(
                    id: m.id ?? 0,
                    name: m.unitType ?? '',
                    selectedQuantity: max,
                    minQty: m.minQty ?? 0,
                    maxQty: max,
                  );
                }
                ref
                    .read(checkoutViewModel.notifier)
                    .saveMaterialForArea(
                      treatment: treatment,
                      area: area,
                      material: selectedMaterial,
                    );
              } else {
                if (!context.mounted) return;
                _showMaterialBottomSheet(context, area, res.data!);
              }
            } else {
              ref.read(checkoutViewModel.notifier).addSelectedArea(area);
            }
          })
          .catchError((e) {
            EasyLoading.dismiss();
            ref.read(checkoutViewModel.notifier).addSelectedArea(area);
          });
    }
  }

  void _showMaterialBottomSheet(
    BuildContext context,
    TreatmentAreaModel area,
    MaterialData material,
  ) {
    final treatment = ref.read(checkoutViewModel).selectedTreatments;
    if (treatment == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      constraints: .new(minWidth: 1.sw),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.r(24)),
        ),
      ),
      builder: (context) {
        return MaterialLevelSheet(
          area: area,
          material: material,
          treatment: treatment,
        );
      },
    );
  }
}
