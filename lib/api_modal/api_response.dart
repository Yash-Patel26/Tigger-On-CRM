class ApiResponse<T> {
  ApiResponse({required this.success, this.message, this.data});

  final bool success;
  final String? message;
  final T? data;

  static ApiResponse<R> fromJson<R>(
    Map<String, dynamic> json, {
    R Function(Object? json)? decode,
  }) {
    final Object? rawData = json['data'];
    return ApiResponse<R>(
      success: (json['success'] as bool?) ?? true,
      message: json['message'] as String?,
      data: decode != null ? decode(rawData) : rawData as R?,
    );
  }

  Map<String, dynamic> toJson(Object? Function(T value)? encode) =>
      <String, dynamic>{
        'success': success,
        if (message != null) 'message': message,
        if (data != null) 'data': encode != null ? encode(data as T) : data,
      };
}

class PaginatedResponse<T> {
  PaginatedResponse({
    required this.items,
    this.total,
    this.page,
    this.pageSize,
  });

  final List<T> items;
  final int? total;
  final int? page;
  final int? pageSize;

  static PaginatedResponse<R> fromJson<R>(
    Map<String, dynamic> json, {
    required R Function(Map<String, dynamic> json) itemFromJson,
  }) {
    final List<dynamic> raw = (json['items'] as List<dynamic>? ?? <dynamic>[]);
    return PaginatedResponse<R>(
      items: raw
          .whereType<Map<String, dynamic>>()
          .map<R>(itemFromJson)
          .toList(growable: false),
      total: json['total'] as int?,
      page: json['page'] as int?,
      pageSize: json['pageSize'] as int?,
    );
  }

  Map<String, dynamic> toJson(Object Function(T item) itemToJson) =>
      <String, dynamic>{
        'items': items.map<Object>(itemToJson).toList(growable: false),
        if (total != null) 'total': total,
        if (page != null) 'page': page,
        if (pageSize != null) 'pageSize': pageSize,
      };
}
