class TreatmentPriceResult {
  final String? name;
  final num totalPrice;
  final List<TreatmentAreaPriceResult> areas;

  TreatmentPriceResult({
    required this.name,
    required this.totalPrice,
    this.areas = const [],
  });
}

class TreatmentAreaPriceResult {
  final String? name;
  final num price;
  final int quantity;
  final num totalPrice;

  TreatmentAreaPriceResult({
    required this.name,
    required this.price,
    required this.quantity,
    required this.totalPrice,
  });
}