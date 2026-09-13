import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../app_init.dart';
import '../exceptions/app_exception.dart';
import '../main.dart';
import '../models/responses/refresh_token_response.dart';
import '../screens/get_started_screen.dart';
import '../utils/enums.dart';
import '../utils/secure_storage_service.dart';

class ApiBaseHelper {
  final SecureStorage _secureStorage = SecureStorage();
  final baseUrl = isDeploymentMode ? BaseUrls.api.url : BaseUrls.apiQa.url;

  Future<http.Response> httpRequest({
    required EndPoints endPoint,
    required RequestType requestType,
    requestBody,
    String? params,
    String? imagePath,
  }) async {
    try {
      final url = '$baseUrl${endPoint.path}${params ?? ''}';
      log('URL: $url');
      log('BODY: $requestBody');
      await refreshToken();
      final headers = await getHeaders();
      switch (requestType) {
        case .get:
          if (requestBody != null) {
            final request = http.Request(requestType.method, Uri.parse(url));
            request.headers.addAll(headers);
            request.body = jsonEncode(requestBody);
            final response = await http.Client().send(request);
            final responseJson = await http.Response.fromStream(response);
            log('RESPONSE: ${responseJson.body}');
            return responseJson;
          }
          final responseJson = await http.get(Uri.parse(url), headers: headers);
          log('RESPONSE: ${responseJson.body}');
          return responseJson;
        case .post:
          final responseJson = await http.post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(requestBody),
          );
          log('RESPONSE: ${responseJson.body}');
          return responseJson;
        case .put:
          return await http.put(
            Uri.parse(url),
            headers: headers,
            body: requestBody != '' ? jsonEncode(requestBody) : null,
          );
        case .patch:
          final responseJson = await http.patch(
            Uri.parse(url),
            headers: headers,
            body: requestBody != '' ? jsonEncode(requestBody) : null,
          );
          log('RESPONSE: ${responseJson.body}');
          return responseJson;
        case .delete:
          final responseJson = await http.delete(
            Uri.parse(url),
            headers: headers,
            body: requestBody != '' ? jsonEncode(requestBody) : null,
          );
          return responseJson;
        case .multipartPost:
          final request = http.MultipartRequest(
            requestType.method,
            Uri.parse(url),
          );
          request.fields.addAll(requestBody!.toJson());
          request.files.add(
            await http.MultipartFile.fromPath('image', imagePath!),
          );
          request.headers.addAll(headers);
          final responseJson = await request.send();
          return await http.Response.fromStream(responseJson);
        case .multipartPatch:
          final request = http.MultipartRequest(
            requestType.method,
            Uri.parse(url),
          );
          request.fields.addAll(requestBody!.toJson());
          request.files.add(
            await http.MultipartFile.fromPath('image', imagePath!),
          );
          request.headers.addAll(headers);
          final responseJson = await request.send();
          return await http.Response.fromStream(responseJson);
      }
    } on SocketException {
      throw const AppException('No Internet Connection');
    } on HttpException {
      throw const AppException('No Internet Connection');
    } on FormatException {
      throw 'Invalid Format';
    } on TimeoutException {
      throw 'Request TimeOut';
    } catch (e) {
      if (e.toString().contains('Unauthorized')) {
        await _secureStorage.clearAllSecureStrings();
        Navigator.pushNamedAndRemoveUntil(
          navigatorKey.currentContext!,
          GetStartedScreen.routeName,
          (_) => false,
        );
      }
      throw e.toString();
    }
  }

  Future<Map<String, String>> getHeaders() async {
    final authToken = await _secureStorage.getToken();
    log("Auth token $authToken");
    Map<String, String> headers = {};
    headers.putIfAbsent('Content-Type', () => 'application/json');
    headers.putIfAbsent('Accept', () => 'application/json');
    headers.putIfAbsent('Authorization', () => 'Bearer ${authToken ?? ''}');
    return headers;
  }

  Future<void> refreshToken() async {
    final token = await _secureStorage.getToken();
    if (token == null) {
      log('TOKEN IS NULL');
      return;
    }
    final expiry = await _secureStorage.getAccessTokenExpiry();
    final now = DateTime.now();
    if (expiry?.isAfter(now) ?? false) {
      log('TOKEN IS NOT EXPIRED');
      return;
    }
    final refreshExpiry = await _secureStorage.getRefreshTokenExpiry();
    if (refreshExpiry?.isBefore(now) ?? true) {
      log('REFRESH TOKEN IS EXPIRED');
      throw Exception('Unauthorized');
    }
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) {
      log('REFRESH TOKEN IS NULL');
      throw Exception('Unauthorized');
    }
    log('EXPIRY: $expiry');
    log('REFRESH EXPIRY: $refreshExpiry');
    log('ACCESS TOKEN: $token');
    final baseUrl = isDeploymentMode ? BaseUrls.api.url : BaseUrls.apiQa.url;
    final uri = Uri.parse('$baseUrl${EndPoints.refreshToken.path}');
    log('URL: $uri');
    final request = {'refresh_token': refreshToken};
    log('REQUEST: $request');
    final json = await http.post(
      uri,
      headers: {'Authorization': 'Bearer $token'},
      body: jsonEncode(request),
    );
    log('RESPONSE: ${json.body}');
    final response = RefreshTokenResponse.fromJson(jsonDecode(json.body));
    if (!(response.status ?? false)) {
      throw Exception('Unauthorized');
    }
    await _secureStorage.saveToken(response.data!.accessToken!);
    await _secureStorage.saveRefreshToken(response.data!.refreshToken!);
    await _secureStorage.saveAccessTokenExpiry(
      DateTime.fromMillisecondsSinceEpoch(
        response.data!.isActiveExpiry! * 1000,
      ),
    );
    await _secureStorage.saveRefreshTokenExpiry(
      DateTime.fromMillisecondsSinceEpoch(
        response.data!.refreshTokenExpiry! * 1000,
      ),
    );
    log('TOKEN REFRESHED');
  }
}
