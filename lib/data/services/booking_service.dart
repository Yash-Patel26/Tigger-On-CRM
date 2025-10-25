import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/booking_model.dart';

class BookingService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Get all bookings with optional filters
  static Future<List<Booking>> getBookings({
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
    try {
      var query = _client.from('bookings').select('*');

      // Apply search filter
      if (search != null && search.isNotEmpty) {
        query = query.or(
          'sr_no.ilike.%$search%,customer_name.ilike.%$search%,project_name.ilike.%$search%',
        );
      }

      // Apply other filters
      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (customerName != null && customerName.isNotEmpty) {
        query = query.ilike('customer_name', '%$customerName%');
      }

      if (propertyType != null && propertyType.isNotEmpty) {
        query = query.eq('property_type', propertyType);
      }

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }

      if (approvedBy != null && approvedBy.isNotEmpty) {
        query = query.eq('approved_by', approvedBy);
      }

      if (project != null && project.isNotEmpty) {
        query = query.eq('project_name', project);
      }

      if (salesExecutiveId != null && salesExecutiveId.isNotEmpty) {
        query = query.eq('sales_executive_id', salesExecutiveId);
      }

      if (fromDate != null) {
        query = query.gte('booking_date', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('booking_date', toDate.toIso8601String());
      }

      // Order and pagination
      final int from = (page - 1) * limit;
      final int to = from + limit - 1;
      final response = await query
          .order('created_at', ascending: false)
          .range(from, to);

      return (response as List).map((json) => Booking.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  // Get booking by ID
  static Future<Booking?> getBookingById(String id) async {
    try {
      final response = await _client
          .from('bookings')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return Booking.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch booking: $e');
    }
  }

  // Get booking by SR number
  static Future<Booking?> getBookingBySrNo(String srNo) async {
    try {
      final response = await _client
          .from('bookings')
          .select('*')
          .eq('sr_no', srNo)
          .maybeSingle();

      if (response == null) return null;
      return Booking.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch booking: $e');
    }
  }

  // Create new booking
  static Future<Booking> createBooking({
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
    try {
      // Generate SR number
      final srNo = await _generateSrNo();

      final bookingData = {
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
        'status': status.name,
        'booking_date': bookingDate.toIso8601String(),
        'possession_date': possessionDate?.toIso8601String(),
        'notes': notes,
        'terms_and_conditions': termsAndConditions,
        'documents': documents,
        'created_by': createdBy,
        'created_by_name': createdByName,
        'custom_fields': customFields,
      };

      final response = await _client
          .from('bookings')
          .insert(bookingData)
          .select()
          .single();

      return Booking.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Update booking
  static Future<Booking> updateBooking({
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
    try {
      final updateData = <String, dynamic>{};

      if (customerName != null) updateData['customer_name'] = customerName;
      if (customerEmail != null) updateData['customer_email'] = customerEmail;
      if (customerPhone != null) updateData['customer_phone'] = customerPhone;
      if (propertyType != null) updateData['property_type'] = propertyType;
      if (category != null) updateData['category'] = category;
      if (unitNo != null) updateData['unit_no'] = unitNo;
      if (unitDetails != null) updateData['unit_details'] = unitDetails;
      if (bookingAmount != null) updateData['booking_amount'] = bookingAmount;
      if (advanceAmount != null) updateData['advance_amount'] = advanceAmount;
      if (balanceAmount != null) updateData['balance_amount'] = balanceAmount;
      if (paymentMode != null) updateData['payment_mode'] = paymentMode.name;
      if (paymentReference != null)
        updateData['payment_reference'] = paymentReference;
      if (salesExecutiveId != null)
        updateData['sales_executive_id'] = salesExecutiveId;
      if (salesExecutiveName != null)
        updateData['sales_executive_name'] = salesExecutiveName;
      if (commission != null) updateData['commission'] = commission;
      if (approvedBy != null) updateData['approved_by'] = approvedBy;
      if (approvedById != null) updateData['approved_by_id'] = approvedById;
      if (approvedAt != null)
        updateData['approved_at'] = approvedAt.toIso8601String();
      if (status != null) updateData['status'] = status.name;
      if (bookingDate != null)
        updateData['booking_date'] = bookingDate.toIso8601String();
      if (possessionDate != null)
        updateData['possession_date'] = possessionDate.toIso8601String();
      if (notes != null) updateData['notes'] = notes;
      if (termsAndConditions != null)
        updateData['terms_and_conditions'] = termsAndConditions;
      if (documents != null) updateData['documents'] = documents;
      if (customFields != null) updateData['custom_fields'] = customFields;

      final response = await _client
          .from('bookings')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return Booking.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  // Delete booking
  static Future<void> deleteBooking(String id) async {
    try {
      await _client.from('bookings').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }

  // Get booking statistics
  static Future<Map<String, int>> getBookingStats({
    DateTime? fromDate,
    DateTime? toDate,
    String? salesExecutiveId,
  }) async {
    try {
      var query = _client.from('bookings').select('status, booking_date');

      if (fromDate != null) {
        query = query.gte('booking_date', fromDate.toIso8601String());
      }

      if (toDate != null) {
        query = query.lte('booking_date', toDate.toIso8601String());
      }

      if (salesExecutiveId != null) {
        query = query.eq('sales_executive_id', salesExecutiveId);
      }

      final response = await query;

      final stats = <String, int>{
        'total': 0,
        'pending': 0,
        'confirmed': 0,
        'cancelled': 0,
        'completed': 0,
      };

      for (final booking in response as List) {
        stats['total'] = (stats['total'] ?? 0) + 1;
        final status = booking['status'] as String;
        stats[status] = (stats[status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Failed to fetch booking statistics: $e');
    }
  }

  // Get today's bookings count
  static Future<int> getTodaysBookingsCount() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final response = await _client
          .from('bookings')
          .select('id')
          .gte('booking_date', startOfDay.toIso8601String())
          .lt('booking_date', endOfDay.toIso8601String());

      return (response as List).length;
    } catch (e) {
      throw Exception('Failed to fetch today\'s bookings count: $e');
    }
  }

  // Generate unique SR number
  static Future<String> _generateSrNo() async {
    try {
      // Get the latest booking to determine next number
      final response = await _client
          .from('bookings')
          .select('sr_no')
          .order('created_at', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        return 'BK001';
      }

      final lastSrNo = response.first['sr_no'] as String;
      final number = int.tryParse(lastSrNo.substring(2)) ?? 0;
      final nextNumber = number + 1;

      return 'BK${nextNumber.toString().padLeft(3, '0')}';
    } catch (e) {
      // Fallback to timestamp-based SR number
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'BK$timestamp';
    }
  }
}
