import 'package:flutter/material.dart';
import '../utils/page_transitions.dart';
import 'developer_management_screen.dart';

class DeveloperQuickStatsScreen extends StatefulWidget {
  const DeveloperQuickStatsScreen({super.key});

  @override
  State<DeveloperQuickStatsScreen> createState() =>
      _DeveloperQuickStatsScreenState();
}

class _DeveloperQuickStatsScreenState extends State<DeveloperQuickStatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _statusFilter = 0; // 0=All, 1=Active, 2=Inactive

  // Mock data - replace with real data source
  final List<Developer> _developers = [
    const Developer(
      name: 'Skyline Builders',
      website: 'https://skyline.example',
      logoUrl: null,
      address: 'Sector 21',
      state: 'Maharashtra',
      district: 'Mumbai Suburban',
      city: 'Mumbai',
      pincode: '400053',
      contacts: [
        DevContact(
          name: 'Amit Shah',
          mobile: '+91 98765 11111',
          designation: 'Director',
          email: 'amit@skyline.com',
        ),
      ],
      companyType: 'Pvt Ltd',
      isReraRegistered: true,
      reraNumber: 'MH/RERA/123456',
      gstin: '27ABCDE1234F1Z5',
      gstinFilePath: null,
      pan: 'ABCDE1234F',
      panFilePath: null,
      bankCategory: 'Savings',
      bankName: 'State Bank of India',
      accountType: 'Current',
      ifscCode: 'SBIN0001234',
      branchName: 'Mumbai Central',
      accountHolderName: 'Skyline Builders Pvt Ltd',
      accountNumber: '1234567890123456',
      isActive: true,
    ),
    const Developer(
      name: 'GreenHomes',
      website: 'https://greenhomes.example',
      logoUrl: null,
      address: 'MG Road',
      state: 'Karnataka',
      district: 'Bengaluru Urban',
      city: 'Bengaluru',
      pincode: '560001',
      contacts: [
        DevContact(
          name: 'Priya Iyer',
          mobile: '+91 98765 22222',
          designation: 'Sales Head',
          email: 'priya@greenhomes.com',
        ),
      ],
      companyType: 'LLP',
      isReraRegistered: false,
      reraNumber: '',
      gstin: '',
      gstinFilePath: null,
      pan: 'PQRSX6789Z',
      panFilePath: null,
      bankCategory: 'Current',
      bankName: 'HDFC Bank',
      accountType: 'Savings',
      ifscCode: 'HDFC0005678',
      branchName: 'Koramangala',
      accountHolderName: 'GreenHomes LLP',
      accountNumber: '9876543210987654',
      isActive: false,
    ),
    const Developer(
      name: 'Metro Developers',
      website: 'https://metrodev.example',
      logoUrl: null,
      address: 'Connaught Place',
      state: 'Delhi',
      district: 'New Delhi',
      city: 'New Delhi',
      pincode: '110001',
      contacts: [
        DevContact(
          name: 'Rajesh Kumar',
          mobile: '+91 98765 33333',
          designation: 'Managing Director',
          email: 'rajesh@metrodev.com',
        ),
      ],
      companyType: 'Pvt Ltd',
      isReraRegistered: true,
      reraNumber: 'DL/RERA/789012',
      gstin: '07FGHIJ5678K9L0',
      gstinFilePath: null,
      pan: 'FGHIJ5678K',
      panFilePath: null,
      bankCategory: 'Savings',
      bankName: 'ICICI Bank',
      accountType: 'Current',
      ifscCode: 'ICIC0009012',
      branchName: 'Connaught Place',
      accountHolderName: 'Metro Developers Pvt Ltd',
      accountNumber: '5555666677778888',
      isActive: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int total = _developers.length;
    final int active = _developers.where((Developer d) => d.isActive).length;
    final int inactive = total - active;

    final String query = _searchController.text.trim().toLowerCase();
    final List<Developer> filtered = _developers.where((Developer d) {
      final bool matchesQuery =
          query.isEmpty ||
          d.name.toLowerCase().contains(query) ||
          (d.website?.toLowerCase().contains(query) ?? false) ||
          d.city.toLowerCase().contains(query);
      final bool matchesStatus =
          _statusFilter == 0 ||
          (_statusFilter == 1 && d.isActive) ||
          (_statusFilter == 2 && !d.isActive);
      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Developer'), elevation: 0),
      body: Column(
        children: [
          // Quick Stats Cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Active',
                    active.toString(),
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Inactive',
                    inactive.toString(),
                    Icons.pause_circle_outline,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Search and Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search developers by name, website, or city...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: _panelColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _panelBorderColor(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _panelBorderColor(context)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('All'),
                            selected: _statusFilter == 0,
                            onSelected: (_) =>
                                setState(() => _statusFilter = 0),
                          ),
                          ChoiceChip(
                            label: const Text('Active'),
                            selected: _statusFilter == 1,
                            onSelected: (_) =>
                                setState(() => _statusFilter = 1),
                          ),
                          ChoiceChip(
                            label: const Text('Inactive'),
                            selected: _statusFilter == 2,
                            onSelected: (_) =>
                                setState(() => _statusFilter = 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: () {
                        Navigator.of(context).push(
                          SmoothPageTransitions.slideFromRight<void>(
                            child: const DeveloperManagementScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_business),
                      tooltip: 'Create New Developer',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Developer List
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: _panelBorderColor(context), height: 1),
                    itemBuilder: (context, index) {
                      final Developer developer = filtered[index];
                      return _buildDeveloperCard(context, developer);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panelColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard(BuildContext context, Developer developer) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panelColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.1),
            backgroundImage:
                (developer.logoUrl != null && developer.logoUrl!.isNotEmpty)
                ? NetworkImage(developer.logoUrl!)
                : null,
            child: (developer.logoUrl == null || developer.logoUrl!.isEmpty)
                ? Icon(
                    Icons.apartment_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  developer.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  developer.website ?? developer.city,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${developer.city}, ${developer.state}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildStatusChip(context, developer.isActive),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, bool isActive) {
    final Color color = isActive ? Colors.green : Colors.redAccent;
    final String label = isActive ? 'Active' : 'Inactive';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No developers found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Color _panelColor(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);
  }

  Color _panelBorderColor(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0x22000000);
  }
}

// Developer model classes
class Developer {
  const Developer({
    required this.name,
    this.website,
    this.logoUrl,
    required this.address,
    required this.state,
    required this.district,
    required this.city,
    required this.pincode,
    required this.contacts,
    required this.companyType,
    required this.isReraRegistered,
    required this.reraNumber,
    required this.gstin,
    this.gstinFilePath,
    required this.pan,
    this.panFilePath,
    required this.bankCategory,
    required this.bankName,
    required this.accountType,
    required this.ifscCode,
    required this.branchName,
    required this.accountHolderName,
    required this.accountNumber,
    required this.isActive,
  });

  final String name;
  final String? website;
  final String? logoUrl;
  final String address;
  final String state;
  final String district;
  final String city;
  final String pincode;
  final List<DevContact> contacts;
  final String companyType;
  final bool isReraRegistered;
  final String reraNumber;
  final String gstin;
  final String? gstinFilePath;
  final String pan;
  final String? panFilePath;
  final String bankCategory;
  final String bankName;
  final String accountType;
  final String ifscCode;
  final String branchName;
  final String accountHolderName;
  final String accountNumber;
  final bool isActive;
}

class DevContact {
  const DevContact({
    required this.name,
    required this.mobile,
    required this.designation,
    required this.email,
  });

  final String name;
  final String mobile;
  final String designation;
  final String email;
}
