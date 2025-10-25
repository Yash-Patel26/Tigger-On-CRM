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
    // Helper function to get string value with fallback
    String getString(String key, [String fallback = '']) {
      return json[key] as String? ?? fallback;
    }

    // Helper function to get nullable string
    String? getNullableString(String key) {
      return json[key] as String?;
    }

    // Helper function to get double value
    double getDouble(String key, [double fallback = 0.0]) {
      final value = json[key];
      if (value == null) return fallback;
      return (value as num).toDouble();
    }

    // Helper function to get nullable double
    double? getNullableDouble(String key) {
      final value = json[key];
      if (value == null) return null;
      return (value as num).toDouble();
    }

    // Helper function to get DateTime
    DateTime getDateTime(String key) {
      return DateTime.parse(json[key] as String);
    }

    // Helper function to get nullable DateTime
    DateTime? getNullableDateTime(String key) {
      final value = json[key];
      if (value == null) return null;
      return DateTime.parse(value as String);
    }

    return Booking(
      id: getString('id'),
      srNo: getString('sr_no'),
      customerId: getString('customer_id'),
      customerName: getString('customer_name'),
      customerEmail: getString('customer_email'),
      customerPhone: getString('customer_phone'),
      leadId: getString('lead_id'),
      projectId: getString('project_id'),
      projectName: getString('project_name'),
      propertyType: getString('property_type'),
      category: getString('category'),
      unitNo: getString('unit_no'),
      unitDetails: getString('unit_details'),
      bookingAmount: getDouble('booking_amount'),
      advanceAmount: getNullableDouble('advance_amount'),
      balanceAmount: getNullableDouble('balance_amount'),
      paymentMode: PaymentMode.values.firstWhere(
        (e) => e.name == getString('payment_mode'),
        orElse: () => PaymentMode.cash,
      ),
      paymentReference: getNullableString('payment_reference'),
      salesExecutiveId: getString('sales_executive_id'),
      salesExecutiveName: getString('sales_executive_name'),
      commission: getDouble('commission'),
      approvedBy: getString('approved_by'),
      approvedById: getNullableString('approved_by_id'),
      approvedAt: getNullableDateTime('approved_at'),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == getString('status'),
        orElse: () => BookingStatus.pending,
      ),
      bookingDate: getDateTime('booking_date'),
      possessionDate: getNullableDateTime('possession_date'),
      notes: getNullableString('notes'),
      termsAndConditions: getNullableString('terms_and_conditions'),
      documents: json['documents'] != null
          ? List<String>.from(json['documents'] as List)
          : null,
      createdBy: getString('created_by'),
      createdByName: getString('created_by_name'),
      createdAt: getDateTime('created_at'),
      updatedAt: getDateTime('updated_at'),
      customFields: json['custom_fields'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sr_no': srNo,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_email': customerEmail,
      'customer_phone': customerPhone,
      'lead_id': leadId,
      'project_id': projectId,
      'project_name': projectName,
      'property_type': propertyType,
      'category': category,
      'unit_no': unitNo,
      'unit_details': unitDetails,
      'booking_amount': bookingAmount,
      'advance_amount': advanceAmount,
      'balance_amount': balanceAmount,
      'payment_mode': paymentMode.name,
      'payment_reference': paymentReference,
      'sales_executive_id': salesExecutiveId,
      'sales_executive_name': salesExecutiveName,
      'commission': commission,
      'approved_by': approvedBy,
      'approved_by_id': approvedById,
      'approved_at': approvedAt?.toIso8601String(),
      'status': status.name,
      'booking_date': bookingDate.toIso8601String(),
      'possession_date': possessionDate?.toIso8601String(),
      'notes': notes,
      'terms_and_conditions': termsAndConditions,
      'documents': documents,
      'created_by': createdBy,
      'created_by_name': createdByName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'custom_fields': customFields,
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
