import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

import '../models/responses/materials_response.dart';
import '../models/responses/treatment_area_list_response.dart';
import '../models/responses/treatment_list_response.dart';
import 'bottom_sheets/material_level_sheet.dart';

class MaterialBottomSheet extends StatelessWidget {
  final TreatmentAreaModel area;
  final MaterialData material;
  final TreatmentData treatment;

  const MaterialBottomSheet({
    super.key,
    required this.area,
    required this.material,
    required this.treatment,
  });

  static Future<void> show({
    required BuildContext context,
    required TreatmentAreaModel area,
    required MaterialData material,
    required TreatmentData treatment,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      constraints: BoxConstraints(
        minWidth: 1.sw,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(context.r(24)),
        ),
      ),
      builder: (_) {
        return MaterialBottomSheet(
          area: area,
          material: material,
          treatment: treatment,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialLevelSheet(
      area: area,
      material: material,
      treatment: treatment,
    );
  }
}