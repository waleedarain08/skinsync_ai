import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../models/selected_treatment_and_areas_model.dart';
import '../utils/custom_fonts.dart';
import 'sticky_tooltip.dart';

class SelectedTreatmentsSummaryCard extends StatelessWidget {
  final List<SelectedTreatmentAndAreasModel> selectedTreatmentsAndAreas;
  final void Function(SelectedTreatmentAndAreasModel item)? onRemoveTreatment;
  final void Function(
    SelectedTreatmentAndAreasModel item,
    SelectedAreaModel areaItem,
  )?
  onRemoveArea;

  const SelectedTreatmentsSummaryCard({
    super.key,
    required this.selectedTreatmentsAndAreas,
    this.onRemoveTreatment,
    this.onRemoveArea,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedTreatmentsAndAreas.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: context.h(230),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: selectedTreatmentsAndAreas.length,
        itemBuilder: (context, index) {
          final item = selectedTreatmentsAndAreas[index];
          final treatment = item.treatment;
          final areas = item.selectedAreas;

          // Group and sum materials by ID/name for aggregate view under this treatment
          final Map<int, SelectedMaterialModel> groupedMaterials = {};
          for (final areaItem in areas) {
            final m = areaItem.material;
            if (m != null && m.selectedQuantity > 0) {
              if (groupedMaterials.containsKey(m.id)) {
                groupedMaterials[m.id] = groupedMaterials[m.id]!.copyWith(
                  selectedQuantity:
                      groupedMaterials[m.id]!.selectedQuantity +
                      m.selectedQuantity,
                );
              } else {
                groupedMaterials[m.id] = m;
              }
            }
          }

          return Container(
            width: context.w(260),
            margin: EdgeInsets.only(right: context.w(16), bottom: context.h(16)),
            padding: EdgeInsets.all(context.w(16)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(context.r(24)),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.12),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.015),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Treatment',
                            style: CustomFonts.black10w600.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          SizedBox(height: context.h(2)),
                          Text(
                            treatment.name ?? '-',
                            style: CustomFonts.black16w600,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (onRemoveTreatment != null)
                      GestureDetector(
                        onTap: () => onRemoveTreatment!(item),
                        child: Icon(
                          Icons.cancel_rounded,
                          size: 20,
                          color: Colors.red.shade400,
                        ),
                      ),
                  ],
                ),
                const Divider(height: 16, color: Colors.black12),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Areas',
                          style: CustomFonts.black10w600.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                        SizedBox(height: context.h(6)),
                        areas.isEmpty
                            ? Center(
                                child: Text(
                                  "No areas selected",
                                  style: CustomFonts.grey12w400,
                                ),
                              )
                            : Wrap(
                                spacing: context.w(6),
                                runSpacing: context.h(6),
                                children: areas.map((areaItem) {
                                  final areaTarget = areaItem.target;
                                  final materialInfo =
                                      (areaItem.material != null &&
                                              areaItem.material!.selectedQuantity > 0)
                                          ? " (${areaItem.material!.selectedQuantity} ${areaItem.material!.name})"
                                          : "";

                                  final String? areaDesc =
                                      (areaTarget.description != null &&
                                              areaTarget.description!
                                                  .trim()
                                                  .isNotEmpty)
                                          ? areaTarget.description!.trim()
                                          : null;
                                  final String? areaImg =
                                      (areaTarget.infoImageUrl != null &&
                                              areaTarget.infoImageUrl!
                                                  .trim()
                                                  .isNotEmpty)
                                          ? areaTarget.infoImageUrl!.trim()
                                          : null;

                                  final bool hasTooltip =
                                      areaDesc != null || areaImg != null;

                                  final chipWidget = Chip(
                                    visualDensity: VisualDensity.compact,
                                    label: Text(
                                      "${areaTarget.name ?? '-'}$materialInfo",
                                      style: CustomFonts.black10w600,
                                    ),
                                    onDeleted: onRemoveArea != null
                                        ? () => onRemoveArea!(item, areaItem)
                                        : null,
                                    deleteIconColor: Colors.red.shade300,
                                  );

                                  if (!hasTooltip) {
                                    return chipWidget;
                                  }

                                  return GestureDetector(
                                    onLongPress: () {
                                      showStickyTooltip(
                                        context: context,
                                        title: areaTarget.name ?? '',
                                        description: areaDesc,
                                        imageUrl: areaImg,
                                      );
                                    },
                                    child: chipWidget,
                                  );
                                }).toList(),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
