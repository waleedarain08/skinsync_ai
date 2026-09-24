import 'dart:convert';

import '../exceptions/app_exception.dart';
import '../models/requests/appointment_request.dart';
import '../models/requests/change_payment_status_request.dart';
import '../models/requests/instructions_request.dart';
import '../models/requests/post_treatment_photos_request.dart';
import '../models/requests/scan_qr_request.dart';
import '../models/responses/appointment_detail_response.dart';
import '../models/responses/appointment_response.dart';
import '../models/responses/appointment_type_list_response.dart';
import '../models/responses/appointments_list_response.dart';
import '../models/responses/base_response_model.dart';
import '../models/responses/instructions_response.dart';
import '../models/responses/post_treatment_photos_response.dart';
import '../models/responses/scan_qr_response.dart';
import '../models/responses/simulation_history_response.dart';
import '../repositories/appointment_repository.dart';
import '../utils/enums.dart';
import 'api_base_helper.dart';

class AppointmentService implements AppointmentRepository {
  final ApiBaseHelper _apiClient;
  AppointmentService({required this._apiClient});

  @override
  Future<AppointmentTypeListResponse> getAppointmentTypes() async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.appointmentTypes,
      requestType: .get,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return AppointmentTypeListResponse.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(
        AppointmentTypeListResponse.fromJson(parsed).message ??
            "Failed to fetch appointment types",
      );
    }
  }

  @override
  Future<AppointmentsListResponse> getAppointmentsApi({
    required int page,
    required int limit,
  }) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.appointments,
      requestType: .get,
      params: '?page=$page&limit=$limit',
    );
    // Check HTTP status code
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      AppointmentsListResponse appointmentResponse =
          AppointmentsListResponse.fromJson(parsed);
      return appointmentResponse;
    } else {
      // Handle HTTP error status codes
      final parsed = json.decode(response.body);
      throw AppException(
        AppointmentsListResponse.fromJson(parsed).message ??
            "Something went wrong",
      );
    }
  }

  @override
  Future<AppointmentDetailResponse> getAppointmentDetail({
    required int appointmentId,
  }) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.appointments,
      requestType: .get,
      params: '/$appointmentId',
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return AppointmentDetailResponse.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(
        AppointmentDetailResponse.fromJson(parsed).message ??
            "Failed to fetch appointment detail",
      );
    }
  }

  @override
  Future<List<SimulationData>> getSimulationHistory() async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.simulationHistory,
      requestType: .get,
    );
    // Check HTTP status code
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      final appointmentResponse = SimulationHistoryResponse.fromJson(parsed);
      return appointmentResponse.data ?? [];
    } else {
      // Handle HTTP error status codes
      final parsed = json.decode(response.body);
      throw AppException(parsed['message'] ?? "Something went wrong");
    }
  }

  @override
  Future<AppointmentData> createAppointment({
    required AppointmentRequest request,
  }) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.appointments,
      requestType: .post,
      requestBody: request.toJson(),
      params: '',
    );
    final data = AppointmentResponse.fromJson(jsonDecode(response.body));
    if (!(data.status ?? false)) {
      throw AppException(data.message ?? 'Something went wrong!');
    }
    return data.data!;
  }
   @override
  Future<ScanQrResponse> scanQrCode({
    required ScanQrRequest request,
  })async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.qrScan,
      requestType: .post,
      requestBody: request.toJson(),
      params: '',
    );
    final data = ScanQrResponse.fromJson(jsonDecode(response.body));
    if (!(data.status ?? false)) {
      throw AppException(data.message ?? 'Something went wrong!');
    }
    return data;
  }
   @override
 Future<InstructionsResponse> postInstructions({
    required InstructionsRequest request,
  })async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.postInstructions,
      requestType: .post,
      requestBody: request.toJson(),
      params: '',
    );
    final data = InstructionsResponse.fromJson(jsonDecode(response.body));
    if (!(data.status ?? false)) {
      throw AppException(data.message ?? 'Something went wrong!');
    }
    return data;
  }
   @override
  Future<InstructionsResponse> preInstructions ({
    required InstructionsRequest request,
  })async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.preInstructions,
      requestType: .post,
      requestBody: request.toJson(),
      params: '',
    );
    final data = InstructionsResponse.fromJson(jsonDecode(response.body));
    if (!(data.status ?? false)) {
      throw AppException(data.message ?? 'Something went wrong!');
    }
    return data;
  }
   @override
  Future<PostTreatmentPhotosResponse> postTreatmentPhotos({
    required InstructionsRequest request,
  })async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.postTreatmentPhotos,
      requestType: .post,
      requestBody: request.toJson(),
      params: '',
    );
    final data = PostTreatmentPhotosResponse.fromJson(jsonDecode(response.body));
    if (!(data.status ?? false)) {
      throw AppException(data.message ?? 'Something went wrong!');
    }
    return data;
  }


 @override
 Future<BaseResponseModel> updatePostTreatmentPhotos({
    required PostTreatmentPhotosRequest request,
  })async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.postTreatmentPhotos,
      requestType: .patch,
      requestBody: request.toJson(),
      params: '',
    );
    final data = BaseResponseModel.fromJson(jsonDecode(response.body));
    if (!(data.status ?? false)) {
      throw AppException(data.message ?? 'Something went wrong!');
    }
    return data;
  }
 @override
  Future<BaseResponseModel> changePaymentStatus({
    required int appointmentId,
    required ChangePaymentStatusRequest request,
  })async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.appointments,
      requestType: .patch,
      requestBody: request.toJson(),
      params: '/$appointmentId/payment-status',
    );
    final data = BaseResponseModel.fromJson(jsonDecode(response.body));
    if (!(data.status ?? false)) {
      throw AppException(data.message ?? 'Something went wrong!');
    }
    return data;
  }

}
