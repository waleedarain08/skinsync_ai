import 'base_response_model.dart';
import 'treatment_category_list_response.dart';

class TreatmentDetailResponse extends BaseResponseModel {
  TreatmentDetailModel? data;

  TreatmentDetailResponse({super.isSuccess, super.message, this.data});

  TreatmentDetailResponse.fromJson(Map<String, dynamic> json) {
    isSuccess = json['is_success'] ?? (json['id'] != null || json['data'] != null);
    message = json['message'] as String?;
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      data = TreatmentDetailModel.fromJson(json['data'] as Map<String, dynamic>);
    } else if (json['id'] != null) {
      data = TreatmentDetailModel.fromJson(json);
    } else {
      data = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    dataMap['is_success'] = isSuccess;
    dataMap['message'] = message;
    if (data != null) {
      dataMap['data'] = data!.toJson();
    }
    return dataMap;
  }
}

class TreatmentDetailModel {
  int? id;
  int? currentStep;
  String? status;
  String? name;
  List<int>? selectedCategoryIds;
  List<TreatmentCategoryModel>? selectedCategories;
  String? globalSku;
  String? patientDisplayName;
  String? image;
  String? icon;
  String? shortDescription;
  String? description;
  List<int>? selectedAreaIds;
  List<SelectedArea>? selectedAreas;
  List<ProductUsage>? productUsages;
  int? baseDuration;
  int? prepTime;
  int? cleanupTime;
  List<ProductDuration>? productDurations;
  bool? allowClinicOverride;
  bool? allowProviderOverride;
  bool? onlineBookable;
  bool? manualApprovalRequired;
  int? minimumBookingNotice;
  int? maximumDaysInAdvance;
  num? basePrice;
  List<UnitPriceOverride>? unitPriceOverrides;
  ClinicalProtocolPdf? clinicalProtocolPdf;
  String? preTreatmentInstructions;
  List<Attachment>? preTreatmentAttachments;
  String? postTreatmentInstructions;
  List<Attachment>? postTreatmentAttachments;
  bool? requirePostTreatmentPhotos;
  int? requiredPostTreatmentPhotoCount;
  List<NotificationModel>? preNotifications;
  List<NotificationModel>? postNotifications;
  String? downtimeLevel;
  int? downtimeDays;
  List<String>? allowedRoles;
  int? totalSessions;
  List<Session>? sessions;
  ConsentForm? preTreatmentConsentForm;
  bool? enableByDefault;
  bool? useInAiSimulator;
  String? createdAt;
  String? updatedAt;

  TreatmentDetailModel({
    this.id,
    this.currentStep,
    this.status,
    this.name,
    this.selectedCategoryIds,
    this.selectedCategories,
    this.globalSku,
    this.patientDisplayName,
    this.image,
    this.icon,
    this.shortDescription,
    this.description,
    this.selectedAreaIds,
    this.selectedAreas,
    this.productUsages,
    this.baseDuration,
    this.prepTime,
    this.cleanupTime,
    this.productDurations,
    this.allowClinicOverride,
    this.allowProviderOverride,
    this.onlineBookable,
    this.manualApprovalRequired,
    this.minimumBookingNotice,
    this.maximumDaysInAdvance,
    this.basePrice,
    this.unitPriceOverrides,
    this.clinicalProtocolPdf,
    this.preTreatmentInstructions,
    this.preTreatmentAttachments,
    this.postTreatmentInstructions,
    this.postTreatmentAttachments,
    this.requirePostTreatmentPhotos,
    this.requiredPostTreatmentPhotoCount,
    this.preNotifications,
    this.postNotifications,
    this.downtimeLevel,
    this.downtimeDays,
    this.allowedRoles,
    this.totalSessions,
    this.sessions,
    this.preTreatmentConsentForm,
    this.enableByDefault,
    this.useInAiSimulator,
    this.createdAt,
    this.updatedAt,
  });

  TreatmentDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    patientDisplayName = json['patient_display_name'] as String? ?? json['name'] as String?;
    name = json['name'] as String? ?? json['patient_display_name'] as String?;
    currentStep = json['current_step'] as int?;
    status = json['status'] as String?;

    if (json['selected_category_ids'] != null) {
      selectedCategoryIds = (json['selected_category_ids'] as List).map((e) => (e as num).toInt()).toList();
    }

    if (json['selected_categories'] != null && json['selected_categories'] is List) {
      selectedCategories = <TreatmentCategoryModel>[];
      for (final v in json['selected_categories'] as List) {
        if (v is Map<String, dynamic>) {
          selectedCategories!.add(TreatmentCategoryModel.fromJson(v));
        }
      }
    }

    globalSku = json['global_sku'] as String?;
    image = json['image'] as String?;
    icon = json['icon'] as String?;
    shortDescription = json['short_description'] as String?;
    description = json['description'] as String?;

    if (json['selected_area_ids'] != null) {
      selectedAreaIds = (json['selected_area_ids'] as List).map((e) => (e as num).toInt()).toList();
    }

    if (json['selected_areas'] != null && json['selected_areas'] is List) {
      selectedAreas = <SelectedArea>[];
      for (final v in json['selected_areas'] as List) {
        if (v is Map<String, dynamic>) {
          selectedAreas!.add(SelectedArea.fromJson(v));
        }
      }
    }

    if (json['product_usages'] != null && json['product_usages'] is List) {
      productUsages = <ProductUsage>[];
      for (final v in json['product_usages'] as List) {
        if (v is Map<String, dynamic>) {
          productUsages!.add(ProductUsage.fromJson(v));
        }
      }
    }

    baseDuration = json['base_duration'] as int?;
    prepTime = json['prep_time'] as int?;
    cleanupTime = json['cleanup_time'] as int?;

    if (json['product_durations'] != null && json['product_durations'] is List) {
      productDurations = <ProductDuration>[];
      for (final v in json['product_durations'] as List) {
        if (v is Map<String, dynamic>) {
          productDurations!.add(ProductDuration.fromJson(v));
        }
      }
    }

    allowClinicOverride = json['allow_clinic_override'] as bool?;
    allowProviderOverride = json['allow_provider_override'] as bool?;
    onlineBookable = json['online_bookable'] as bool?;
    manualApprovalRequired = json['manual_approval_required'] as bool?;
    minimumBookingNotice = json['minimum_booking_notice'] as int?;
    maximumDaysInAdvance = json['maximum_days_in_advance'] as int?;
    basePrice = json['base_price'] as num?;

    if (json['unit_price_overrides'] != null && json['unit_price_overrides'] is List) {
      unitPriceOverrides = <UnitPriceOverride>[];
      for (final v in json['unit_price_overrides'] as List) {
        if (v is Map<String, dynamic>) {
          unitPriceOverrides!.add(UnitPriceOverride.fromJson(v));
        }
      }
    }

    if (json['clinical_protocol_pdf'] != null && json['clinical_protocol_pdf'] is Map<String, dynamic>) {
      clinicalProtocolPdf = ClinicalProtocolPdf.fromJson(json['clinical_protocol_pdf'] as Map<String, dynamic>);
    }

    preTreatmentInstructions = json['pre_treatment_instructions'] as String?;
    if (json['pre_treatment_attachments'] != null && json['pre_treatment_attachments'] is List) {
      preTreatmentAttachments = <Attachment>[];
      for (final v in json['pre_treatment_attachments'] as List) {
        if (v is Map<String, dynamic>) {
          preTreatmentAttachments!.add(Attachment.fromJson(v));
        }
      }
    }

    postTreatmentInstructions = json['post_treatment_instructions'] as String?;
    if (json['post_treatment_attachments'] != null && json['post_treatment_attachments'] is List) {
      postTreatmentAttachments = <Attachment>[];
      for (final v in json['post_treatment_attachments'] as List) {
        if (v is Map<String, dynamic>) {
          postTreatmentAttachments!.add(Attachment.fromJson(v));
        }
      }
    }

