import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:iconsax/iconsax.dart';

import '../models/requests/preferred_slot.dart';
import '../utils/assets.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../utils/string_utils.dart';
import '../view_models/checkout_view_model.dart';
import '../view_models/clinic_view_model.dart';
import '../view_models/treatment_requests_view_model.dart';
import '../view_models/treatment_view_model.dart';
import '../widgets/app_loader.dart';
import '../widgets/bottom_sheets/preferred_slots_bottom_sheet.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/dialogs/delete_confirmation_dialog.dart';
import '../widgets/medical_disclaimer_banner.dart';
import '../widgets/simulation_card.dart';
import 'ar_face_model_preview_screen.dart';
import 'bottom_nav_page.dart';
import 'consent_forms/face_consent_screen.dart';
import 'face_pose_capture_screen.dart';
import 'journey_clinics_screen.dart';
import 'treatment_review_screen.dart';

class TreatmentRequestDetailScreen extends ConsumerStatefulWidget {
  final int groupId;
  final String groupName;

  const TreatmentRequestDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  static const String routeName = '/TreatmentRequestDetailScreen';

  @override
  ConsumerState<TreatmentRequestDetailScreen> createState() =>
      _TreatmentRequestDetailScreenState();
}

enum _JourneyFilter { all, shared, unshared }

