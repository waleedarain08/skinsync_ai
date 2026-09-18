import '../models/responses/simulation_history_response.dart';
import '../models/treatment_price_model.dart';

class PriceUtils {
  static List<TreatmentPriceResult> calculateTreatmentPrices(
    List<SimulationTreatment> treatments,
  ) {
    return treatments.map((treatment) {
      num treatmentTotal = 0;

      final areaPrices = <TreatmentAreaPriceResult>[];

      for (final area in treatment.areas ?? <SimulationArea>[]) {
        final num areaPrice = area.price ?? 0;

        int totalQuantity = 0;

        for (final material
            in area.materials ?? <SimulationMaterial>[]) {
          totalQuantity += material.selectedQuantity ?? 0;
        }

        final num calculatedAreaPrice = totalQuantity == 0
            ? areaPrice
            : areaPrice * totalQuantity;

        treatmentTotal += calculatedAreaPrice;

        areaPrices.add(
          TreatmentAreaPriceResult(
            name: area.name,
            price: areaPrice,
            quantity: totalQuantity,
            totalPrice: calculatedAreaPrice,
          ),
        );
      }

      return TreatmentPriceResult(
        name: treatment.name,
        totalPrice: treatmentTotal,
        areas: areaPrices,
      );
    }).toList();
  }

  static num calculateGrandTotal(
    List<SimulationTreatment> treatments,
  ) {
    final treatmentPrices = calculateTreatmentPrices(treatments);

    return treatmentPrices.fold<num>(
      0,
      (total, treatment) => total + treatment.totalPrice,
    );
  }
}