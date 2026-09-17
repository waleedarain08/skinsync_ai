import 'dart:convert';

import '../exceptions/app_exception.dart';
import '../models/requests/create_group_request.dart';
import '../models/requests/share_map_treatment_request.dart';
import '../models/requests/share_treatment_request.dart';
import '../models/requests/tj_options_request.dart';
import '../models/responses/auth_response.dart';
import '../models/responses/base_response_model.dart';
import '../models/responses/clinic_detail_response.dart';
import '../models/responses/groups_list_response.dart';
import '../models/responses/tj_option_simulations_response.dart';
import '../models/responses/tj_options_list_response.dart';
import '../repositories/treatment_requests_repository.dart';
import '../utils/enums.dart';
import 'api_base_helper.dart';

class TreatmentRequestsService implements TreatmentRequestsRepository {
  final ApiBaseHelper _apiClient;
  TreatmentRequestsService({required this._apiClient});

  @override
  Future<GroupsListResponse> getGroups({required int page,required String search,required bool isShared}) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.treatmentRequestGroups,
      requestType: RequestType.get,
      params: '?page=$page&limit=10&search=$search&is_shared=$isShared'
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return GroupsListResponse.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(
        AuthResponse.fromJson(parsed).message ?? "Failed to fetch groups",
      );
    }
  }

  @override
  Future<BaseResponseModel> createGroup(CreateGroupRequest request) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.treatmentRequestGroups,
      requestType: RequestType.post,
      requestBody: request.toJson(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return BaseResponseModel.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(
        AuthResponse.fromJson(parsed).message ?? "Failed to create group",
      );
    }
  }

  @override
  Future<TJOptionsListResponse> getOptions(int groupId) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.treatmentRequestOptions,
      requestType: RequestType.get,
      params: "?group_id=$groupId",
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return TJOptionsListResponse.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(
        AuthResponse.fromJson(parsed).message ?? "Failed to fetch options",
      );
    }
  }

  @override
  Future<BaseResponseModel> createTjOptions(TjOptionsRequest request) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.treatmentRequestOptions,
      requestType: RequestType.post,
      requestBody: request.toJson(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return BaseResponseModel.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(
        AuthResponse.fromJson(parsed).message ?? "Failed to create group",
      );
    }
  }

  @override
  Future<TJOptionSimulationsResponse> getOptionsDetail(int optionId) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.treatmentRequestOptions,
      requestType: RequestType.get,
      params: "/$optionId",
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return TJOptionSimulationsResponse.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(
        AuthResponse.fromJson(parsed).message ?? "Failed to fetch options",
      );
    }
  }

  @override
  Future<BaseResponseModel> shareTreatmentRequest({
    required ShareTreatmentRequest request,
  }) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.shareTreatmentRequest,
      requestType: RequestType.post,
      requestBody: request.toJson(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return BaseResponseModel.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(
        AuthResponse.fromJson(parsed).message ?? "Failed to create group",
      );
    }
  }

  @override
  Future<BaseResponseModel> shareMapTreatmentRequest({
    required ShareMapTreatmentRequest request,
  }) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.shareMapTreatmentRequest,
      requestType: RequestType.post,
      requestBody: request.toJson(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return BaseResponseModel.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(
        AuthResponse.fromJson(parsed).message ?? "Failed to create group",
      );
    }
  }

  @override
  Future<ClinicDetailResponse> getClinicDetail(int clinicId) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.clinic,
      requestType: RequestType.get,
      params: "/$clinicId",
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return ClinicDetailResponse.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(
        AuthResponse.fromJson(parsed).message ??
            "Failed to fetch clinic detail",
      );
    }
  }

   @override
  Future<BaseResponseModel> deleteGroup(int groupID) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.updateTreatmentRequestGroups,
      requestType: RequestType.delete,
      params: "/$groupID",
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return BaseResponseModel.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(
        AuthResponse.fromJson(parsed).message ?? "Failed to delete group",
      );
    }
  }

  @override
  Future<BaseResponseModel> deleteOption(int optionId) async {
    final response = await _apiClient.httpRequest(
      endPoint: EndPoints.deleteTreatmentRequestOptions,
      requestType: RequestType.delete,
      params: "/$optionId",
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return BaseResponseModel.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(
        AuthResponse.fromJson(parsed).message ?? "Failed to delete option",
      );
    }
  }

    @override
  Future<BaseResponseModel> updateTreatmantGroupName(int groupId , String name) async {
      final response = await _apiClient.httpRequest(
      endPoint: EndPoints.updateTreatmentRequestGroups,
      requestType: RequestType.patch,
        params: "/$groupId",
      requestBody: {
        'name' : name
      }
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final parsed = json.decode(response.body);
      return BaseResponseModel.fromJson(parsed);
    } else {
      final parsed = json.decode(response.body);
      throw AppException(
        AuthResponse.fromJson(parsed).message ?? "Failed to create group",
      );
    }
  }
}
