import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/responses/treatment_area_list_response.dart';
import '../view_models/treatment_view_model.dart';
import '../widgets/material_bottom_sheet.dart';
import '../widgets/scan_face_dialog.dart';
import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../view_models/checkout_view_model.dart';
import '../view_models/treatment_area_view_model.dart';
import '../widgets/app_loader.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/treatment_container.dart';

class TreatmentAreaScreen extends ConsumerStatefulWidget {
  final List<TreatmentAreaModel>? areas;
  final String title;
  final String selectionPath; // Path of selected focus areas
  final int? treatmentId;

  const TreatmentAreaScreen({
    super.key,
    this.areas,
    required this.title,
    this.selectionPath = "Focus Areas", // Defaults to root path
    this.treatmentId,
  });

  static const String routeName = '/TreatmentAreaScreen';

  @override
  ConsumerState<TreatmentAreaScreen> createState() =>
      _TreatmentAreaScreenState();
}

class _TreatmentAreaScreenState extends ConsumerState<TreatmentAreaScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.areas == null || widget.areas!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.treatmentId != null) {
          ref
              .read(treatmentAreaProvider.notifier)
              .fetchAreasByTreatment(widget.treatmentId);
        } else {
          final selectedTreatment = ref
              .read(checkoutViewModel)
              .selectedTreatments;
          if (selectedTreatment != null) {
            ref
                .read(treatmentAreaProvider.notifier)
                .fetchAreasByTreatment(selectedTreatment.id);
          } else {
            ref
                .read(treatmentAreaProvider.notifier)
                .fetchAreasByTreatment(null);
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(treatmentAreaProvider);
    final displayedAreas = (widget.areas != null && widget.areas!.isNotEmpty)
        ? widget.areas!
        : viewModel.areas;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional MedSpa Header
            CustomAppBar(title: widget.title),
            // Premium Breadcrumb Selection Path Container
            Padding(
              padding: EdgeInsets.symmetric(horizontal: context.w(30)),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: context.w(16),
                  vertical: context.h(12),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.r(15)),
                  border: Border.all(
                    color: CustomColors.lightPurpleColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.radar_rounded,
                      size: context.sp(14),
                      color: CustomColors.purpleColor,
                    ),
                    SizedBox(width: context.w(8)),
                    Expanded(
                      child: Text(
                        widget.selectionPath,
                        style: TextStyle(
                          fontSize: context.sp(12),
                          fontWeight: FontWeight.w500,
                          color: CustomColors.textGreyColor,
                          fontFamily: 'Degular',
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Focus Area Listing using Reusable Adaptive TreatmentContainer
            Expanded(
              child: viewModel.loading /*&& displayedAreas.isEmpty*/
                  ? const AppLoader()
                  : displayedAreas.isEmpty
                  ? _buildEmptyResultsPlaceholder()
                  : AnimationLimiter(
                      key: ValueKey('area_list_${widget.title}'),
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.w(30),
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: displayedAreas.length + 1,
                        itemBuilder: (context, index) {
                          if (index == displayedAreas.length) {
                            return SizedBox(
                              height: context.h(110),
                            ); // Provide padding for floating items
                          }

                          final area = displayedAreas[index];

                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 600),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: context.h(16),
                                  ),
                                  child: TreatmentContainer(
                                    customTitle: area.name,
                                    customSubtitle: area.globalSku ?? "",
                                    customImageUrl: area.image ?? "",
                                    customIcon: area.icon ?? "",
                                    customOnTap: () {
                                      if (area.subAreas != null &&
                                          area.subAreas!.isNotEmpty) {
                                        // Recursively open another area screen with appended path
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TreatmentAreaScreen(
                                                  areas: area.subAreas,
                                                  title: area.name ?? "",
                                                  selectionPath:
                                                      "${widget.selectionPath}  ▸  ${area.name}",
                                                ),
                                          ),
                                        );
                                      } else {
                                        final treatment = ref
                                            .read(checkoutViewModel)
                                            .selectedTreatments;

                                        if (treatment == null) {
                                          // No treatment context available — fall back straight to the dialog
                                          ref
                                              .read(checkoutViewModel.notifier)
                                              .addSelectedArea(area);
                                          if (context.mounted)
                                            showMScanFaceDialog(context);
                                          return;
                                        }

                                        final treatmentSku =
                                            treatment.globalSku ?? '';
                                        final areaSku = area.globalSku ?? '';

                                        EasyLoading.show(
                                          status: 'Fetching materials...',
                                        );
                                        ref
                                            .read(treatmentViewModel.notifier)
                                            .getMaterials(
                                              treatmentSku: treatmentSku,
                                              areaSku: areaSku,
                                            )
                                            .then((res) async {
                                              EasyLoading.dismiss();
                                              ref
                                                  .read(
                                                    checkoutViewModel.notifier,
                                                  )
                                                  .addSelectedArea(area);

                                             

                                              if (res != null &&
                                                  res.isSuccess == true &&
                                                  res.data != null) {
                                                if (!context.mounted) return;
                                                await MaterialBottomSheet.show(
                                                  context: context,
                                                  area: area,
                                                  material: res.data!,
                                                  treatment: treatment,
                                                );
                                                if (context.mounted) {
                                                  showMScanFaceDialog(context);
                                                }
                                              } else {
                                                if (context.mounted) {
                                                  showMScanFaceDialog(context);
                                                }
                                              }
                                              
                                            })
                                            .catchError((e) {
                                              EasyLoading.dismiss();
                                              ref
                                                  .read(
                                                    checkoutViewModel.notifier,
                                                  )
                                                  .addSelectedArea(area);
                                              if (context.mounted) {
                                                showMScanFaceDialog(context);
                                              }
                                            });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResultsPlaceholder() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.w(40)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.crop_free_rounded,
              size: context.sp(70),
              color: Colors.grey.shade400,
            ),
            SizedBox(height: context.h(15)),
            Text(
              "No Areas Found",
              style: CustomFonts.black20w600.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: context.h(5)),
            Text(
              "We couldn't find any target areas under this section.",
              textAlign: TextAlign.center,
              style: CustomFonts.grey14w400,
            ),
          ],
        ),
      ),
    );
  }
}
