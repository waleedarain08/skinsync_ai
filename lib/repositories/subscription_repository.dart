import '../models/responses/base_response_model.dart';
import '../models/responses/patient_plans_response.dart';
import '../models/responses/subscription_response.dart';
import '../utils/enums.dart';

abstract class SubscriptionRepository {
  Future<PatientPlansResponse> getPatientCurrentPlan();
  Future<SubscriptionResponse> upgradePlan({
    required String planId,
    String? durationId,
  });
  Future<BaseResponseModel> recordUsage({
    required UsageType usageType,
    required String subscriptionId,
  });
}
