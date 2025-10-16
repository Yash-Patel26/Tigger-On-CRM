class FilterOptions {
  final String? search;
  final List<String>? status;
  final List<String>? assignedTo;
  final List<String>? createdBy;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? sortBy;
  final String? sortOrder;
  final Map<String, dynamic>? customFilters;

  const FilterOptions({
    this.search,
    this.status,
    this.assignedTo,
    this.createdBy,
    this.dateFrom,
    this.dateTo,
    this.sortBy,
    this.sortOrder,
    this.customFilters,
  });

  Map<String, dynamic> toJson() {
    return {
      'search': search,
      'status': status,
      'assigned_to': assignedTo,
      'created_by': createdBy,
      'date_from': dateFrom?.toIso8601String(),
      'date_to': dateTo?.toIso8601String(),
      'sort_by': sortBy,
      'sort_order': sortOrder,
      'custom_filters': customFilters,
    };
  }

  FilterOptions copyWith({
    String? search,
    List<String>? status,
    List<String>? assignedTo,
    List<String>? createdBy,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? sortBy,
    String? sortOrder,
    Map<String, dynamic>? customFilters,
  }) {
    return FilterOptions(
      search: search ?? this.search,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      customFilters: customFilters ?? this.customFilters,
    );
  }

  @override
  String toString() {
    return 'FilterOptions(search: $search, status: $status, sortBy: $sortBy)';
  }
}

class PaginationOptions {
  final int page;
  final int pageSize;
  final int? offset;
  final int? limit;

  const PaginationOptions({
    this.page = 1,
    this.pageSize = 20,
    this.offset,
    this.limit,
  });

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'offset': offset ?? ((page - 1) * pageSize),
      'limit': limit ?? pageSize,
    };
  }

  PaginationOptions copyWith({
    int? page,
    int? pageSize,
    int? offset,
    int? limit,
  }) {
    return PaginationOptions(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
    );
  }

  @override
  String toString() {
    return 'PaginationOptions(page: $page, pageSize: $pageSize)';
  }
}

class SortOptions {
  final String field;
  final SortOrder order;

  const SortOptions({required this.field, this.order = SortOrder.asc});

  Map<String, dynamic> toJson() {
    return {'field': field, 'order': order.name};
  }

  @override
  String toString() {
    return 'SortOptions(field: $field, order: $order)';
  }
}

enum SortOrder {
  asc,
  desc;

  String get displayName {
    switch (this) {
      case SortOrder.asc:
        return 'Ascending';
      case SortOrder.desc:
        return 'Descending';
    }
  }
}

class DateRange {
  final DateTime? start;
  final DateTime? end;

  const DateRange({this.start, this.end});

  Map<String, dynamic> toJson() {
    return {'start': start?.toIso8601String(), 'end': end?.toIso8601String()};
  }

  bool get isValid => start != null && end != null && !start!.isAfter(end!);

  Duration? get duration =>
      start != null && end != null ? end!.difference(start!) : null;

  @override
  String toString() {
    return 'DateRange(start: $start, end: $end)';
  }
}

class SearchOptions {
  final String query;
  final List<String>? fields;
  final bool caseSensitive;
  final bool exactMatch;

  const SearchOptions({
    required this.query,
    this.fields,
    this.caseSensitive = false,
    this.exactMatch = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'fields': fields,
      'case_sensitive': caseSensitive,
      'exact_match': exactMatch,
    };
  }

  @override
  String toString() {
    return 'SearchOptions(query: $query, fields: $fields)';
  }
}
