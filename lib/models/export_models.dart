enum ExportFormat {
  csv,
  excel,
  pdf,
  json;

  String get displayName {
    switch (this) {
      case ExportFormat.csv:
        return 'CSV';
      case ExportFormat.excel:
        return 'Excel';
      case ExportFormat.pdf:
        return 'PDF';
      case ExportFormat.json:
        return 'JSON';
    }
  }

  String get fileExtension {
    switch (this) {
      case ExportFormat.csv:
        return '.csv';
      case ExportFormat.excel:
        return '.xlsx';
      case ExportFormat.pdf:
        return '.pdf';
      case ExportFormat.json:
        return '.json';
    }
  }
}

enum ExportStatus {
  pending,
  processing,
  completed,
  failed;

  String get displayName {
    switch (this) {
      case ExportStatus.pending:
        return 'Pending';
      case ExportStatus.processing:
        return 'Processing';
      case ExportStatus.completed:
        return 'Completed';
      case ExportStatus.failed:
        return 'Failed';
    }
  }
}

class ExportRequest {
  final String entityType; // leads, customers, bookings, etc.
  final ExportFormat format;
  final Map<String, dynamic>? filters;
  final List<String>? fields;
  final String? fileName;
  final Map<String, dynamic>? options;

  const ExportRequest({
    required this.entityType,
    required this.format,
    this.filters,
    this.fields,
    this.fileName,
    this.options,
  });

  Map<String, dynamic> toJson() {
    return {
      'entity_type': entityType,
      'format': format.name,
      'filters': filters,
      'fields': fields,
      'file_name': fileName,
      'options': options,
    };
  }

  @override
  String toString() {
    return 'ExportRequest(entityType: $entityType, format: $format)';
  }
}

class ExportJob {
  final String id;
  final String entityType;
  final ExportFormat format;
  final ExportStatus status;
  final String? fileName;
  final String? downloadUrl;
  final String? error;
  final int? totalRecords;
  final int? processedRecords;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String createdBy;
  final Map<String, dynamic>? metadata;

  const ExportJob({
    required this.id,
    required this.entityType,
    required this.format,
    required this.status,
    this.fileName,
    this.downloadUrl,
    this.error,
    this.totalRecords,
    this.processedRecords,
    required this.createdAt,
    this.completedAt,
    required this.createdBy,
    this.metadata,
  });

  factory ExportJob.fromJson(Map<String, dynamic> json) {
    return ExportJob(
      id: json['id'] as String,
      entityType: json['entity_type'] as String,
      format: ExportFormat.values.firstWhere(
        (e) => e.name == json['format'],
        orElse: () => ExportFormat.csv,
      ),
      status: ExportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ExportStatus.pending,
      ),
      fileName: json['file_name'] as String?,
      downloadUrl: json['download_url'] as String?,
      error: json['error'] as String?,
      totalRecords: json['total_records'] as int?,
      processedRecords: json['processed_records'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      createdBy: json['created_by'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entity_type': entityType,
      'format': format.name,
      'status': status.name,
      'file_name': fileName,
      'download_url': downloadUrl,
      'error': error,
      'total_records': totalRecords,
      'processed_records': processedRecords,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_by': createdBy,
      'metadata': metadata,
    };
  }

  double get progress {
    if (totalRecords == null || totalRecords == 0) return 0.0;
    return (processedRecords ?? 0) / totalRecords!;
  }

  bool get isCompleted => status == ExportStatus.completed;
  bool get isFailed => status == ExportStatus.failed;
  bool get isProcessing => status == ExportStatus.processing;

  @override
  String toString() {
    return 'ExportJob(id: $id, entityType: $entityType, status: $status)';
  }
}

class ImportRequest {
  final String entityType;
  final String filePath;
  final String fileName;
  final Map<String, String>? fieldMapping;
  final bool skipFirstRow;
  final Map<String, dynamic>? options;

  const ImportRequest({
    required this.entityType,
    required this.filePath,
    required this.fileName,
    this.fieldMapping,
    this.skipFirstRow = true,
    this.options,
  });

  Map<String, dynamic> toJson() {
    return {
      'entity_type': entityType,
      'file_path': filePath,
      'file_name': fileName,
      'field_mapping': fieldMapping,
      'skip_first_row': skipFirstRow,
      'options': options,
    };
  }

  @override
  String toString() {
    return 'ImportRequest(entityType: $entityType, fileName: $fileName)';
  }
}

class ImportResult {
  final int totalRows;
  final int successCount;
  final int errorCount;
  final List<String> errors;
  final List<Map<String, dynamic>>? failedRows;
  final DateTime completedAt;

  const ImportResult({
    required this.totalRows,
    required this.successCount,
    required this.errorCount,
    required this.errors,
    this.failedRows,
    required this.completedAt,
  });

  factory ImportResult.fromJson(Map<String, dynamic> json) {
    return ImportResult(
      totalRows: json['total_rows'] as int,
      successCount: json['success_count'] as int,
      errorCount: json['error_count'] as int,
      errors: (json['errors'] as List<dynamic>).cast<String>(),
      failedRows: json['failed_rows'] as List<Map<String, dynamic>>?,
      completedAt: DateTime.parse(json['completed_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_rows': totalRows,
      'success_count': successCount,
      'error_count': errorCount,
      'errors': errors,
      'failed_rows': failedRows,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  double get successRate => totalRows > 0 ? successCount / totalRows : 0.0;
  bool get hasErrors => errorCount > 0;

  @override
  String toString() {
    return 'ImportResult(totalRows: $totalRows, successCount: $successCount, errorCount: $errorCount)';
  }
}
