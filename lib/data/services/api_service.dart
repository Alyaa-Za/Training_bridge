import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../models/api_response.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(ApiConstants.tokenKey);

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResponse> post(String endpoint, Map<String, dynamic> body) async {
    final fullUrl = '${ApiConstants.baseUrl}$endpoint';

    print('═══════════════════════════════════');
    print('🚀 POST REQUEST');
    print('📍 URL: $fullUrl');
    print('📦 Body: ${jsonEncode(body)}');
    print('═══════════════════════════════════');

    try {
      final response = await http
          .post(
        Uri.parse(fullUrl),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Request timeout after 10 seconds');
        },
      );

      print('═══════════════════════════════════');
      print('✅ RESPONSE RECEIVED');
      print('📊 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      print('═══════════════════════════════════');

      return _handleResponse(response);

    } on SocketException catch (e) {
      print('═══════════════════════════════════');
      print('❌ SOCKET EXCEPTION (No Internet)');
      print('Error: $e');
      print('═══════════════════════════════════');

      return ApiResponse(
        success: false,
        message: 'No internet connection. Please check your network.',
        data: null,
      );

    } on TimeoutException catch (e) {
      print('═══════════════════════════════════');
      print('❌ TIMEOUT EXCEPTION');
      print('Error: $e');
      print('═══════════════════════════════════');

      return ApiResponse(
        success: false,
        message: 'Connection timeout. Server is not responding.',
        data: null,
      );

    } on FormatException catch (e) {
      print('═══════════════════════════════════');
      print('❌ FORMAT EXCEPTION');
      print('Error: $e');
      print('═══════════════════════════════════');

      return ApiResponse(
        success: false,
        message: 'Invalid response format from server.',
        data: null,
      );

    } catch (e) {
      print('═══════════════════════════════════');
      print('❌ GENERAL EXCEPTION');
      print('Error: $e');
      print('Error Type: ${e.runtimeType}');
      print('═══════════════════════════════════');

      return ApiResponse(
        success: false,
        message: 'Unexpected error: $e',
        data: null,
      );
    }
  }

  ApiResponse _handleResponse(http.Response response) {
    try {
      // محاولة تحويل الاستجابة إلى JSON
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      // التعامل مع API مختلفة
      // بعض APIs ترجع { success, message, data }
      // وبعضها يرجع { token } مباشرة

      if (responseData.containsKey('success')) {
        // نظام موحد مثل الذي صممته
        return ApiResponse(
          success: responseData['success'] ?? false,
          message: responseData['message'] ?? '',
          data: responseData['data'],
        );
      } else if (responseData.containsKey('token')) {
        // API مثل reqres.in
        return ApiResponse(
          success: true,
          message: 'Login successful',
          data: responseData,
        );
      } else if (response.statusCode >= 200 && response.statusCode < 300) {
        // أي استجابة ناجحة
        return ApiResponse(
          success: true,
          message: 'Success',
          data: responseData,
        );
      } else {
        // استجابة فاشلة
        return ApiResponse(
          success: false,
          message: responseData['error'] ?? responseData['message'] ?? 'Unknown error',
          data: null,
        );
      }

    } catch (e) {
      print('❌ Error parsing response: $e');

      return ApiResponse(
        success: false,
        message: 'Could not parse server response',
        data: null,
      );
    }
  }

  Future<ApiResponse> get(String endpoint) async {
    final fullUrl = '${ApiConstants.baseUrl}$endpoint';

    print('═══════════════════════════════════');
    print('🚀 GET REQUEST');
    print('📍 URL: $fullUrl');
    print('═══════════════════════════════════');

    try {
      final response = await http
          .get(
        Uri.parse(fullUrl),
        headers: await _getHeaders(),
      )
          .timeout(const Duration(seconds: 10));

      print('═══════════════════════════════════');
      print('✅ RESPONSE RECEIVED');
      print('📊 Status Code: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      print('═══════════════════════════════════');

      return _handleResponse(response);

    } on SocketException catch (e) {
      print('❌ No Internet Connection: $e');
      return ApiResponse(
        success: false,
        message: 'No internet connection',
        data: null,
      );
    } catch (e) {
      print('❌ Error: $e');
      return ApiResponse(
        success: false,
        message: 'Error: $e',
        data: null,
      );
    }
  }

  Future<ApiResponse> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: $e',
        data: null,
      );
    }
  }

  Future<ApiResponse> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: await _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error: $e',
        data: null,
      );
    }
  }

  Future<ApiResponse> uploadFile(
      String endpoint,
      String fieldName,
      String filePath,
      ) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
      );

      request.headers.addAll(await _getHeaders());
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error uploading file: $e',
        data: null,
      );
    }
  }
}