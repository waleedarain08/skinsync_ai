class GetPractitionersRequest {
  final int page;
  final int limit;
  final int? date;
  final int? startTime;
  final int? endTime;
  final int? clinicId;
  final bool? isVirtual;
  final String? practitionerType;
  final String? search;
  final List<int>? treatmentIds;

  GetPractitionersRequest({
    this.page = 1,
    this.limit = 10,
    this.date,
    this.startTime,
    this.endTime,
    this.clinicId,
    this.isVirtual,
    this.practitionerType = "doctor",
    this.search,
    this.treatmentIds,
  });

  Map<String, dynamic> toJson() {
    return {
      "page": page,
      "limit": limit,
      "date": date,
      "start_time": startTime,
      "end_time": endTime,
      "clinic_id": clinicId,
      "is_virtual": isVirtual,
      "practitioner_type": practitionerType,
      "search": search,
      "treatment_ids": treatmentIds,
    };
  }
}