    requirePostTreatmentPhotos = json['require_post_treatment_photos'] as bool?;
    requiredPostTreatmentPhotoCount = json['required_post_treatment_photo_count'] as int?;

    if (json['pre_notifications'] != null && json['pre_notifications'] is List) {
      preNotifications = <NotificationModel>[];
      for (final v in json['pre_notifications'] as List) {
        if (v is Map<String, dynamic>) {
          preNotifications!.add(NotificationModel.fromJson(v));
        }
      }
    }

    if (json['post_notifications'] != null && json['post_notifications'] is List) {
      postNotifications = <NotificationModel>[];
      for (final v in json['post_notifications'] as List) {
        if (v is Map<String, dynamic>) {
          postNotifications!.add(NotificationModel.fromJson(v));
        }
      }
    }

    downtimeLevel = json['downtime_level'] as String?;
    downtimeDays = json['downtime_days'] as int?;

    if (json['allowed_roles'] != null && json['allowed_roles'] is List) {
      allowedRoles = List<String>.from(json['allowed_roles']);
    }

    totalSessions = json['total_sessions'] as int?;

    if (json['sessions'] != null && json['sessions'] is List) {
      sessions = <Session>[];
      for (final v in json['sessions'] as List) {
        if (v is Map<String, dynamic>) {
          sessions!.add(Session.fromJson(v));
        }
      }
    }

    if (json['pre_treatment_consent_form'] != null && json['pre_treatment_consent_form'] is Map<String, dynamic>) {
      preTreatmentConsentForm = ConsentForm.fromJson(json['pre_treatment_consent_form'] as Map<String, dynamic>);
    }

