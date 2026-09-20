import 'doctor_treatment_photo_model.dart';

class UploadedPhoto {
  final String id;
  final String url;
  final String? label; // e.g. "Front View", "Left Profile", "Right Profile"
  final DateTime uploadedAt;

  UploadedPhoto({
    required this.id,
    required this.url,
    this.label,
    required this.uploadedAt,
  });

  factory UploadedPhoto.fromJson(Map<String, dynamic> json) {
    return UploadedPhoto(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      label: json['label'] as String?,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'label': label,
        'uploaded_at': uploadedAt.toIso8601String(),
      };
}

class PhotoMilestoneItem {
  final int numberOfDays;
  final int requiredPhotos;
  final String title;
  final List<UploadedPhoto> uploadedPhotos;

  PhotoMilestoneItem({
    required this.numberOfDays,
    required this.requiredPhotos,
    required this.title,
    this.uploadedPhotos = const [],
  });

  bool get isCompleted => uploadedPhotos.length >= requiredPhotos;
  int get remainingPhotos =>
      (requiredPhotos - uploadedPhotos.length).clamp(0, requiredPhotos);

  factory PhotoMilestoneItem.fromJson(Map<String, dynamic> json) {
    return PhotoMilestoneItem(
      numberOfDays: json['number_of_days'] as int? ?? 0,
      requiredPhotos: json['required_photos'] as int? ?? 1,
      title: json['title'] as String? ?? 'Milestone Check',
      uploadedPhotos: json['uploaded_photos'] != null
          ? List<UploadedPhoto>.from(
              (json['uploaded_photos'] as List)
                  .map((x) => UploadedPhoto.fromJson(x)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'number_of_days': numberOfDays,
        'required_photos': requiredPhotos,
        'title': title,
        'uploaded_photos': uploadedPhotos.map((x) => x.toJson()).toList(),
      };
}

class PostTreatmentPhotoItem {
  final int treatmentId;
  final String treatmentName;
  final String? areaName;
  final bool requirePostTreatmentPhotos;
  final List<PhotoMilestoneItem> photoMilestones;
  final List<DoctorTreatmentPhoto> doctorPhotos;

  PostTreatmentPhotoItem({
    required this.treatmentId,
    required this.treatmentName,
    this.areaName,
    this.requirePostTreatmentPhotos = true,
    this.photoMilestones = const [],
    this.doctorPhotos = const [],
  });

  factory PostTreatmentPhotoItem.fromJson(Map<String, dynamic> json) {
    return PostTreatmentPhotoItem(
      treatmentId: json['treatment_id'] as int? ?? 0,
      treatmentName: json['treatment_name'] as String? ?? 'Treatment',
      areaName: json['area_name'] as String?,
      requirePostTreatmentPhotos:
          json['require_post_treatment_photos'] as bool? ?? true,
      photoMilestones: json['photo_milestone'] != null
          ? List<PhotoMilestoneItem>.from(
              (json['photo_milestone'] as List)
                  .map((x) => PhotoMilestoneItem.fromJson(x)),
            )
          : [],
      doctorPhotos: json['doctor_photos'] != null
          ? List<DoctorTreatmentPhoto>.from(
              (json['doctor_photos'] as List)
                  .map((x) => DoctorTreatmentPhoto.fromJson(x)),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'treatment_id': treatmentId,
        'treatment_name': treatmentName,
        'area_name': areaName,
        'require_post_treatment_photos': requirePostTreatmentPhotos,
        'photo_milestone': photoMilestones.map((x) => x.toJson()).toList(),
        'doctor_photos': doctorPhotos.map((x) => x.toJson()).toList(),
      };
}
