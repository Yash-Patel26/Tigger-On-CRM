import '../models/booking_model.dart';
import 'api_service.dart';

class BookingService {
  final ApiService _apiService;

  BookingService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  // Get all bookings with optional filters
  Future<ApiResponse<List<Booking>>> getBookings({
    String? search,
    BookingStatus? status,
    String? customerId,
    String? projectId,
    String? salesExecutiveId,
    String? approvedBy,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (status != null) {
      queryParams['status'] = status.name;
    }
    if (customerId != null) {
      queryParams['customerId'] = customerId;
    }
    if (projectId != null) {
      queryParams['projectId'] = projectId;
    }
    if (salesExecutiveId != null) {
      queryParams['salesExecutiveId'] = salesExecutiveId;
    }
    if (approvedBy != null) {
      queryParams['approvedBy'] = approvedBy;
    }
    if (fromDate != null) {
      queryParams['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate.toIso8601String();
    }

    return await _apiService.get<List<Booking>>(
      '/bookings',
      queryParams: queryParams,
      fromJson: (json) => (json['data'] as List)
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get booking by ID
  Future<ApiResponse<Booking>> getBooking(String id) async {
    return await _apiService.get<Booking>(
      '/bookings/$id',
      fromJson: (json) =>
          Booking.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Create new booking
  Future<ApiResponse<Booking>> createBooking(Booking booking) async {
    return await _apiService.post<Booking>(
      '/bookings',
      body: booking.toJson(),
      fromJson: (json) =>
          Booking.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Update booking
  Future<ApiResponse<Booking>> updateBooking(String id, Booking booking) async {
    return await _apiService.put<Booking>(
      '/bookings/$id',
      body: booking.toJson(),
      fromJson: (json) =>
          Booking.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Delete booking
  Future<ApiResponse<void>> deleteBooking(String id) async {
    return await _apiService.delete<void>('/bookings/$id');
  }

  // Update booking status
  Future<ApiResponse<Booking>> updateBookingStatus(
    String bookingId,
    BookingStatus status,
    String? notes,
  ) async {
    return await _apiService.patch<Booking>(
      '/bookings/$bookingId/status',
      body: {'status': status.name, if (notes != null) 'notes': notes},
      fromJson: (json) =>
          Booking.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Approve booking
  Future<ApiResponse<Booking>> approveBooking(
    String bookingId,
    String approvedBy,
    String? notes,
  ) async {
    return await _apiService.post<Booking>(
      '/bookings/$bookingId/approve',
      body: {'approvedBy': approvedBy, if (notes != null) 'notes': notes},
      fromJson: (json) =>
          Booking.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Cancel booking
  Future<ApiResponse<Booking>> cancelBooking(
    String bookingId,
    String reason,
    String? notes,
  ) async {
    return await _apiService.post<Booking>(
      '/bookings/$bookingId/cancel',
      body: {'reason': reason, if (notes != null) 'notes': notes},
      fromJson: (json) =>
          Booking.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Get booking statistics
  Future<ApiResponse<Map<String, dynamic>>> getBookingStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? salesExecutiveId,
    String? projectId,
  }) async {
    final queryParams = <String, String>{};

    if (fromDate != null) {
      queryParams['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate.toIso8601String();
    }
    if (salesExecutiveId != null) {
      queryParams['salesExecutiveId'] = salesExecutiveId;
    }
    if (projectId != null) {
      queryParams['projectId'] = projectId;
    }

    return await _apiService.get<Map<String, dynamic>>(
      '/bookings/stats',
      queryParams: queryParams,
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }

  // Get today's bookings
  Future<ApiResponse<List<Booking>>> getTodaysBookings() async {
    return await _apiService.get<List<Booking>>(
      '/bookings/today',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get pending approvals
  Future<ApiResponse<List<Booking>>> getPendingApprovals() async {
    return await _apiService.get<List<Booking>>(
      '/bookings/pending-approvals',
      fromJson: (json) => (json['data'] as List)
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // Get booking timeline/activity
  Future<ApiResponse<List<Map<String, dynamic>>>> getBookingTimeline(
    String bookingId,
  ) async {
    return await _apiService.get<List<Map<String, dynamic>>>(
      '/bookings/$bookingId/timeline',
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Update payment details
  Future<ApiResponse<Booking>> updatePaymentDetails(
    String bookingId,
    double? advanceAmount,
    double? balanceAmount,
    PaymentMode? paymentMode,
    String? paymentReference,
  ) async {
    return await _apiService.patch<Booking>(
      '/bookings/$bookingId/payment',
      body: {
        if (advanceAmount != null) 'advanceAmount': advanceAmount,
        if (balanceAmount != null) 'balanceAmount': balanceAmount,
        if (paymentMode != null) 'paymentMode': paymentMode.name,
        if (paymentReference != null) 'paymentReference': paymentReference,
      },
      fromJson: (json) =>
          Booking.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  // Generate booking receipt
  Future<ApiResponse<Map<String, dynamic>>> generateReceipt(
    String bookingId,
  ) async {
    return await _apiService.get<Map<String, dynamic>>(
      '/bookings/$bookingId/receipt',
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }

  // Get commission report
  Future<ApiResponse<List<Map<String, dynamic>>>> getCommissionReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? salesExecutiveId,
  }) async {
    final queryParams = <String, String>{};

    if (fromDate != null) {
      queryParams['fromDate'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['toDate'] = toDate.toIso8601String();
    }
    if (salesExecutiveId != null) {
      queryParams['salesExecutiveId'] = salesExecutiveId;
    }

    return await _apiService.get<List<Map<String, dynamic>>>(
      '/bookings/commission-report',
      queryParams: queryParams,
      fromJson: (json) =>
          (json['data'] as List).map((e) => e as Map<String, dynamic>).toList(),
    );
  }

  // Search bookings by SR number
  Future<ApiResponse<List<Booking>>> searchBySrNo(String srNo) async {
    return await _apiService.get<List<Booking>>(
      '/bookings/search/sr-no',
      queryParams: {'srNo': srNo},
      fromJson: (json) => (json['data'] as List)
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