    enableByDefault = json['enable_by_default'] as bool?;
    useInAiSimulator = json['use_in_ai_simulator'] as bool?;
    createdAt = json['created_at'] as String?;
    updatedAt = json['updated_at'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['current_step'] = currentStep;
    data['status'] = status;
    if (selectedCategoryIds != null) {
      data['selected_category_ids'] = selectedCategoryIds;
    }
    if (selectedCategories != null) {
      data['selected_categories'] = selectedCategories!.map((v) => v.toJson()).toList();
    }
    data['global_sku'] = globalSku;
    data['patient_display_name'] = patientDisplayName;
    data['name'] = name;
    data['image'] = image;
    data['icon'] = icon;
    data['short_description'] = shortDescription;
    data['description'] = description;
    if (selectedAreaIds != null) {
      data['selected_area_ids'] = selectedAreaIds;
    }
    if (selectedAreas != null) {
      data['selected_areas'] = selectedAreas!.map((v) => v.toJson()).toList();
    }
    if (productUsages != null) {
      data['product_usages'] = productUsages!.map((v) => v.toJson()).toList();
    }
    data['base_duration'] = baseDuration;
    data['prep_time'] = prepTime;
    data['cleanup_time'] = cleanupTime;
    if (productDurations != null) {
      data['product_durations'] = productDurations!.map((v) => v.toJson()).toList();
    }
    data['allow_clinic_override'] = allowClinicOverride;
    data['allow_provider_override'] = allowProviderOverride;
    data['online_bookable'] = onlineBookable;
    data['manual_approval_required'] = manualApprovalRequired;
    data['minimum_booking_notice'] = minimumBookingNotice;
    data['maximum_days_in_advance'] = maximumDaysInAdvance;
    data['base_price'] = basePrice;
    if (unitPriceOverrides != null) {
      data['unit_price_overrides'] = unitPriceOverrides!.map((v) => v.toJson()).toList();
    }
    if (clinicalProtocolPdf != null) {
      data['clinical_protocol_pdf'] = clinicalProtocolPdf!.toJson();
    }
    data['pre_treatment_instructions'] = preTreatmentInstructions;
    if (preTreatmentAttachments != null) {
      data['pre_treatment_attachments'] = preTreatmentAttachments!.map((v) => v.toJson()).toList();
    }
    data['post_treatment_instructions'] = postTreatmentInstructions;
    if (postTreatmentAttachments != null) {
      data['post_treatment_attachments'] = postTreatmentAttachments!.map((v) => v.toJson()).toList();
    }
    data['require_post_treatment_photos'] = requirePostTreatmentPhotos;
    data['required_post_treatment_photo_count'] = requiredPostTreatmentPhotoCount;
    if (preNotifications != null) {
      data['pre_notifications'] = preNotifications!.map((v) => v.toJson()).toList();
    }
    if (postNotifications != null) {
      data['post_notifications'] = postNotifications!.map((v) => v.toJson()).toList();
    }
    data['downtime_level'] = downtimeLevel;
    data['downtime_days'] = downtimeDays;
    if (allowedRoles != null) {
      data['allowed_roles'] = allowedRoles;
    }
    data['total_sessions'] = totalSessions;
    if (sessions != null) {
      data['sessions'] = sessions!.map((v) => v.toJson()).toList();
    }
    if (preTreatmentConsentForm != null) {
      data['pre_treatment_consent_form'] = preTreatmentConsentForm!.toJson();
    }
    data['enable_by_default'] = enableByDefault;
    data['use_in_ai_simulator'] = useInAiSimulator;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class SelectedArea {
  int? id;
  String? name;
  String? globalSku;
  String? icon;
  String? image;
  String? status;

  SelectedArea({
    this.id,
    this.name,
    this.globalSku,
    this.icon,
    this.image,
    this.status,
  });

  SelectedArea.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    name = json['name'] as String?;
    globalSku = json['global_sku'] as String?;
    icon = json['icon'] as String?;
    image = json['image'] as String?;
    status = json['status'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['global_sku'] = globalSku;
    data['icon'] = icon;
    data['image'] = image;
    data['status'] = status;
    return data;
  }
}

class ProductUsage {
  int? productId;
  String? productName;
  String? productImage;
  String? productSku;
  String? deductionTiming;
  bool? allowSubstitution;
  String? notes;
  List<SubAreaConsumption>? subAreaConsumptions;

  ProductUsage({
    this.productId,
    this.productName,
    this.productImage,
    this.productSku,
    this.deductionTiming,
    this.allowSubstitution,
    this.notes,
    this.subAreaConsumptions,
  });

  ProductUsage.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'] as int?;
    productName = json['product_name'] as String?;
    productImage = json['product_image'] as String?;
    productSku = json['product_sku'] as String?;
    deductionTiming = json['deduction_timing'] as String?;
    allowSubstitution = json['allow_substitution'] as bool?;
    notes = json['notes'] as String?;
    if (json['sub_area_consumptions'] != null && json['sub_area_consumptions'] is List) {
      subAreaConsumptions = <SubAreaConsumption>[];
      for (final v in json['sub_area_consumptions'] as List) {
        if (v is Map<String, dynamic>) {
          subAreaConsumptions!.add(SubAreaConsumption.fromJson(v));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['product_image'] = productImage;
    data['product_sku'] = productSku;
    data['deduction_timing'] = deductionTiming;
    data['allow_substitution'] = allowSubstitution;
    data['notes'] = notes;
    if (subAreaConsumptions != null) {
      data['sub_area_consumptions'] = subAreaConsumptions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubAreaConsumption {
  int? subAreaId;
  String? subAreaName;
  num? minQuantity;
  num? maxQuantity;

  SubAreaConsumption({
    this.subAreaId,
    this.subAreaName,
    this.minQuantity,
    this.maxQuantity,
  });

  SubAreaConsumption.fromJson(Map<String, dynamic> json) {
    subAreaId = json['sub_area_id'] as int?;
    subAreaName = json['sub_area_name'] as String?;
    minQuantity = json['min_quantity'] as num?;
    maxQuantity = json['max_quantity'] as num?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sub_area_id'] = subAreaId;
    data['sub_area_name'] = subAreaName;
    data['min_quantity'] = minQuantity;
    data['max_quantity'] = maxQuantity;
    return data;
  }
}

class ProductDuration {
  int? productId;
  String? productName;
  num? perUnitDuration;

  ProductDuration({this.productId, this.productName, this.perUnitDuration});

  ProductDuration.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'] as int?;
    productName = json['product_name'] as String?;
    perUnitDuration = json['per_unit_duration'] as num?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['per_unit_duration'] = perUnitDuration;
    return data;
  }
}

class UnitPriceOverride {
  int? productId;
  String? productName;
  num? pricePerUnit;

  UnitPriceOverride({this.productId, this.productName, this.pricePerUnit});

  UnitPriceOverride.fromJson(Map<String, dynamic> json) {
    productId = json['product_id'] as int?;
    productName = json['product_name'] as String?;
    pricePerUnit = json['price_per_unit'] as num?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = productId;
    data['product_name'] = productName;
    data['price_per_unit'] = pricePerUnit;
    return data;
  }
}

class ClinicalProtocolPdf {
  String? name;
  String? url;

  ClinicalProtocolPdf({this.name, this.url});

  ClinicalProtocolPdf.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    url = json['url'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}

class Attachment {
  String? name;
  String? url;
  String? type;

  Attachment({this.name, this.url, this.type});

  Attachment.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    url = json['url'] as String?;
    type = json['type'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    data['type'] = type;
    return data;
  }
}

class NotificationModel {
  String? title;
  String? message;
  int? timing;
  String? timingUnit;
  String? type;

  NotificationModel({
    this.title,
    this.message,
    this.timing,
    this.timingUnit,
    this.type,
  });

  NotificationModel.fromJson(Map<String, dynamic> json) {
    title = json['title'] as String?;
    message = json['message'] as String?;
    timing = json['timing'] as int?;
    timingUnit = json['timing_unit'] as String?;
    type = json['type'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['message'] = message;
    data['timing'] = timing;
    data['timing_unit'] = timingUnit;
    data['type'] = type;
    return data;
  }
}

class Session {
  int? sessionNumber;
  List<FollowUp>? followUps;

  Session({this.sessionNumber, this.followUps});

  Session.fromJson(Map<String, dynamic> json) {
    sessionNumber = json['session_number'] as int?;
    if (json['follow_ups'] != null && json['follow_ups'] is List) {
      followUps = <FollowUp>[];
      for (final v in json['follow_ups'] as List) {
        if (v is Map<String, dynamic>) {
          followUps!.add(FollowUp.fromJson(v));
        }
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['session_number'] = sessionNumber;
    if (followUps != null) {
      data['follow_ups'] = followUps!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FollowUp {
  String? type;
  int? durationValue;
  String? durationUnit;
  int? intervalValue;
  String? intervalUnit;
  bool? isImageRequired;
  String? notes;

  FollowUp({
    this.type,
    this.durationValue,
    this.durationUnit,
    this.intervalValue,
    this.intervalUnit,
    this.isImageRequired,
    this.notes,
  });

  FollowUp.fromJson(Map<String, dynamic> json) {
    type = json['type'] as String?;
    durationValue = json['duration_value'] as int?;
    durationUnit = json['duration_unit'] as String?;
    intervalValue = json['interval_value'] as int?;
    intervalUnit = json['interval_unit'] as String?;
    isImageRequired = json['is_image_required'] as bool?;
    notes = json['notes'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['duration_value'] = durationValue;
    data['duration_unit'] = durationUnit;
    data['interval_value'] = intervalValue;
    data['interval_unit'] = intervalUnit;
    data['is_image_required'] = isImageRequired;
    data['notes'] = notes;
    return data;
  }
}

class ConsentForm {
  String? name;
  String? url;

  ConsentForm({this.name, this.url});

  ConsentForm.fromJson(Map<String, dynamic> json) {
    name = json['name'] as String?;
    url = json['url'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['url'] = url;
    return data;
  }
}
