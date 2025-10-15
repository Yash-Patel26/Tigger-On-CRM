// No Flutter imports needed for this model

class CallEntry {
  CallEntry({
    required this.id,
    required this.displayName,
    required this.phoneNumber,
    required this.maskedNumber,
    required this.startedAt,
    this.endedAt,
    this.recordingFilePath,
    this.notes,
  });

  final String id;
  final String displayName;
  final String phoneNumber;
  final String maskedNumber;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? recordingFilePath;
  final String? notes;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'displayName': displayName,
    'phoneNumber': phoneNumber,
    'maskedNumber': maskedNumber,
    'startedAt': startedAt.toIso8601String(),
    'endedAt': endedAt?.toIso8601String(),
    'recordingFilePath': recordingFilePath,
    'notes': notes,
  };

  factory CallEntry.fromJson(Map<String, dynamic> json) => CallEntry(
    id: json['id'] as String,
    displayName: json['displayName'] as String,
    phoneNumber: json['phoneNumber'] as String,
    maskedNumber: json['maskedNumber'] as String,
    startedAt: DateTime.parse(json['startedAt'] as String),
    endedAt: json['endedAt'] != null
        ? DateTime.parse(json['endedAt'] as String)
        : null,
    recordingFilePath: json['recordingFilePath'] as String?,
    notes: json['notes'] as String?,
  );
}

String maskPhone(String number) {
  // Default policy fallback; DialerScreen should use MaskingPolicyService
  final String digits = number.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length <= 4) return digits;
  final String prefix = digits.substring(0, 2);
  final String suffix = digits.substring(digits.length - 2);
  final String middle = List<String>.filled(digits.length - 4, '•').join();
  return '$prefix$middle$suffix';
}
