import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../data/models/models.dart';
import '../../../data/repositories/booking_repository.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  final BookingRepository _bookingRepository = BookingRepository();
  Booking? _booking;
  bool _isLoading = true;
  String? _error;

  // Disposition data
  String? _mainDisposition;
  String? _subDisposition;
  int _ndof = 0; // Number of Days Outstanding

  @override
  void initState() {
    super.initState();
    _loadBookingData();
  }

  Future<void> _loadBookingData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load booking data
      final booking = await _bookingRepository.getBookingById(widget.bookingId);

      if (booking == null) {
        setState(() {
          _error = 'Booking not found';
          _isLoading = false;
        });
        return;
      }

      // Calculate NDOF (Number of Days Outstanding)
      final now = DateTime.now();
      final bookingDate = booking.bookingDate;
      _ndof = now.difference(bookingDate).inDays;

      // Load disposition data from lead
      if (booking.leadId.isNotEmpty) {
        await _loadDispositionData(booking.leadId);
      }

      setState(() {
        _booking = booking;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadDispositionData(String leadId) async {
    try {
      final client = supabase.Supabase.instance.client;

      // Get the latest disposition for this lead
      final dispositions = await client
          .from('lead_dispositions')
          .select('main_disposition_id, sub_disposition_id')
          .eq('lead_id', leadId)
          .order('disposed_at', ascending: false)
          .limit(1);

      if (dispositions.isEmpty) {
        return;
      }

      final disposition = dispositions[0];
      final mainDispositionId = disposition['main_disposition_id'] as String?;
      final subDispositionId = disposition['sub_disposition_id'] as String?;

      if (mainDispositionId == null || subDispositionId == null) {
        return;
      }

      // Get main disposition name
      final mainDisposition = await client
          .from('lead_status_master')
          .select('name')
          .eq('id', mainDispositionId)
          .eq('is_active', true)
          .maybeSingle();

      // Get sub disposition name
      final subDisposition = await client
          .from('lead_sub_status_master')
          .select('name')
          .eq('id', subDispositionId)
          .eq('is_active', true)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _mainDisposition = mainDisposition?['name'] as String? ?? 'Not Set';
          _subDisposition = subDisposition?['name'] as String? ?? 'Not Set';
        });
      }
    } catch (e) {
      print('Error loading disposition data: $e');
      // Don't fail the entire screen if disposition fails to load
      if (mounted) {
        setState(() {
          _mainDisposition = 'Error loading';
          _subDisposition = 'Error loading';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _booking?.srNo ?? 'Booking Details',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : _booking == null
          ? const Center(child: Text('Booking not found'))
          : _buildContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            'Error loading booking',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error occurred',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadBookingData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Details Card
          _buildBasicDetailsCard(),
          const SizedBox(height: 12),

          // Property Card
          _buildPropertyCard(),
          const SizedBox(height: 12),

          // Disposition Card
          _buildDispositionCard(),
          const SizedBox(height: 12),

          // Transaction Card
          _buildTransactionCard(),
        ],
      ),
    );
  }

  Widget _buildBasicDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Basic Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            _buildInfoRow('Customer Name', _booking!.customerName),
            const SizedBox(height: 8),
            _buildInfoRow('Customer ID', _booking!.customerId),
            const SizedBox(height: 8),
            _buildInfoRow('Mobile Number', _booking!.customerPhone),
            const SizedBox(height: 8),
            _buildInfoRow('Email', _booking!.customerEmail),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.home,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Property',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            _buildInfoRow('Project', _booking!.projectName),
            const SizedBox(height: 8),
            _buildInfoRow('Property Type', _booking!.propertyType),
            const SizedBox(height: 8),
            _buildInfoRow('Property Category', _booking!.category),
          ],
        ),
      ),
    );
  }

  Widget _buildDispositionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Disposition',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            _buildInfoRow('Main Disposition', _mainDisposition ?? 'Not Set'),
            const SizedBox(height: 8),
            _buildInfoRow('Sub Disposition', _subDisposition ?? 'Not Set'),
            const SizedBox(height: 8),
            _buildInfoRow('NDOF', '$_ndof days'),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionCard() {
    // Calculate values
    final propertyPrice = _booking!.bookingAmount;
    final discount =
        0.0; // Discount not stored in booking model, defaulting to 0
    final salesPrice = propertyPrice - discount;
    final paidAmount = _booking!.advanceAmount ?? 0.0;
    final remainingAmount = _booking!.balanceAmount ?? 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.payment,
                  color: Theme.of(context).colorScheme.primary,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  'Transaction',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            _buildInfoRow('Property Price', _formatAmount(propertyPrice)),
            const SizedBox(height: 8),
            _buildInfoRow('Discount', _formatAmount(discount)),
            const SizedBox(height: 8),
            _buildInfoRow('Sales Price', _formatAmount(salesPrice)),
            const SizedBox(height: 8),
            _buildInfoRow('Paid Amount', _formatAmount(paidAmount)),
            const SizedBox(height: 8),
            _buildInfoRow('Remaining Amount', _formatAmount(remainingAmount)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(2)} K';
    } else {
      return '₹${amount.toStringAsFixed(2)}';
    }
  }
}
