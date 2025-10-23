enum BookingStatus { pending, confirmed, cancelled, completed }

enum PaymentMode { cash, cheque, online, bankTransfer, upi, other }

class Booking {
  final String id;
  final String srNo; // Serial number like BK001
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String leadId;
  final String projectId;
  final String projectName;
  final String propertyType;
  final String category;
  final String unitNo;
  final String unitDetails;
  final double bookingAmount;
  final double? advanceAmount;
  final double? balanceAmount;
  final PaymentMode paymentMode;
  final String? paymentReference;
  final String salesExecutiveId;
  final String salesExecutiveName;
  final double commission;
  final String approvedBy;
  final String? approvedById;
  final DateTime? approvedAt;
  final BookingStatus status;
  final DateTime bookingDate;
  final DateTime? possessionDate;
  final String? notes;
  final String? termsAndConditions;
  final List<String>? documents;
  final String createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? customFields;

  const Booking({
    required this.id,
    required this.srNo,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.leadId,
    required this.projectId,
    required this.projectName,
    required this.propertyType,
    required this.category,
    required this.unitNo,
    required this.unitDetails,
    required this.bookingAmount,
    this.advanceAmount,
    this.balanceAmount,
    required this.paymentMode,
    this.paymentReference,
    required this.salesExecutiveId,
    required this.salesExecutiveName,
    required this.commission,
    required this.approvedBy,
    this.approvedById,
    this.approvedAt,
    required this.status,
    required this.bookingDate,
    this.possessionDate,
    this.notes,
    this.termsAndConditions,
    this.documents,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
    this.customFields,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      srNo: json['srNo'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerEmail: json['customerEmail'] as String,
      customerPhone: json['customerPhone'] as String,
      leadId: json['leadId'] as String,
      projectId: json['projectId'] as String,
      projectName: json['projectName'] as String,
      propertyType: json['propertyType'] as String,
      category: json['category'] as String,
      unitNo: json['unitNo'] as String,
      unitDetails: json['unitDetails'] as String,
      bookingAmount: (json['bookingAmount'] as num).toDouble(),
      advanceAmount: json['advanceAmount'] != null
          ? (json['advanceAmount'] as num).toDouble()
          : null,
      balanceAmount: json['balanceAmount'] != null
          ? (json['balanceAmount'] as num).toDouble()
          : null,
      paymentMode: PaymentMode.values.firstWhere(
        (e) => e.name == json['paymentMode'],
        orElse: () => PaymentMode.cash,
      ),
      paymentReference: json['paymentReference'] as String?,
      salesExecutiveId: json['salesExecutiveId'] as String,
      salesExecutiveName: json['salesExecutiveName'] as String,
      commission: (json['commission'] as num).toDouble(),
      approvedBy: json['approvedBy'] as String,
      approvedById: json['approvedById'] as String?,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.pending,
      ),
      bookingDate: DateTime.parse(json['bookingDate'] as String),
      possessionDate: json['possessionDate'] != null
          ? DateTime.parse(json['possessionDate'] as String)
          : null,
      notes: json['notes'] as String?,
      termsAndConditions: json['termsAndConditions'] as String?,
      documents: json['documents'] != null
          ? List<String>.from(json['documents'] as List)
          : null,
      createdBy: json['createdBy'] as String,
      createdByName: json['createdByName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      customFields: json['customFields'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'srNo': srNo,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'leadId': leadId,
      'projectId': projectId,
      'projectName': projectName,
      'propertyType': propertyType,
      'category': category,
      'unitNo': unitNo,
      'unitDetails': unitDetails,
      'bookingAmount': bookingAmount,
      'advanceAmount': advanceAmount,
      'balanceAmount': balanceAmount,
      'paymentMode': paymentMode.name,
      'paymentReference': paymentReference,
      'salesExecutiveId': salesExecutiveId,
      'salesExecutiveName': salesExecutiveName,
      'commission': commission,
      'approvedBy': approvedBy,
      'approvedById': approvedById,
      'approvedAt': approvedAt?.toIso8601String(),
      'status': status.name,
      'bookingDate': bookingDate.toIso8601String(),
      'possessionDate': possessionDate?.toIso8601String(),
      'notes': notes,
      'termsAndConditions': termsAndConditions,
      'documents': documents,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'customFields': customFields,
    };
  }

  Booking copyWith({
    String? id,
    String? srNo,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? leadId,
    String? projectId,
    String? projectName,
    String? propertyType,
    String? category,
    String? unitNo,
    String? unitDetails,
    double? bookingAmount,
    double? advanceAmount,
    double? balanceAmount,
    PaymentMode? paymentMode,
    String? paymentReference,
    String? salesExecutiveId,
    String? salesExecutiveName,
    double? commission,
    String? approvedBy,
    String? approvedById,
    DateTime? approvedAt,
    BookingStatus? status,
    DateTime? bookingDate,
    DateTime? possessionDate,
    String? notes,
    String? termsAndConditions,
    List<String>? documents,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? customFields,
  }) {
    return Booking(
      id: id ?? this.id,
      srNo: srNo ?? this.srNo,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      leadId: leadId ?? this.leadId,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      propertyType: propertyType ?? this.propertyType,
      category: category ?? this.category,
      unitNo: unitNo ?? this.unitNo,
      unitDetails: unitDetails ?? this.unitDetails,
      bookingAmount: bookingAmount ?? this.bookingAmount,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      paymentMode: paymentMode ?? this.paymentMode,
      paymentReference: paymentReference ?? this.paymentReference,
      salesExecutiveId: salesExecutiveId ?? this.salesExecutiveId,
      salesExecutiveName: salesExecutiveName ?? this.salesExecutiveName,
      commission: commission ?? this.commission,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedById: approvedById ?? this.approvedById,
      approvedAt: approvedAt ?? this.approvedAt,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      possessionDate: possessionDate ?? this.possessionDate,
      notes: notes ?? this.notes,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      documents: documents ?? this.documents,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customFields: customFields ?? this.customFields,
    );
  }

  @override
  String toString() {
    return 'Booking(id: $id, srNo: $srNo, customerName: $customerName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Booking && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
