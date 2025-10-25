import '../models/booking_model.dart';
import '../services/booking_service.dart';
import '../services/api_service.dart';

class BookingRepository {
  final BookingService _bookingService;

  BookingRepository({BookingService? bookingService})
    : _bookingService = bookingService ?? BookingService();

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
    return _bookingService.getBookings(
      search: search,
      status: status,
      customerId: customerId,
      projectId: projectId,
      salesExecutiveId: salesExecutiveId,
      approvedBy: approvedBy,
      fromDate: fromDate,
      toDate: toDate,
      page: page,
      limit: limit,
    );
  }

  Future<ApiResponse<Booking>> getBookingById(String id) async {
    return _bookingService.getBooking(id);
  }

  Future<ApiResponse<Booking>> createBooking(Booking booking) async {
    return _bookingService.createBooking(booking);
  }

  Future<ApiResponse<Booking>> updateBooking(String id, Booking booking) async {
    return _bookingService.updateBooking(id, booking);
  }

  Future<ApiResponse<void>> deleteBooking(String id) async {
    return _bookingService.deleteBooking(id);
  }

  Future<ApiResponse<Booking>> updateBookingStatus(
    String bookingId,
    BookingStatus status,
    String? notes,
  ) async {
    return _bookingService.updateBookingStatus(bookingId, status, notes);
  }

  Future<ApiResponse<Booking>> approveBooking(
    String bookingId,
    String approvedBy,
    String? notes,
  ) async {
    return _bookingService.approveBooking(bookingId, approvedBy, notes);
  }

  Future<ApiResponse<Booking>> cancelBooking(
    String bookingId,
    String reason,
    String? notes,
  ) async {
    return _bookingService.cancelBooking(bookingId, reason, notes);
  }

  Future<ApiResponse<Map<String, dynamic>>> getBookingStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? salesExecutiveId,
    String? projectId,
  }) async {
    return _bookingService.getBookingStats(
      fromDate: fromDate,
      toDate: toDate,
      salesExecutiveId: salesExecutiveId,
      projectId: projectId,
    );
  }

  Future<ApiResponse<List<Booking>>> getTodaysBookings() async {
    return _bookingService.getTodaysBookings();
  }

  Future<ApiResponse<List<Booking>>> getPendingApprovals() async {
    return _bookingService.getPendingApprovals();
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getBookingTimeline(
    String bookingId,
  ) async {
    return _bookingService.getBookingTimeline(bookingId);
  }

  Future<ApiResponse<Booking>> updatePaymentDetails(
    String bookingId,
    double? advanceAmount,
    double? balanceAmount,
    PaymentMode? paymentMode,
    String? paymentReference,
  ) async {
    return _bookingService.updatePaymentDetails(
      bookingId,
      advanceAmount,
      balanceAmount,
      paymentMode,
      paymentReference,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> generateReceipt(
    String bookingId,
  ) async {
    return _bookingService.generateReceipt(bookingId);
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getCommissionReport({
    DateTime? fromDate,
    DateTime? toDate,
    String? salesExecutiveId,
  }) async {
    return _bookingService.getCommissionReport(
      fromDate: fromDate,
      toDate: toDate,
      salesExecutiveId: salesExecutiveId,
    );
  }

  Future<ApiResponse<List<Booking>>> searchBySrNo(String srNo) async {
    return _bookingService.searchBySrNo(srNo);
  }
}
