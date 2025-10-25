import '../models/booking_model.dart';
import '../services/booking_service.dart';

class BookingRepository {
  // Static methods from BookingService
  Future<List<Booking>> getBookings({
    String? search,
    BookingStatus? status,
    String? customerName,
    String? propertyType,
    String? category,
    String? approvedBy,
    String? project,
    String? salesExecutiveId,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 20,
  }) async {
    return await BookingService.getBookings(
      search: search,
      status: status,
      customerName: customerName,
      propertyType: propertyType,
      category: category,
      approvedBy: approvedBy,
      project: project,
      salesExecutiveId: salesExecutiveId,
      fromDate: fromDate,
      toDate: toDate,
      page: page,
      limit: limit,
    );
  }

  Future<Booking?> getBookingById(String id) async {
    return await BookingService.getBookingById(id);
  }

  Future<Booking?> getBookingBySrNo(String srNo) async {
    return await BookingService.getBookingBySrNo(srNo);
  }

  Future<Booking> createBooking({
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required String leadId,
    required String projectId,
    required String projectName,
    required String propertyType,
    required String category,
    required String unitNo,
    required String unitDetails,
    required double bookingAmount,
    double? advanceAmount,
    double? balanceAmount,
    required PaymentMode paymentMode,
    String? paymentReference,
    required String salesExecutiveId,
    required String salesExecutiveName,
    required double commission,
    required String approvedBy,
    String? approvedById,
    required BookingStatus status,
    required DateTime bookingDate,
    DateTime? possessionDate,
    String? notes,
    String? termsAndConditions,
    List<String>? documents,
    required String createdBy,
    required String createdByName,
    Map<String, dynamic>? customFields,
  }) async {
    return await BookingService.createBooking(
      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      leadId: leadId,
      projectId: projectId,
      projectName: projectName,
      propertyType: propertyType,
      category: category,
      unitNo: unitNo,
      unitDetails: unitDetails,
      bookingAmount: bookingAmount,
      advanceAmount: advanceAmount,
      balanceAmount: balanceAmount,
      paymentMode: paymentMode,
      paymentReference: paymentReference,
      salesExecutiveId: salesExecutiveId,
      salesExecutiveName: salesExecutiveName,
      commission: commission,
      approvedBy: approvedBy,
      approvedById: approvedById,
      status: status,
      bookingDate: bookingDate,
      possessionDate: possessionDate,
      notes: notes,
      termsAndConditions: termsAndConditions,
      documents: documents,
      createdBy: createdBy,
      createdByName: createdByName,
      customFields: customFields,
    );
  }

  Future<Booking> updateBooking({
    required String id,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
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
    Map<String, dynamic>? customFields,
  }) async {
    return await BookingService.updateBooking(
      id: id,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      propertyType: propertyType,
      category: category,
      unitNo: unitNo,
      unitDetails: unitDetails,
      bookingAmount: bookingAmount,
      advanceAmount: advanceAmount,
      balanceAmount: balanceAmount,
      paymentMode: paymentMode,
      paymentReference: paymentReference,
      salesExecutiveId: salesExecutiveId,
      salesExecutiveName: salesExecutiveName,
      commission: commission,
      approvedBy: approvedBy,
      approvedById: approvedById,
      approvedAt: approvedAt,
      status: status,
      bookingDate: bookingDate,
      possessionDate: possessionDate,
      notes: notes,
      termsAndConditions: termsAndConditions,
      documents: documents,
      customFields: customFields,
    );
  }

  Future<void> deleteBooking(String id) async {
    return await BookingService.deleteBooking(id);
  }

  // Update booking status
  Future<Booking> updateBookingStatus({
    required String id,
    required BookingStatus status,
    String? notes,
  }) async {
    return await BookingService.updateBooking(
      id: id,
      status: status,
      notes: notes,
    );
  }

  // Approve booking
  Future<Booking> approveBooking({
    required String id,
    required String approvedBy,
    String? approvedById,
    String? notes,
  }) async {
    return await BookingService.updateBooking(
      id: id,
      approvedBy: approvedBy,
      approvedById: approvedById,
      approvedAt: DateTime.now(),
      status: BookingStatus.confirmed,
      notes: notes,
    );
  }

  // Cancel booking
  Future<Booking> cancelBooking({
    required String id,
    required String reason,
    String? notes,
  }) async {
    return await BookingService.updateBooking(
      id: id,
      status: BookingStatus.cancelled,
      notes: notes ?? reason,
    );
  }

  // Get booking statistics
  Future<Map<String, int>> getBookingStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? salesExecutiveId,
  }) async {
    return await BookingService.getBookingStats(
      fromDate: fromDate,
      toDate: toDate,
      salesExecutiveId: salesExecutiveId,
    );
  }

  // Get today's bookings count
  Future<int> getTodaysBookingsCount() async {
    return await BookingService.getTodaysBookingsCount();
  }

  // Get bookings by status
  Future<List<Booking>> getBookingsByStatus(BookingStatus status) async {
    return await BookingService.getBookings(status: status);
  }

  // Get pending bookings
  Future<List<Booking>> getPendingBookings() async {
    return await BookingService.getBookings(status: BookingStatus.pending);
  }

  // Update payment details
  Future<Booking> updatePaymentDetails({
    required String id,
    double? advanceAmount,
    double? balanceAmount,
    PaymentMode? paymentMode,
    String? paymentReference,
  }) async {
    return await BookingService.updateBooking(
      id: id,
      advanceAmount: advanceAmount,
      balanceAmount: balanceAmount,
      paymentMode: paymentMode,
      paymentReference: paymentReference,
    );
  }

  // Search by SR number
  Future<Booking?> searchBySrNo(String srNo) async {
    return await BookingService.getBookingBySrNo(srNo);
  }
}
