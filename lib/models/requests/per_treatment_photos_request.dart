class PerTreatmentPhotosRequest {
  final int appointmentId;
  final List<String> imageUrls;

  PerTreatmentPhotosRequest({
    required this.appointmentId,
    required this.imageUrls,
  });

  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'image_urls': imageUrls,
    };
  }
}
