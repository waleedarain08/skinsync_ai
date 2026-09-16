class PractitionerAvailabilityRequest {
  final int doctorId;
  final int date;
  final int clinicId;
  final List<PractitionerAvailabilityTreatmentRequest> treatments;

  PractitionerAvailabilityRequest({
    required this.doctorId,
    required this.date,
    required this.clinicId,
    required this.treatments,
  });

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'date': date,
      'clinic_id': clinicId,
      'treatments': treatments.map((e) => e.toJson()).toList(),
    };
  }
}

class PractitionerAvailabilityTreatmentRequest {
  final int treatmentId;
  final List<int> areaIds;

  PractitionerAvailabilityTreatmentRequest({
    required this.treatmentId,
    required this.areaIds,
  });

  Map<String, dynamic> toJson() {
    return {'treatment_id': treatmentId, 'area_ids': areaIds};
  }
}
