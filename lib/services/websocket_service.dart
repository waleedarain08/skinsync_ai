import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:web_socket_client/web_socket_client.dart';

import '../exceptions/app_exception.dart';
import '../models/chat_treatment_request_model.dart';
import '../utils/enums.dart';
import '../utils/secure_storage_service.dart';
import 'api_base_helper.dart';

class WsEvent {
  final EventType type;
  final Map<String, dynamic> data;

  WsEvent({required this.type, required this.data});
}

/// Singleton service that manages a single websocket connection per app.
class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocket? _socket;
  StreamSubscription<dynamic>? _msgSub;
  StreamSubscription<dynamic>? _connSub;
  ValueSetter<WsEvent>? _savedOnEvent;
  bool _isRefreshingAndReconnecting = false;

  bool get isConnected => _socket != null;

  Future<void> connect({required ValueSetter<WsEvent> onEvent}) async {
    _savedOnEvent = onEvent;
    if (_socket != null) return;

    // Check & Refresh token before connecting if needed
    try {
      await ApiBaseHelper().refreshToken();
    } catch (e) {
      log('WebSocket pre-connect token check error: $e');
    }

    final token = await SecureStorage().getToken();
    final baseUrl = ApiBaseHelper().baseUrl;
    final socketUri = Uri.parse('${baseUrl}ws').replace(
      scheme: baseUrl.startsWith('https') ? 'wss' : 'ws',
      queryParameters: {'token': token},
    );

    log('WebSocket connecting to $socketUri');

    try {
      _socket = WebSocket(
        socketUri,
        headers: {'Authorization': 'Bearer $token'},
      );

      _msgSub = _socket!.messages.listen(
        (event) async {
          try {
            if (event is String) {
              final payload = jsonDecode(event) as Map<String, dynamic>;
              final typeStr = payload['event_type'] as String?;
              final eventType = EventType.fromValue(typeStr);
              final data = payload['data'] as Map<String, dynamic>? ?? payload;

              // Intercept token expiry / unauthorized error events
              if (eventType == EventType.error) {
                final errorMsg = (data['error'] as String? ?? '').toLowerCase();
                if (errorMsg.contains('unauthorized') ||
                    errorMsg.contains('expired') ||
                    errorMsg.contains('token')) {
                  log('WebSocket received token expiry event: $errorMsg');
                  await _refreshAndReconnect();
                  return;
                }
              }

              onEvent(WsEvent(type: eventType, data: data));
            }
          } catch (e, s) {
            log('WebSocket parse error: $e', stackTrace: s);
          }
        },
        onDone: () {
          _cleanupSocket();
        },
        onError: (error) async {
          log('WebSocket error: $error');
          final errorStr = error.toString().toLowerCase();
          if (errorStr.contains('401') ||
              errorStr.contains('unauthorized') ||
              errorStr.contains('expired') ||
              errorStr.contains('token')) {
            await _refreshAndReconnect();
          } else {
            _cleanupSocket();
          }
        },
      );

      _connSub = _socket!.connection.listen((connection) {
        log('WebSocket connection state: ${connection.runtimeType}');
        if (connection is Disconnecting) {
          _cleanupSocket();
        }
      });
    } catch (e, s) {
      log('WebSocket connect failed: $e', stackTrace: s);
      _cleanupSocket();
    }
  }

  Future<void> _refreshAndReconnect() async {
    if (_isRefreshingAndReconnecting) return;
    _isRefreshingAndReconnecting = true;
    log('WebSocket token expired. Running refresh token and reconnecting...');

    try {
      await _cleanupSocket();
      await ApiBaseHelper().refreshToken();
      final onEvent = _savedOnEvent;
      if (onEvent != null) {
        await connect(onEvent: onEvent);
      }
    } catch (e) {
      log('WebSocket refresh & reconnect failed: $e');
    } finally {
      _isRefreshingAndReconnecting = false;
    }
  }

  Future<void> sendMessage({
    required int chatId,
    required MessageType type,
    required String content,
    String? mediaUrl,
    String? documentUrl,
    ChatTreatmentRequestModel? treatmentRequest,
  }) async {
    if (_socket == null) {
      throw Exception('Websocket not connected');
    }
    String text = '';
    if (type == .sharedRequest) {
      if (treatmentRequest == null) {
        throw const AppException('TreatmentRequest is required!');
      }
      text = jsonEncode(treatmentRequest.copyWith(text: content).toJson());
    } else {
      text = content;
    }

    final payload = <String, dynamic>{
      'chat_id': chatId,
      'type': type.value,
      'content': text,
      if (type == MessageType.media) 'media_url': mediaUrl,
      if (type == MessageType.document) 'document_url': documentUrl,
    };
    _socket!.send(jsonEncode(payload));
  }

  Future<void> disconnect() async {
    await _cleanupSocket();
  }

  Future<void> _cleanupSocket() async {
    try {
      await _msgSub?.cancel();
      await _connSub?.cancel();
    } catch (_) {}
    try {
      _socket?.close();
    } catch (_) {}
    _socket = null;
    _msgSub = null;
    _connSub = null;
  }
}
