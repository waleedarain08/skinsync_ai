import 'base_response_model.dart';

class PostTreatmentPhotosResponse extends BaseResponseModel {
  final List<PostTreatmentPhotoData> data;

  PostTreatmentPhotosResponse({
    required super.isSuccess,
    required super.message,
    required this.data,
  });

  factory PostTreatmentPhotosResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return PostTreatmentPhotosResponse(
      isSuccess: json['is_success'],
      message: json['message'],
      data: json['data'] != null
          ? List<PostTreatmentPhotoData>.from(
              json['data'].map(
                (x) => PostTreatmentPhotoData.fromJson(x),
              ),
            )
          : [],
    );
  }
}

class PostTreatmentPhotoData {
  final String? treatmentName;
  final int? treatmentId;
  final String? areaName;
  final int? areaId;
  final List<PhotoMilestone> photoMilestone;

  PostTreatmentPhotoData({
    this.treatmentName,
    this.treatmentId,
    this.areaName,
    this.areaId,
    this.photoMilestone = const [],
  });

  factory PostTreatmentPhotoData.fromJson(
    Map<String, dynamic> json,
  ) {
    return PostTreatmentPhotoData(
      treatmentName: json['treatment_name'],
      treatmentId: json['treatment_id'],
      areaName: json['area_name'],
      areaId: json['area_id'],
      photoMilestone: json['photo_milestone'] != null
          ? List<PhotoMilestone>.from(
              json['photo_milestone'].map(
                (x) => PhotoMilestone.fromJson(x),
              ),
            )
          : [],
    );
  }
}

class PhotoMilestone {
  final String? title;
  final bool? isUpload;
  final int? numberOfDays;
  final int? requiredPhotos;
  final List<String> uploadedPhotos;

  PhotoMilestone({
    this.title,
    this.isUpload,
    this.numberOfDays,
    this.requiredPhotos,
    this.uploadedPhotos = const [],
  });

  factory PhotoMilestone.fromJson(
    Map<String, dynamic> json,
  ) {
    return PhotoMilestone(
      title: json['title'],
      isUpload: json['isUpload'],
      numberOfDays: json['number_of_days'],
      requiredPhotos: json['required_photos'],
      uploadedPhotos: json['uploaded_photos'] != null
          ? List<String>.from(json['uploaded_photos'])
          : [],
    );
  }
}