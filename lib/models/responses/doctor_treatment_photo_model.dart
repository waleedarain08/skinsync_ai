class DoctorTreatmentPhoto {
  final String id;
  final String url;
  final String title;
  final String? doctorName;
  final DateTime? dateTaken;
  final String? note;

  DoctorTreatmentPhoto({
    required this.id,
    required this.url,
    required this.title,
    this.doctorName,
    this.dateTaken,
    this.note,
  });

  factory DoctorTreatmentPhoto.fromJson(Map<String, dynamic> json) {
    return DoctorTreatmentPhoto(
      id: json['id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      title: json['title'] as String? ?? 'Doctor Photo',
      doctorName: json['doctor_name'] as String?,
      dateTaken: json['date_taken'] != null
          ? DateTime.tryParse(json['date_taken'])
          : null,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'title': title,
        'doctor_name': doctorName,
        'date_taken': dateTaken?.toIso8601String(),
        'note': note,
      };
}
