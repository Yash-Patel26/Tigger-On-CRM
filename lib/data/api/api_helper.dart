import 'dart:convert';
import 'dart:io' show SocketException;
import 'dart:async' show TimeoutException;

import 'package:http/http.dart' as http;

class ApiEndpoints {
  static const String baseUrl = 'https://api.example.com';

  // Example endpoints; customize per backend
  static const String leads = '/leads';
  static const String vendors = '/vendors';
  static String leadById(String id) => '/leads/$id';
}

class ApiHttpException implements Exception {
  ApiHttpException({
    required this.statusCode,
    required this.message,
    this.body,
  });

  final int statusCode;
  final String message;
  final String? body;

  @override
  String toString() =>
      'ApiHttpException('
      '$statusCode'
      '): '
      '$message';
}

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
    Duration? timeout,
    int? retryCount,
  }) : _http = httpClient ?? http.Client(),
       _baseUrl = baseUrl ?? ApiEndpoints.baseUrl,
       _timeout = timeout ?? const Duration(seconds: 20),
       _retryCount = retryCount ?? 2;

  final http.Client _http;
  final String _baseUrl;
  final Duration _timeout;
  final int _retryCount;
  String? _authToken;
  Future<String?> Function()? _refreshTokenCallback;
  Map<String, String> _extraDefaultHeaders = <String, String>{};
  Map<String, String> _defaultQuery = <String, String>{};

  Map<String, String> get _defaultHeaders => <String, String>{
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void setAuthToken(String? token) {
    _authToken = token;
  }

  void setRefreshTokenCallback(Future<String?> Function()? callback) {
    _refreshTokenCallback = callback;
  }

  void setDefaultHeaders(Map<String, String> headers) {
    _extraDefaultHeaders = Map<String, String>.from(headers);
  }

  void setDefaultQueryParams(Map<String, String> query) {
    _defaultQuery = Map<String, String>.from(query);
  }

  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    final Map<String, String> merged = <String, String>{
      ..._defaultHeaders,
      ..._extraDefaultHeaders,
      if (headers != null) ...headers,
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      merged.putIfAbsent('Authorization', () => 'Bearer $_authToken');
    }
    return merged;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? query]) {
    if (path.startsWith('http')) return Uri.parse(path);
    final Uri base = Uri.parse(_baseUrl);
    final String normalizedPath = _normalizePath(base.path, path);
    final Map<String, String> qp = <String, String>{
      ..._defaultQuery,
      if (query != null)
        ...query.map(
          (String k, dynamic v) => MapEntry<String, String>(k, '$v'),
        ),
    };
    return base.replace(
      path: normalizedPath,
      queryParameters: qp.isEmpty ? null : qp,
    );
  }

  String _normalizePath(String basePath, String appendPath) {
    final String a = basePath.endsWith('/')
        ? basePath.substring(0, basePath.length - 1)
        : basePath;
    final String b = appendPath.startsWith('/') ? appendPath : '/$appendPath';
    return a + b;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(path, query);
    return _authAware(
      () => _sendWithRetry(
        () => _http.get(uri, headers: _mergeHeaders(headers)).timeout(_timeout),
      ),
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(path);
    return _authAware(
      () => _sendWithRetry(
        () => _http
            .post(
              uri,
              headers: _mergeHeaders(headers),
              body: body is String
                  ? body
                  : jsonEncode(body ?? <String, dynamic>{}),
            )
            .timeout(_timeout),
      ),
    );
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(path);
    return _authAware(
      () => _sendWithRetry(
        () => _http
            .put(
              uri,
              headers: _mergeHeaders(headers),
              body: body is String
                  ? body
                  : jsonEncode(body ?? <String, dynamic>{}),
            )
            .timeout(_timeout),
      ),
    );
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(path);
    return _authAware(
      () => _sendWithRetry(
        () => _http
            .patch(
              uri,
              headers: _mergeHeaders(headers),
              body: body is String
                  ? body
                  : jsonEncode(body ?? <String, dynamic>{}),
            )
            .timeout(_timeout),
      ),
    );
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(path);
    return _authAware(
      () => _sendWithRetry(
        () => _http
            .delete(
              uri,
              headers: _mergeHeaders(headers),
              body: body == null
                  ? null
                  : (body is String ? body : jsonEncode(body)),
            )
            .timeout(_timeout),
      ),
    );
  }

  Future<Map<String, dynamic>> uploadMultipart(
    String path, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
    Map<String, String>? headers,
  }) async {
    final Uri uri = _buildUri(path);
    final http.MultipartRequest request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_mergeHeaders(headers)..remove('Content-Type'));
    if (fields != null) {
      request.fields.addAll(fields);
    }
    if (files != null) {
      request.files.addAll(files);
    }
    final http.StreamedResponse streamed = await request.send().timeout(
      _timeout,
    );
    final http.Response res = await http.Response.fromStream(streamed);
    return _handleResponse(res);
  }

  Future<Map<String, dynamic>> _authAware(
    Future<http.Response> Function() request,
  ) async {
    http.Response res = await request();
    if (res.statusCode == 401 && _refreshTokenCallback != null) {
      final String? newToken = await _refreshTokenCallback!.call();
      if (newToken != null && newToken.isNotEmpty) {
        _authToken = newToken;
        res = await request();
      }
    }
    return _handleResponse(res);
  }

  Future<http.Response> _sendWithRetry(
    Future<http.Response> Function() sender,
  ) async {
    Object? lastError;
    for (int attempt = 0; attempt <= _retryCount; attempt++) {
      try {
        return await sender();
      } on http.ClientException catch (e) {
        lastError = e;
      } on SocketException catch (e) {
        lastError = e;
      } on TimeoutException catch (e) {
        lastError = e;
      } catch (e) {
        lastError = e;
      }
      if (attempt < _retryCount) {
        final int delayMs = 400 * (1 << attempt);
        await Future<void>.delayed(Duration(milliseconds: delayMs));
        continue;
      }
      throw ApiHttpException(statusCode: 599, message: lastError.toString());
    }
    throw ApiHttpException(statusCode: 599, message: 'Network error');
  }

  Map<String, dynamic> _handleResponse(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return <String, dynamic>{};
      final dynamic decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return <String, dynamic>{'data': decoded};
    }
    throw ApiHttpException(
      statusCode: res.statusCode,
      message: _safeErrorMessage(res.body),
      body: res.body,
    );
  }

  String _safeErrorMessage(String body) {
    try {
      final dynamic decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final Object? messageValue = decoded['message'];
        return messageValue?.toString() ?? 'Request failed';
      }
      return decoded?.toString() ?? 'Request failed';
    } catch (_) {
      return 'Request failed';
    }
  }
}
