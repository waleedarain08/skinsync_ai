import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../utils/color_constant.dart';
import '../utils/custom_fonts.dart';
import '../view_models/checkout_view_model.dart';

class SelectedTreatmentAndAreasWidget extends ConsumerWidget {
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onRemove;

  const SelectedTreatmentAndAreasWidget({
    super.key,
    this.padding,
    this.margin,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(checkoutViewModel);
    final checkoutTreatmentsList = checkoutState.checkoutTreatmentsList;

    if (checkoutTreatmentsList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: context.h(38),
      margin: margin ?? EdgeInsets.only(top: context.h(12)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: padding ?? EdgeInsets.symmetric(horizontal: context.w(24)),
        itemCount: checkoutTreatmentsList.length,
        itemBuilder: (context, index) {
          final selection = checkoutTreatmentsList[index];
          final materialInfo =
              (selection.material != null &&
                      selection.material!.selectedQuantity > 0)
                  ? " (${selection.material!.selectedQuantity} ${selection.material!.name})"
                  : "";
          final chipText =
              "${selection.treatmentName} - ${selection.areaName}$materialInfo";

          return Container(
            margin: EdgeInsets.only(right: context.w(8)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(context.r(16)),
              gradient: CustomColors.purpleBlueGradient,
              boxShadow: [
                BoxShadow(
                  color: CustomColors.purpleColor.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.r(16)),
              child: Stack(
                children: [
                  // 1. White Tint Mask Overlay
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),

                  // 2. High-Contrast Content
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(14),
                      vertical: context.h(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.insights_rounded,
                          color: CustomColors.purpleColor,
                          size: context.sp(13),
                        ),
                        SizedBox(width: context.w(8)),
                        Text(
                          chipText,
                          style: CustomFonts.black10w600.copyWith(
                            fontSize: context.sp(11),
                          ),
                        ),
                        SizedBox(width: context.w(8)),
                        // Visual thin line divider
                        Container(
                          width: context.w(1),
                          height: context.h(14),
                          color: Colors.black12,
                        ),
                        SizedBox(width: context.w(8)),
                        // Clickable Cancel Cross Button
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(checkoutViewModel.notifier)
                                .removeFlatSelection(
                                  treatmentId: selection.treatmentId,
                                  areaId: selection.areaId,
                                );
                            onRemove?.call();
                          },
                          child: Icon(
                            Icons.cancel_rounded,
                            size: context.sp(14),
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
