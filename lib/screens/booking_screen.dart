import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'booking_filters_sheet.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // Demo counts; replace with real data
  int totalBookings = 156;
  int todaysBookings = 8;

  String _search = '';

  // Filter variables
  String _selectedCustomerName = '';
  String _selectedPropertyType = '';
  String _selectedCategoryType = '';
  String _selectedApprovedBy = '';
  String _selectedProject = '';
  String _selectedAging = '';
  DateTime? _selectedLastUpdatedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Bookings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            tooltip: 'Filters',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Metrics Row
          _buildMetricsRow(),

          // Search Bar
          _buildSearchBar(),

          // Bookings List
          Expanded(child: _buildBookingsList()),
        ],
      ),
    );
  }

  Widget _buildMetricsRow() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              'Total Bookings',
              totalBookings.toString(),
              Icons.book_online,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              'Today\'s Bookings',
              todaysBookings.toString(),
              Icons.today,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) => setState(() => _search = value),
        decoration: const InputDecoration(
          hintText: 'Search by SR No, Customer Name, or Property...',
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: Icon(Icons.filter_list, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildBookingsList() {
    final filteredBookings = _getFilteredBookings();

    if (filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_online_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No bookings found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        final booking = filteredBookings[index];
        return _buildBookingCard(booking);
      },
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with SR No and Status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor(booking['status']).withOpacity(0.1),
                  _getStatusColor(booking['status']).withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'SR No: ${booking['srNo']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking['status']).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking['status'],
                    style: TextStyle(
                      color: _getStatusColor(booking['status']),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Booking Info
                _buildInfoSection('Booking Info', Icons.book_online, [
                  _buildInfoRow('Booking Date', booking['bookingDate']),
                  _buildInfoRow('Booking Amount', booking['bookingAmount']),
                  _buildInfoRow('Payment Mode', booking['paymentMode']),
                ]),

                const SizedBox(height: 16),

                // Customer Info
                _buildInfoSection('Customer Info', Icons.person, [
                  _buildInfoRow('Customer Name', booking['customerName']),
                  _buildInfoRow('Contact', booking['contact']),
                  _buildInfoRow('Email', booking['email']),
                ]),

                const SizedBox(height: 16),

                // Sale Info
                _buildInfoSection('Sale Info', Icons.sell, [
                  _buildInfoRow('Sales Executive', booking['salesExecutive']),
                  _buildInfoRow('Commission', booking['commission']),
                  _buildInfoRow('Approved By', booking['approvedBy']),
                ]),

                const SizedBox(height: 16),

                // Property Info
                _buildInfoSection('Property Info', Icons.home, [
                  _buildInfoRow('Property Type', booking['propertyType']),
                  _buildInfoRow('Category', booking['category']),
                  _buildInfoRow('Project', booking['project']),
                  _buildInfoRow('Unit No', booking['unitNo']),
                ]),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewBooking(booking),
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('View'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _editBooking(booking),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$label copied to clipboard'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
              child: Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredBookings() {
    final bookings = _getMockBookings();

    return bookings.where((booking) {
      // Search filter
      if (_search.isNotEmpty) {
        final searchLower = _search.toLowerCase();
        if (!booking['srNo'].toLowerCase().contains(searchLower) &&
            !booking['customerName'].toLowerCase().contains(searchLower) &&
            !booking['project'].toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Other filters
      if (_selectedCustomerName.isNotEmpty &&
          !booking['customerName'].toLowerCase().contains(
            _selectedCustomerName.toLowerCase(),
          )) {
        return false;
      }

      if (_selectedPropertyType.isNotEmpty &&
          booking['propertyType'] != _selectedPropertyType) {
        return false;
      }

      if (_selectedCategoryType.isNotEmpty &&
          booking['category'] != _selectedCategoryType) {
        return false;
      }

      if (_selectedApprovedBy.isNotEmpty &&
          booking['approvedBy'] != _selectedApprovedBy) {
        return false;
      }

      if (_selectedProject.isNotEmpty &&
          booking['project'] != _selectedProject) {
        return false;
      }

      if (_selectedAging.isNotEmpty) {
        // TODO: Implement aging filter logic based on booking date
        // This would require calculating days since booking and comparing with selected aging
      }

      if (_selectedLastUpdatedDate != null) {
        // TODO: Implement last updated date filter logic
        // This would require comparing booking's last updated date with selected date
      }

      return true;
    }).toList();
  }

  List<Map<String, dynamic>> _getMockBookings() {
    return [
      {
        'srNo': 'BK001',
        'status': 'Confirmed',
        'bookingDate': '15 Dec 2024',
        'bookingAmount': '₹25,00,000',
        'paymentMode': 'Cheque',
        'customerName': 'Rajesh Kumar',
        'contact': '+91 98765 43210',
        'email': 'rajesh.kumar@email.com',
        'salesExecutive': 'Sarah Wilson',
        'commission': '₹1,25,000',
        'approvedBy': 'Manager Name',
        'propertyType': '2 BHK Apartment',
        'category': 'Residential',
        'project': 'Project Alpha',
        'unitNo': 'A-101',
      },
      {
        'srNo': 'BK002',
        'status': 'Pending',
        'bookingDate': '14 Dec 2024',
        'bookingAmount': '₹18,50,000',
        'paymentMode': 'Online',
        'customerName': 'Priya Sharma',
        'contact': '+91 87654 32109',
        'email': 'priya.sharma@email.com',
        'salesExecutive': 'John Doe',
        'commission': '₹92,500',
        'approvedBy': 'Manager Name',
        'propertyType': '1 BHK Apartment',
        'category': 'Residential',
        'project': 'Project Beta',
        'unitNo': 'B-205',
      },
      {
        'srNo': 'BK003',
        'status': 'Cancelled',
        'bookingDate': '13 Dec 2024',
        'bookingAmount': '₹32,00,000',
        'paymentMode': 'Cash',
        'customerName': 'Amit Patel',
        'contact': '+91 76543 21098',
        'email': 'amit.patel@email.com',
        'salesExecutive': 'Sarah Wilson',
        'commission': '₹0',
        'approvedBy': 'Manager Name',
        'propertyType': '3 BHK Apartment',
        'category': 'Residential',
        'project': 'Project Alpha',
        'unitNo': 'C-301',
      },
    ];
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _viewBooking(Map<String, dynamic> booking) {
    // TODO: Navigate to booking detail screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing booking ${booking['srNo']}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _editBooking(Map<String, dynamic> booking) {
    // TODO: Navigate to edit booking screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editing booking ${booking['srNo']}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingFiltersSheet(
        onApply: (filters) {
          setState(() {
            _selectedCustomerName = filters['customerName'] ?? '';
            _selectedPropertyType = filters['propertyType'] ?? '';
            _selectedCategoryType = filters['categoryType'] ?? '';
            _selectedApprovedBy = filters['approvedBy'] ?? '';
            _selectedProject = filters['project'] ?? '';
            _selectedAging = filters['aging'] ?? '';
            _selectedLastUpdatedDate = filters['lastUpdatedDate'];
          });
        },
        onClear: () {
          setState(() {
            _selectedCustomerName = '';
            _selectedPropertyType = '';
            _selectedCategoryType = '';
            _selectedApprovedBy = '';
            _selectedProject = '';
            _selectedAging = '';
            _selectedLastUpdatedDate = null;
          });
        },
      ),
    );
  }
}
