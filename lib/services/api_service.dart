import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode ?? 200,
    );
  }

  factory ApiResponse.error(
    String message, {
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode ?? 500,
      errors: errors,
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://api.tiggeron.com/v1';
  static const Duration timeout = Duration(seconds: 30);

  final http.Client _client;
  String? _authToken;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);

      final response = await _client
          .get(uri, headers: _headers)
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException catch (e) {
      return ApiResponse.error('HTTP error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException catch (e) {
      return ApiResponse.error('HTTP error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client
          .put(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException catch (e) {
      return ApiResponse.error('HTTP error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client
          .delete(uri, headers: _headers)
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException catch (e) {
      return ApiResponse.error('HTTP error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await _client
          .patch(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(timeout);

      return _handleResponse<T>(response, fromJson);
    } on SocketException {
      return ApiResponse.error('No internet connection');
    } on HttpException catch (e) {
      return ApiResponse.error('HTTP error: ${e.message}');
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      try {
        final jsonData = jsonDecode(body) as Map<String, dynamic>;

        if (fromJson != null) {
          final data = fromJson(jsonData);
          return ApiResponse.success(data, statusCode: statusCode);
        } else {
          return ApiResponse.success(jsonData as T, statusCode: statusCode);
        }
      } catch (e) {
        return ApiResponse.error(
          'Failed to parse response: $e',
          statusCode: statusCode,
        );
      }
    } else {
      try {
        final jsonData = jsonDecode(body) as Map<String, dynamic>;
        final message = jsonData['message'] as String? ?? 'Request failed';
        final errors = jsonData['errors'] as Map<String, dynamic>?;

        return ApiResponse.error(
          message,
          statusCode: statusCode,
          errors: errors,
        );
      } catch (e) {
        return ApiResponse.error(
          'Request failed with status $statusCode',
          statusCode: statusCode,
        );
      }
    }
  }

  void dispose() {
    _client.close();
  }

  // Supabase init is handled separately in SupabaseService.
}
