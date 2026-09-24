class PostTreatmentPhotosRequest {
  final int appointmentId;
  final int treatmentId;
  final int areaId;
  final PhotoMilestoneRequest photoMilestone;

  PostTreatmentPhotosRequest({
    required this.appointmentId,
    required this.treatmentId,
    required this.areaId,
    required this.photoMilestone,
  });

  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'treatment_id': treatmentId,
      'area_id': areaId,
      'photo_milestone': photoMilestone.toJson(),
    };
  }
}

class PhotoMilestoneRequest {
  final String title;
  final bool isUpload;
  final int numberOfDays;
  final int requiredPhotos;
  final List<String> uploadedPhotos;

  PhotoMilestoneRequest({
    required this.title,
    required this.isUpload,
    required this.numberOfDays,
    required this.requiredPhotos,
    required this.uploadedPhotos,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'isUpload': isUpload,
      'number_of_days': numberOfDays,
      'required_photos': requiredPhotos,
      'uploaded_photos': uploadedPhotos,
    };
  }
}