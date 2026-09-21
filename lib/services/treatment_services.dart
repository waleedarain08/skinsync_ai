import 'dart:convert';

import '../exceptions/app_exception.dart';
import '../models/requests/save_history_request.dart';
import '../models/responses/auth_response.dart';
import '../models/responses/base_response_model.dart';
import '../models/responses/materials_response.dart';
import '../models/responses/treatment_detail_response.dart';
import '../models/responses/treatment_list_response.dart';
import '../models/responses/treatment_progress_detail_response.dart';
import '../models/responses/treatment_progress_response.dart';
import '../repositories/treatment_repository.dart';
import '../utils/enums.dart';
import 'api_base_helper.dart';

class TreatmentService implements TreatmentRepository {
  final ApiBaseHelper _apiClient;
  TreatmentService({required this._apiClient});

  @override
  Future<TreatmentListResponse> getTreatments({
    String? search,
    int? categoryId,
    int? areaId,
    int page = 1,
    int limit = 10,
    bool? isSimulator,
  }) async {
    final Map<String, String> queryParams = {};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (categoryId != null) {
      queryParams['category_id'] = categoryId.toString();
    }
    if (areaId != null) {
      queryParams['area_id'] = areaId.toString();
    }
    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();
    if (isSimulator != null) {
      queryParams['is_simulator'] = isSimulator.toString();
    }

    final queryString = Uri(queryParameters: queryParams).query;
    final params = queryString.isNotEmpty ? '?$queryString' : '';

    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.treatmentList,
      requestType: .get,
      params: params,
    );
    // Check HTTP status code
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      TreatmentListResponse treatmentListResponse =
          TreatmentListResponse.fromJson(parsed);
      return treatmentListResponse;
    } else {
      // Handle HTTP error status codes
      final parsed = json.decode(response.body);
      throw AppException(AuthResponse.fromJson(parsed).message as String);
    }
  }

  @override
  Future<void> saveAiHistory(SaveHistoryRequest request) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.simulationHistory,
      requestType: .post,
      requestBody: request.toJson(),
    );
    // Check HTTP status code
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      final _ = BaseResponseModel.fromJson(parsed);
    } else {
      // Handle HTTP error status codes
      final parsed = json.decode(response.body);
      throw AppException(AuthResponse.fromJson(parsed).message as String);
    }
  }

  @override
  Future<TreatmentDetailResponse> getTreatmentDetail({
    required int treatmentId,
  }) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.treatments,
      requestType: .get,
      params: '/$treatmentId',
    );
    // Check HTTP status code
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      TreatmentDetailResponse detailResponse = TreatmentDetailResponse.fromJson(
        parsed,
      );
      return detailResponse;
    } else {
      // Handle HTTP error status codes
      final parsed = json.decode(response.body);
      throw AppException(AuthResponse.fromJson(parsed).message as String);
    }
  }

  @override
  Future<MaterialsResponse> getMaterials({
    required String treatmentSku,
    required String areaSku,
  }) async {
    final Map<String, String> queryParams = {
      'treatment_sku': treatmentSku,
      'area_sku': areaSku,
    };
    final queryString = Uri(queryParameters: queryParams).query;
    final params = queryString.isNotEmpty ? '?$queryString' : '';

    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.materials,
      requestType: .get,
      params: params,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return MaterialsResponse.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(AuthResponse.fromJson(parsed).message as String);
    }
  }

  @override
  Future<TreatmentProgressResponse> getTreatmentProgress({
    int page = 1,
    int limit = 10,
    int? treatmentId,
    int? areaId,
  }) async {
    final Map<String, String> queryParams = {};
    queryParams['page'] = page.toString();
    queryParams['limit'] = limit.toString();
    if (areaId != null) {
      queryParams['area_id'] = areaId.toString();
    }
    if (treatmentId != null) {
      queryParams['treatment_id'] = areaId.toString();
    }
    final queryString = Uri(queryParameters: queryParams).query;
    final params = queryString.isNotEmpty ? '?$queryString' : '';
    final jsonResponse = await _apiClient.httpRequest(
      endPoint: EndPoints.treatmentProgress,
      requestType: .get,
      params: params,
    );
    // Check HTTP status code
    if (jsonResponse.statusCode >= 200 && jsonResponse.statusCode < 300) {
      final parsed = json.decode(jsonResponse.body);
      TreatmentProgressResponse response = TreatmentProgressResponse.fromJson(
        parsed,
      );
      return response;
    } else {
      // Handle HTTP error status codes
      final parsed = json.decode(jsonResponse.body);
      throw AppException(AuthResponse.fromJson(parsed).message as String);
    }
  }

  @override
  Future<TreatmentProgressDetailResponse> getTreatmentprogressDetail({
    required int progressID,
  }) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.treatmentProgress,
      requestType: .get,
      params: '/$progressID',
    );
    // Check HTTP status code
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      TreatmentProgressDetailResponse detailResponse =
          TreatmentProgressDetailResponse.fromJson(parsed);
      return detailResponse;
    } else {
      // Handle HTTP error status codes
      final parsed = json.decode(response.body);
      throw AppException(AuthResponse.fromJson(parsed).message as String);
    }
  }
}