class _TreatmentRequestDetailScreenState
    extends ConsumerState<TreatmentRequestDetailScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  _JourneyFilter _currentFilter = _JourneyFilter.all;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _setupTabController(List<dynamic> filteredOptions) {
    final length = filteredOptions.length;
    if (_tabController == null || _tabController!.length != length) {
      _tabController?.dispose();
      _tabController = TabController(length: length, vsync: this);
      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging &&
            _tabController!.index < filteredOptions.length) {
          ref
              .read(treatmentRequestsProvider.notifier)
              .fetchOptionsDetail(filteredOptions[_tabController!.index].id!);
        }
      });

      if (length > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _tabController!.index < filteredOptions.length) {
            ref
                .read(treatmentRequestsProvider.notifier)
                .fetchOptionsDetail(filteredOptions[_tabController!.index].id!);
          }
        });
      }
    }
  }

  void _showEditGroupDialog() {
    final TextEditingController nameController = TextEditingController(
      text: ref.read(treatmentRequestsProvider).selectedGroup?.name ?? '',
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.r(16)),
          ),
          title: Text("Edit Group Name", style: CustomFonts.black18w600),
          content: TextField(
            controller: nameController,
            autofocus: true,
            style: const TextStyle(color: Colors.black),
            decoration: InputDecoration(
              labelText: "Group Name",
              labelStyle: CustomFonts.grey14w400,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.r(10)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(context.r(10)),
                borderSide: const BorderSide(color: CustomColors.purpleColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Cancel", style: CustomFonts.textGrey15w400),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColors.purpleColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(context.r(8)),
                ),
              ),
              onPressed: () {
                final updatedName = nameController.text.trim();
                if (updatedName.isNotEmpty) {
                  ref
                      .read(treatmentRequestsProvider.notifier)
                      .callUpdateGroupName(widget.groupId, updatedName);
                }
                Navigator.pop(dialogContext);
              },
              child: Text(
                "Update",
                style: CustomFonts.black14w600.copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(treatmentRequestsProvider);

    final filteredOptions = state.options.where((opt) {
      switch (_currentFilter) {
        case _JourneyFilter.shared:
          return opt.isShared == true;
        case _JourneyFilter.unshared:
          return opt.isShared != true;
        case _JourneyFilter.all:
          return true;
      }
    }).toList();

    if (filteredOptions.isNotEmpty) {
      _setupTabController(filteredOptions);
    }

    return PopScope(
      onPopInvokedWithResult: (_, _) {
        ref.read(treatmentRequestsProvider.notifier).clearSelectedGroup();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          showTitle: true,
          title: state.selectedGroup?.name?.capitalize ?? '',
          actions: [
            IconButton(
              padding: .zero,
              icon: const Icon(
                Icons.edit_outlined,
                color: Colors.black,
                size: 20,
              ),
              tooltip: "Edit Group Name",
              onPressed: _showEditGroupDialog,
            ),
            PopupMenuButton<_JourneyFilter>(
              padding: EdgeInsets.zero,
              onSelected: (filter) {
                setState(() {
                  _currentFilter = filter;
                  _tabController = null; // Reset controller to re-init
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.r(16)),
              ),
              color: Colors.white,
              elevation: 3,
              itemBuilder: (context) => [
                _buildFilterItem(_JourneyFilter.all, "All"),
                _buildFilterItem(_JourneyFilter.shared, "Shared"),
                _buildFilterItem(_JourneyFilter.unshared, "Unshared"),
              ],
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.w(12)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.filter, color: Colors.black, size: 18),
                    SizedBox(width: context.w(6)),
                    Text(
                      _currentFilter == _JourneyFilter.all
                          ? "All"
                          : (_currentFilter == _JourneyFilter.shared
                                ? "Shared"
                                : "Unshared"),
                      style: CustomFonts.black14w600,
                    ),
                  ],
                ),
              ),
            ),
            Consumer(
              builder: (_, ref, _) {
                final state = ref.watch(treatmentViewModel);
                if (!state.capturedImagesNull) {
                  return const SizedBox.shrink();
                }
                return IconButton(
                  onPressed: () {
                    FaceConsentScreen.checkAndProceed(
                      context: context,
                      ref: ref,
                      onProceed: () {
                        ref.read(checkoutViewModel.notifier).clearState();
                        ref
                            .read(treatmentViewModel.notifier)
                            .clearAllSelectedTreatments(capturedImage: true);
                        ref.read(treatmentViewModel.notifier).clearAiImage();
                        Navigator.of(
                          context,
                        ).pushNamed(FacePoseCaptureScreen.routeName);
                      },
                    );
                  },
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.black,
                  ),
                  tooltip: "Add More Options",
                );
              },
            ),
          ],
        ),
        body: state.loading
            ? const Center(child: AppLoader())
            : filteredOptions.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.document_filter,
                      size: context.w(48),
                      color: Colors.grey,
                    ),
                    SizedBox(height: context.h(16)),
                    Text(
                      _currentFilter == _JourneyFilter.all
                          ? (state.errorMessage ?? "No options available")
                          : "No ${_currentFilter.name} options found",
                      style: CustomFonts.grey16w400,
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    isScrollable: filteredOptions.length > 3,
                    indicatorColor: CustomColors.lightBlueColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey.shade500,
                    labelStyle: CustomFonts.black16w600,
                    unselectedLabelStyle: CustomFonts.grey16w500,
                    dividerColor: Colors.transparent,
                    tabs: filteredOptions.map((opt) {
                      final bool isShared = opt.isShared == true;
                      return Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(opt.name?.capitalize ?? ''),
                            if (isShared) ...[
                              SizedBox(width: context.w(6)),
                              Image.asset(
                                PngAssets.splashLogo,
                                height: context.h(16),
                                width: context.w(16),
                                fit: BoxFit.contain,
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  Expanded(
                    child: state.isSimulationsLoading
                        ? const Center(child: AppLoader())
                        : TabBarView(
                            controller: _tabController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: filteredOptions.map((opt) {
                              return _buildSimulationsList(context, state);
                            }).toList(),
                          ),
                  ),
                ],
              ),
        bottomNavigationBar: _buildBottomBar(context, state, filteredOptions),
      ),
    );
  }

  PopupMenuItem<_JourneyFilter> _buildFilterItem(
    _JourneyFilter value,
    String label,
  ) {
    final isSelected = _currentFilter == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Text(
            label,
            style: CustomFonts.black14w500.copyWith(
              color: isSelected ? CustomColors.purpleColor : Colors.black,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check, color: CustomColors.purpleColor, size: 18),
          ],
        ],
      ),
    );
  }

  Widget? _buildBottomBar(
    BuildContext context,
    TreatmentRequestsState state,
    List<dynamic> filteredOptions,
  ) {
    if (state.loading || filteredOptions.isEmpty || state.simulations == null) {
      return null;
    }

    return Padding(
      padding: EdgeInsets.only(
        top: context.h(10),
        bottom: MediaQuery.paddingOf(context).bottom + context.h(20),
        left: context.w(24),
        right: context.w(24),
      ),
      child: Row(
        spacing: context.w(10),
        children: [
          Expanded(
            child: Consumer(
              builder: (context, ref, _) {
                final capturedImagesNull = ref.watch(
                  treatmentViewModel.select((s) => s.capturedImagesNull),
                );

                return CustomButton(
                  isBorder: true,
                  text: !capturedImagesNull ? 'Back To Home' : 'Modify',
                  onPressed: () async {
                    final sim = state.simulations;
                    if (!capturedImagesNull) {
                      Navigator.popUntil(
                        context,
                        (route) =>
                            route.settings.name == BottomNavPage.routeName,
                      );
                    } else if (sim != null) {
                      await ref
                          .read(treatmentViewModel.notifier)
                          .initializeSimulation(sim);
                      if (context.mounted) {
                        Navigator.pushNamed(
                          context,
                          ArFaceModelPreviewScreen.routeName,
                        );
                      }
                    }
                  },
                );
              },
            ),
          ),
          Expanded(
            child:
                (filteredOptions[_tabController?.index ?? 0].isShared == true)
                ? Container(
                    height: context.h(52),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(context.r(12)),
                    ),
                    child: Center(
                      child: Text(
                        "Already Shared",
                        style: CustomFonts.black16w600.copyWith(
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  )
                : CustomButton(
                    text: "Share",
                    onPressed: () async {
                      final currentOptionId =
                          filteredOptions[_tabController?.index ?? 0].id;
                      if (currentOptionId != null) {
                        ref
                            .read(treatmentRequestsProvider.notifier)
                            .setOptionId(currentOptionId);
                      }
                      final clinic = ref.read(clinicProvider).clinic;

                      void processShare(List<PreferredSlot> slots) {
                        if (clinic != null) {
                          Navigator.pushNamed(
                            context,
                            TreatmentReviewScreen.routeName,
                            arguments: {
                              'simulationData': state.simulations,
                              'preferredSlots': slots,
                              'clinic': clinic,
                            },
                          );
                        } else {
                          Navigator.pushNamed(
                            context,
                            JourneyClinicsScreen.routeName,
                          );
                        }
                      }

                      if (clinic != null) {
                        PreferredSlotsBottomSheet.show(
                          context: context,
                          onConfirm: (slots) => processShare(slots),
                        );
                      } else {
                        Navigator.pushNamed(
                          context,
                          JourneyClinicsScreen.routeName,
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _selectedSubTab = "Simulation";

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

  Widget _buildSimulationsList(
    BuildContext context,
    TreatmentRequestsState state,
  ) {
    final sim = state.simulations;
    if (sim == null) {
      return Center(
        child: Text(
          "No simulation for this option",
          style: CustomFonts.grey16w400,
        ),
      );
    }

    final filteredOptions = state.options.where((opt) {
      switch (_currentFilter) {
        case _JourneyFilter.shared:
          return opt.isShared == true;
        case _JourneyFilter.unshared:
          return opt.isShared != true;
        case _JourneyFilter.all:
          return true;
      }
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(24),
        vertical: context.h(20),
      ),
      child: Column(
        children: [
          const MedicalDisclaimerBanner(),
          Padding(
            padding: EdgeInsets.only(top: context.h(10), bottom: context.h(20)),
            child: Row(
              children: [
                _buildSubTabButton("Simulation"),
                SizedBox(width: context.w(12)),
                _buildSubTabButton("Treatments"),
              ],
            ),
          ),
          SimulationCard(
            sim: sim,
            price: state.price,
            showActionButton: false,
            showImages: _selectedSubTab == "Simulation",
            showTreatments: _selectedSubTab == "Treatments",
            onDelete: () {
              final currentOption = filteredOptions[_tabController?.index ?? 0];
              if (currentOption.id != null) {
                showDeleteConfirmationDialog(
                  context: context,
                  title: "Delete Option?",
                  description:
                      "Are you sure you want to delete '${currentOption.name?.capitalize}'? This action cannot be undone.",
                  onDelete: () {
                    ref
                        .read(treatmentRequestsProvider.notifier)
                        .callDeleteOption(currentOption.id!);
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  
}
