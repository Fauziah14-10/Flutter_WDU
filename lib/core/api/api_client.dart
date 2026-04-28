import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../constants/endpoints.dart';
import '../utils/storage.dart';
import '../utils/logger.dart';

// ── RESPONSE WRAPPER ──────────────────────────────────────────
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;

  const ApiResponse({
    required this.success,
    required this.statusCode,
    this.data,
    this.message,
  });
}

// ── CUSTOM EXCEPTIONS ─────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException()
    : super('Sesi habis, silakan login kembali', statusCode: 401);
}

class NetworkException extends ApiException {
  NetworkException() : super('Tidak ada koneksi internet');
}

class ServerException extends ApiException {
  ServerException(String message) : super(message, statusCode: 500);
}

// ── API CLIENT ────────────────────────────────────────────────
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _client = http.Client();

  // ── TIMEOUT DURATION ──
  static const Duration _timeout = Duration(seconds: 30);

  // ── BUILD HEADERS ──────────────────────────────────────────
  Future<Map<String, String>> _buildHeaders({bool requireAuth = true}) async {
    String platform = 'Unknown';
    if (kIsWeb) {
      platform = 'Web';
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          platform = 'Android';
          break;
        case TargetPlatform.iOS:
          platform = 'iOS';
          break;
        case TargetPlatform.windows:
          platform = 'Windows';
          break;
        default:
          platform = 'Unknown';
      }
    }
    
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'WDU-Flutter-App/$platform',
      'X-App-Source': 'WDU-Flutter-App',
      'X-App-Platform': platform,
    };

    if (requireAuth) {
      final token = await StorageHelper.getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // ── LOG REQUEST (hanya di debug mode) ──────────────────────
  void _logRequest(String method, String url) {
    if (kDebugMode) {
      debugPrint('🚀 [API] $method $url');
    }
  }

  // ── HANDLE RESPONSE ────────────────────────────────────────
  ApiResponse<Map<String, dynamic>> _handleResponse(http.Response response) {
    Map<String, dynamic> body = {};
    try {
      final String trimmedBody = response.body.trim();
      if (trimmedBody.isNotEmpty) {
        final decoded = jsonDecode(trimmedBody);
        if (decoded is Map<String, dynamic>) {
          body = decoded;
        } else {
          body = {'data': decoded};
        }
      }
    } catch (e, st) {
      AppLogger.error(
        'API DECODE ERROR - Status: ${response.statusCode}, URL: ${response.request?.url}',
        error: e,
        stackTrace: st,
        category: 'API',
      );
      throw ServerException(
        'Gagal memproses data server (Error ${response.statusCode}).',
      );
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return ApiResponse(
          success: true,
          statusCode: response.statusCode,
          data: body,
          message: body['message'] as String?,
        );

      case 401:
        throw UnauthorizedException();

      case 422:
        // Validation error dari Laravel
        final errors = body['errors'];
        final msg = errors != null
            ? (errors as Map).values.first[0].toString()
            : body['message'] ?? 'Validasi gagal';
        throw ApiException(msg, statusCode: 422);

      case 404:
        throw ApiException(
          'Data atau Endpoint tidak ditemukan (404)',
          statusCode: 404,
        );

      case 500:
        throw ServerException(
          body['message'] ?? 'Terjadi kesalahan internal server (500)',
        );

      default:
        throw ApiException(
          body['message'] ?? 'Terjadi kesalahan sistem',
          statusCode: response.statusCode,
        );
    }
  }

  // ── VALIDATE TOKEN BEFORE REQUEST ────────────────────────────
  Future<void> _validateToken() async {
    final token = await StorageHelper.getToken();
    if (token == null || token.isEmpty) {
      throw UnauthorizedException();
    }
  }

  // ── GET ────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> get(
    String endpoint, {
    bool requireAuth = true,
    Map<String, String>? queryParams,
  }) async {
    // Validate token first if auth required
    if (requireAuth) {
      await _validateToken();
    }

    try {
      var uri = Uri.parse('${Endpoints.baseUrl}$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      _logRequest('GET', uri.toString());
      final headers = await _buildHeaders(requireAuth: requireAuth);
      final response = await _client
          .get(uri, headers: headers)
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException catch (e, st) {
      AppLogger.error(
        'SocketException pada GET $endpoint',
        error: e,
        stackTrace: st,
        category: 'API',
      );
      throw ApiException(
        'Tidak dapat terhubung ke server.',
        statusCode: 0,
      );
    } on TimeoutException catch (e, st) {
      AppLogger.error(
        'TimeoutException pada GET $endpoint',
        error: e,
        stackTrace: st,
        category: 'API',
      );
      throw ApiException(
        'Koneksi ke server timeout.',
        statusCode: 408,
      );
    } on HttpException catch (e, st) {
      AppLogger.error(
        'HttpException pada GET $endpoint',
        error: e,
        stackTrace: st,
        category: 'API',
      );
      throw NetworkException();
    } catch (e, st) {
      AppLogger.error(
        'Unexpected error pada GET $endpoint',
        error: 'Type: ${e.runtimeType}, Message: $e',
        stackTrace: st,
        category: 'API',
      );
      rethrow;
    }
  }

  // ── POST ───────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requireAuth = true,
  }) async {
    // Validate token first if auth required
    if (requireAuth) {
      await _validateToken();
    }

    try {
      final uri = Uri.parse('${Endpoints.baseUrl}$endpoint');
      _logRequest('POST', uri.toString());
      final encodedBody = jsonEncode(body);

      final headers = await _buildHeaders(requireAuth: requireAuth);
      final response = await _client
          .post(uri, headers: headers, body: encodedBody)
          .timeout(_timeout);

      return _handleResponse(response);
    } on SocketException catch (e, st) {
      AppLogger.error(
        'SocketException pada POST $endpoint',
        error: e,
        stackTrace: st,
        category: 'API',
      );
      throw ApiException(
        'Tidak dapat terhubung ke server.',
        statusCode: 0,
      );
    } on TimeoutException catch (e, st) {
      AppLogger.error(
        'TimeoutException pada POST $endpoint',
        error: e,
        stackTrace: st,
        category: 'API',
      );
      throw ApiException(
        'Koneksi ke server timeout.',
        statusCode: 408,
      );
    } catch (e, st) {
      AppLogger.error(
        'Unexpected error pada POST $endpoint',
        error: e,
        stackTrace: st,
        category: 'API',
      );
      rethrow;
    }
  }

  // ── PUT ────────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> put(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requireAuth = true,
  }) async {
    // Validate token first if auth required
    if (requireAuth) {
      await _validateToken();
    }

    try {
      final uri = Uri.parse('${Endpoints.baseUrl}$endpoint');
      _logRequest('PUT', uri.toString());
      final encodedBody = jsonEncode(body);

      final headers = await _buildHeaders(requireAuth: requireAuth);
      final response = await _client
          .put(uri, headers: headers, body: encodedBody)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e, st) {
      AppLogger.error(
        'Error pada PUT $endpoint',
        error: e,
        stackTrace: st,
        category: 'API',
      );
      rethrow;
    }
  }

  // ── PATCH ──────────────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> patch(
    String endpoint, {
    required Map<String, dynamic> body,
    bool requireAuth = true,
  }) async {
    // Validate token first if auth required
    if (requireAuth) {
      await _validateToken();
    }

    try {
      final uri = Uri.parse('${Endpoints.baseUrl}$endpoint');
      _logRequest('PATCH', uri.toString());
      final encodedBody = jsonEncode(body);

      final headers = await _buildHeaders(requireAuth: requireAuth);
      final response = await _client
          .patch(uri, headers: headers, body: encodedBody)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e, st) {
      AppLogger.error(
        'Error pada PATCH $endpoint',
        error: e,
        stackTrace: st,
        category: 'API',
      );
      rethrow;
    }
  }

  // ── POST WITH MULTIPLE FILES ─────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> postWithMultipleFiles(
    String endpoint, {
    required List<Map<String, dynamic>> files,
    Map<String, String>? additionalFields,
    bool requireAuth = true,
  }) async {
    if (requireAuth) {
      await _validateToken();
    }

    try {
      final uri = Uri.parse('${Endpoints.baseUrl}$endpoint');
      _logRequest('POST (Multipart)', uri.toString());
      final request = http.MultipartRequest('POST', uri);

      final headers = await _buildHeaders(requireAuth: requireAuth);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      for (var fileInfo in files) {
        final fieldName = fileInfo['fieldName'];
        final filePath = fileInfo['filePath'];
        final fileName = fileInfo['fileName'];
        final fileBytes = fileInfo['bytes'] as Uint8List?;

        if (fieldName != null) {
          if (kIsWeb && fileBytes != null) {
            request.files.add(http.MultipartFile.fromBytes(
              fieldName,
              fileBytes,
              filename: fileName ?? 'upload.file',
            ));
          } else if (!kIsWeb && filePath != null && filePath.isNotEmpty) {
            final file = File(filePath);
            if (await file.exists()) {
              request.files.add(await http.MultipartFile.fromPath(
                fieldName,
                filePath,
              ));
            }
          }
        }
      }

      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(const Duration(minutes: 2));
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e, st) {
      AppLogger.error(
        'Error pada POST with files $endpoint',
        error: e,
        stackTrace: st,
        category: 'API',
      );
      rethrow;
    }
  }

  // ── POST WITH FILE UPLOAD ────────────────────────────────────────
  Future<ApiResponse<Map<String, dynamic>>> postWithFile(
    String endpoint, {
    required String filePath,
    required String fieldName,
    List<int>? bytes, // Add bytes for Web support
    Map<String, String>? additionalFields,
    bool requireAuth = true,
  }) async {
    if (requireAuth) {
      await _validateToken();
    }

    try {
      final uri = Uri.parse('${Endpoints.baseUrl}$endpoint');
      _logRequest('POST (Multipart-Single)', uri.toString());
      final request = http.MultipartRequest('POST', uri);

      final headers = await _buildHeaders(requireAuth: requireAuth);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      if (kIsWeb && bytes != null) {
        // Use bytes for Web
        request.files.add(http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: filePath.split('/').last,
        ));
      } else {
        // Use path for Mobile
        request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));
      }

      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send().timeout(const Duration(minutes: 2));
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e, st) {
      AppLogger.error(
        'Error pada POST with file $endpoint',
        error: e,
        stackTrace: st,
        category: 'API',
      );
      rethrow;
    }
  }

  // ── DELETE ─────────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> delete(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    // Validate token first if auth required
    if (requireAuth) {
      await _validateToken();
    }

    try {
      final uri = Uri.parse('${Endpoints.baseUrl}$endpoint');
      _logRequest('DELETE', uri.toString());

      final headers = await _buildHeaders(requireAuth: requireAuth);
      final response = await _client
          .delete(uri, headers: headers)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e, st) {
      AppLogger.error(
        'Error pada DELETE $endpoint',
        error: e,
        stackTrace: st,
        category: 'API',
      );
      rethrow;
    }
  }

  // ── DISPOSE ────────────────────────────────────────────────
  void dispose() => _client.close();
}
