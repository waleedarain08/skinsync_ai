import 'dart:convert';

import '../../utils/enums.dart';
import '../chat_treatment_request_model.dart';
import 'appointment_detail_response.dart';
import 'base_response_model.dart';
import 'get_clinic_response.dart';

class MessagesResponse extends BaseResponseModel {
  final MessagesData? data;
  MessagesResponse({super.isSuccess, super.message, this.data});

  factory MessagesResponse.fromJson(Map<String, dynamic> json) =>
      MessagesResponse(
        isSuccess: json["is_success"],
        message: json["message"],
        data: json["data"] == null ? null : MessagesData.fromJson(json["data"]),
      );
}

class MessagesData {
  final List<Message>? messages;
  final ChatUser? user;
  final Clinic? clinic;
  final int? page;
  final int? limit;
  final int? total;
  final int? totalPages;

  MessagesData({
    this.messages,
    this.user,
    this.clinic,
    this.page,
    this.limit,
    this.total,
    this.totalPages,
  });

  factory MessagesData.fromJson(Map<String, dynamic> json) => MessagesData(
    messages: json["messages"] == null
        ? []
        : List<Message>.from(json["messages"]!.map((x) => Message.fromJson(x))),
    user: json["user"] == null ? null : ChatUser.fromJson(json["user"]),
    clinic: json['clinic'] == null ? null : Clinic.fromJson(json['clinic']),
    page: json["page"],
    limit: json["limit"],
    total: json["total"],
    totalPages: json["total_pages"],
  );

  MessagesData copyWith({
    List<Message>? messages,
    ChatUser? user,
    Clinic? clinic,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
  }) {
    return MessagesData(
      messages: messages ?? this.messages,
      user: user ?? this.user,
      clinic: clinic ?? this.clinic,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class Message {
  final int? id;
  final int? chatId;
  final MessageType? type;
  final String? senderType;
  final int? senderId;
  final String? senderName;
  final String? content;
  final bool isRead;
  final String? mediaUrl;
  final String? documentUrl;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Message({
    this.id,
    this.chatId,
    this.type,
    this.senderType,
    this.senderId,
    this.senderName,
    this.content,
    this.isRead = false,
    this.mediaUrl,
    this.documentUrl,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    chatId: json['chat_id'],
    type: MessageType.fromValue(json["type"]),
    senderType: json["sender_type"],
    senderId: json["sender_id"],
    senderName: json["sender_name"],
    content: json["content"],
    isRead: json["is_read"],
    mediaUrl: json["media_url"],
    documentUrl: json["document_url"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Message copyWith({
    int? id,
    int? chatId,
    MessageType? type,
    String? senderType,
    int? senderId,
    String? senderName,
    String? content,
    bool? isRead,
    String? mediaUrl,
    String? documentUrl,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      type: type ?? this.type,
      senderType: senderType ?? this.senderType,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      documentUrl: documentUrl ?? this.documentUrl,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isMe {
    return userId == senderId;
  }

  ChatTreatmentRequestModel? get sharedRequestData {
    try {
      if (type != MessageType.sharedRequest) {
        return null;
      }
      if (content == null) {
        return null;
      }
      return ChatTreatmentRequestModel.fromJson(jsonDecode(content!));
    } catch (_) {
      return null;
    }
  }

  AppointmentDetailData? get appointmentData {
    try {
      if (type != MessageType.appointment) {
        return null;
      }
      if (content == null) {
        return null;
      }
      return AppointmentDetailData.fromJson(jsonDecode(content!));
    } catch (_) {
      return null;
    }
  }

  SessionCompletionData? get sessionCompletionData {
    try {
      if (content == null || content!.isEmpty) {
        return null;
      }
      final trimmed = content!.trim();
      return SessionCompletionData.fromJson(jsonDecode(trimmed));
    } catch (e) {
      return null;
    }
  }
}

class ChatUser {
  final int? userProfileId;
  final int? userId;
  final String? name;
  final String? phoneNumber;
  final String? emailAddress;
  final String? location;
  final String? bio;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChatUser({
    this.userProfileId,
    this.userId,
    this.name,
    this.phoneNumber,
    this.emailAddress,
    this.location,
    this.bio,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) => ChatUser(
    userProfileId: json["user_profile_id"],
    userId: json["user_id"],
    name: json["name"],
    phoneNumber: json["phone_number"],
    emailAddress: json["email_address"],
    location: json["location"],
    bio: json["bio"],
    profileImageUrl: json["profile_image_url"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );
}

class SessionCompletionData {
  final int? appointmentId;
  final String? appointmentKey;
  final String? doctorName;
  final String? treatmentName;
  final String? areaName;
  final String? duration;
  final String? notes;

  SessionCompletionData({
    this.appointmentId,
    this.appointmentKey,
    this.doctorName,
    this.treatmentName,
    this.areaName,
    this.duration,
    this.notes,
  });

  factory SessionCompletionData.fromJson(Map<String, dynamic> json) {
    return SessionCompletionData(
      appointmentId: json['appointment_id'] as int? ?? json['id'] as int?,
      appointmentKey: json['appointment_key'] as String? ?? json['appointmentKey'] as String?,
      doctorName: json['doctor_name'] as String?,
      treatmentName: json['treatment_name'] as String?,
      areaName: json['area_name'] as String?,
      duration: json['duration'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment_id': appointmentId,
      'appointment_key': appointmentKey,
      'doctor_name': doctorName,
      'treatment_name': treatmentName,
      'area_name': areaName,
      'duration': duration,
      'notes': notes,
    };
  }
}