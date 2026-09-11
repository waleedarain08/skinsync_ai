import '../models/responses/treatment_area_list_response.dart';
import 'face_area_detector_util.dart';

/// Smart SKU & Area binder mapping face tap regions to fetched Treatment Areas
class FaceAreaSkuMapper {
  /// Global SKU binding table for TRT-0001-BOTX (Botox / Neuromodulator)
  static final Map<String, String> _botoxSkuByRegion = {
    'forehead': 'BTX-0001-UPRF',
    'glabella': 'BTX-0002-UPRF',
    'frown': 'BTX-0002-UPRF',
    'eyebrow': 'BTX-0003-UPRF',
    'brow': 'BTX-0003-UPRF',
    'crows feet': 'BTX-0004-UPRF',
    'crow': 'BTX-0004-UPRF',
    'bunny': 'BTX-0001-MDLF',
    'jelly': 'BTX-0002-MDLF',
    'under eye': 'BTX-0002-MDLF',
    'nasal tip': 'BTX-0003-MDLF',
    'nose flare': 'BTX-0004-MDLF',
    'gummy': 'BTX-0001-LWRF',
    'lip flip': 'BTX-0002-LWRF',
    'perioral': 'BTX-0003-LWRF',
    'smoker': 'BTX-0003-LWRF',
    'downturned': 'BTX-0004-LWRF',
    'chin dimpling': 'BTX-0005-LWRF',
    'chin': 'BTX-0005-LWRF',
    'masseter': 'BTX-0001-JWLN',
    'jawline': 'BTX-0002-JWLN',
    'platysmal': 'BTX-0003-JWLN',
    'neck': 'BTX-0003-JWLN',
  };

  /// Global SKU binding table for TRT-0002-DRMA (Dermal Fillers)
  static final Map<String, String> _dermalSkuByRegion = {
    'temple': 'DRM-0001-UPRF',
    'preauricular': 'DRM-0004-MDLF',
    'nasolabial': 'DRM-0003-MDLF',
    'fold': 'DRM-0003-MDLF',
    'cheek': 'DRM-0002-MDLF',
    'middle face': 'DRM-0002-MDLF',
    'tear trough': 'DRM-0001-MDLF',
    'under eye': 'DRM-0001-MDLF',
    'chin shadow': 'DRM-0004-LWRF',
    'chin': 'DRM-0003-LWRF',
    'marionette': 'DRM-0002-LWRF',
    'lip': 'DRM-0001-LWRF',
    'mouth': 'DRM-0001-LWRF',
    'pre-jowl': 'DRM-0002-JWLN',
    'jowl': 'DRM-0002-JWLN',
    'jawline': 'DRM-0001-JWLN',
    'jaw': 'DRM-0001-JWLN',
  };

  /// Smartly finds the matching fetched AreaData object for a tapped face region
  static AreaData? findMatchingArea({
    required FaceAreaResult tapResult,
    required List<AreaData> fetchedAreas,
    String? treatmentGlobalSku,
  }) {
    if (fetchedAreas.isEmpty) return null;

    final List<AreaData> allAreas = _flattenAreas(fetchedAreas);
    final String mainArea = tapResult.mainArea.toLowerCase();
    final String detailArea = tapResult.detailArea.toLowerCase();

    // 1. Direct SKU Binding check for TRT-0001-BOTX (Botox)
    if (treatmentGlobalSku == 'TRT-0001-BOTX' ||
        (treatmentGlobalSku != null &&
            (treatmentGlobalSku.contains('BTX') ||
                treatmentGlobalSku.contains('BOT')))) {
      String? expectedSku;

      for (final entry in _botoxSkuByRegion.entries) {
        if (detailArea.contains(entry.key) || mainArea.contains(entry.key)) {
          expectedSku = entry.value;
          break;
        }
      }

      if (expectedSku != null) {
        final matched = allAreas.firstWhere(
          (a) => a.globalSku == expectedSku,
          orElse: () => AreaData(),
        );
        if (matched.id != null) return matched;
      }
    }

    // 2. Direct SKU Binding check for TRT-0002-DRMA (Dermal Fillers)
    if (treatmentGlobalSku == 'TRT-0002-DRMA' ||
        (treatmentGlobalSku != null &&
            (treatmentGlobalSku.contains('DRM') ||
                treatmentGlobalSku.contains('FILL')))) {
      String? expectedSku;

      for (final entry in _dermalSkuByRegion.entries) {
        if (detailArea.contains(entry.key) || mainArea.contains(entry.key)) {
          expectedSku = entry.value;
          break;
        }
      }

      if (expectedSku != null) {
        final matched = allAreas.firstWhere(
          (a) => a.globalSku == expectedSku,
          orElse: () => AreaData(),
        );
        if (matched.id != null) return matched;
      }
    }

    // 3. Direct SKU or exact name match in fetched areas
    for (final area in allAreas) {
      final areaName = (area.name ?? '').toLowerCase();
      final sku = (area.globalSku ?? '').toLowerCase();

      if (areaName.isEmpty) continue;

      if (areaName == detailArea || areaName == mainArea) {
        return area;
      }

      if (sku.isNotEmpty &&
          (sku.contains(detailArea) || sku.contains(mainArea))) {
        return area;
      }
    }

    // 4. Partial / Fuzzy name match in fetched areas
    for (final area in allAreas) {
      final areaName = (area.name ?? '').toLowerCase();
      if (areaName.isEmpty) continue;

      if (areaName.contains(detailArea) || detailArea.contains(areaName)) {
        return area;
      }
      if (areaName.contains(mainArea) || mainArea.contains(areaName)) {
        return area;
      }
    }

    // 5. Fallback Keyword Token matching
    for (final area in allAreas) {
      final areaName = (area.name ?? '').toLowerCase();
      if ((mainArea.contains('eye') || detailArea.contains('eye')) &&
          (areaName.contains('eye') ||
              areaName.contains('tear') ||
              areaName.contains('crow'))) {
        return area;
      }
      if ((mainArea.contains('cheek') || detailArea.contains('cheek')) &&
          areaName.contains('cheek')) {
        return area;
      }
      if ((mainArea.contains('lip') || detailArea.contains('lip')) &&
          (areaName.contains('lip') ||
              areaName.contains('mouth') ||
              areaName.contains('gummy'))) {
        return area;
      }
      if ((mainArea.contains('chin') || detailArea.contains('chin')) &&
          areaName.contains('chin')) {
        return area;
      }
      if ((mainArea.contains('jaw') || detailArea.contains('jaw')) &&
          (areaName.contains('jaw') ||
              areaName.contains('jowl') ||
              areaName.contains('masseter'))) {
        return area;
      }
      if ((mainArea.contains('nose') || detailArea.contains('nose')) &&
          (areaName.contains('nose') ||
              areaName.contains('naso') ||
              areaName.contains('bunny'))) {
        return area;
      }
      if ((mainArea.contains('temple') || detailArea.contains('temple')) &&
          areaName.contains('temple')) {
        return area;
      }
      if ((mainArea.contains('forehead') || detailArea.contains('forehead')) &&
          areaName.contains('forehead')) {
        return area;
      }
    }

    return null;
  }

  /// Flattens area hierarchy (including subAreas)
  static List<AreaData> _flattenAreas(List<AreaData> rootAreas) {
    final List<AreaData> result = [];
    void traverse(AreaData area) {
      result.add(area);
      if (area.subAreas != null && area.subAreas!.isNotEmpty) {
        for (final sub in area.subAreas!) {
          traverse(sub);
        }
      }
    }

    for (final a in rootAreas) {
      traverse(a);
    }
    return result;
  }
}
