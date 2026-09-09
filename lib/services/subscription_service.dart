import 'dart:convert';

import '../models/responses/base_response_model.dart';
import '../models/responses/patient_plans_response.dart';
import '../models/responses/subscription_response.dart';
import '../repositories/subscription_repository.dart';
import '../utils/enums.dart';
import 'api_base_helper.dart';

class SubscriptionService implements SubscriptionRepository {
  final ApiBaseHelper apiClient;

  SubscriptionService({required this.apiClient});

  @override
  Future<PatientPlansResponse> getPatientCurrentPlan() async {
    final response = await apiClient.httpRequest(
      endPoint: EndPoints.patientCurrentPlan,
      requestType: RequestType.get,
    );
    return PatientPlansResponse.fromJson(jsonDecode(response.body));
  }

  @override
  Future<SubscriptionResponse> upgradePlan({
    required String planId,
    String? durationId,
  }) async {
    final Map<String, dynamic> body = {"plan_id": planId};
    if (durationId != null) {
      body["duration_id"] = durationId;
    }

    final response = await apiClient.httpRequest(
      endPoint: EndPoints.subscribe,
      requestType: RequestType.post,
      requestBody: body,
    );
    return SubscriptionResponse.fromJson(jsonDecode(response.body));
  }

  @override
  Future<BaseResponseModel> recordUsage({
    required UsageType usageType,
    required String subscriptionId,
  }) async {
    final Map<String, dynamic> body = {
      "usage_type": usageType.value,
      "subscription_id": subscriptionId,
    };

    final response = await apiClient.httpRequest(
      endPoint: EndPoints.patientUsages,
      requestType: RequestType.post,
      requestBody: body,
    );
    return BaseResponseModel.fromJson(jsonDecode(response.body));
  }
}
