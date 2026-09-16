import 'dart:convert';

import '../exceptions/app_exception.dart';
import '../models/requests/get_practitioners_request.dart';
import '../models/requests/practitioner_availability_request.dart';
import '../models/responses/availability_response.dart';
import '../models/responses/base_response_model.dart';
import '../models/responses/practitioner_list_response.dart';
import '../repositories/doctor_repository.dart';
import '../utils/date_time_utils.dart';
import '../utils/enums.dart';
import 'api_base_helper.dart';

class DoctorService implements DoctorRepository {
  final ApiBaseHelper _apiClient;

  DoctorService({required this._apiClient});

  @override
  Future<PractitionerListResponse> getPractitioners({
    required GetPractitionersRequest request,
  }) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.practitionersList,
      requestType: .post,
      requestBody: request.toJson(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return PractitionerListResponse.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(
        PractitionerListResponse.fromJson(parsed).message ??
            'Error fetching practitioners',
      );
    }
  }

 @override
  Future<AvailabilityResponse> getPractitionerAvailability({
    required PractitionerAvailabilityRequest request,
  }) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.practitionersAvailability,
      requestType: .post,
      requestBody: request.toJson(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return AvailabilityResponse.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(
        BaseResponseModel.fromJson(parsed).message ??
            'Error fetching practitioners',
      );
    }
  }


  @override
  Future<PractitionerListResponse> getDoctors({
    required int clinicId,
    required int treatmentId,
    required String sideAreaIdsList,
  }) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.getDoctor,
      requestType: .get,
      params:
          'clinic_id=$clinicId&treatment_id=$treatmentId&side_area_ids=$sideAreaIdsList',
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return PractitionerListResponse.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(
        PractitionerListResponse.fromJson(parsed).message as String,
      );
    }
  }

  @override
  Future<List<Slot>> getAvailability({
    required int doctorId,
    required int clinicId,
    required DateTime date,
  }) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.getAvailability,
      requestType: .get,
      params:
          '?doctor_id=$doctorId&clinic_id=$clinicId&date=${date.secondsSinceEpoch}',
    );
    final data = AvailabilityResponse.fromJson(jsonDecode(response.body));
    if (data.status == false) {
      throw Exception(data.message ?? 'Something went wrong!');
    }
    return data.slots;
  }
}
