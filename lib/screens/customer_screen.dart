// ignore_for_file: unused_field, unused_element
import 'package:flutter/material.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final _searchController = TextEditingController();
  String? _selectedPropertyType; // reserved for future
  String? _selectedProject; // reserved for future
  String? _selectedAging; // reserved for future
  DateTime? _selectedLastUpdateDate; // reserved for future

  // All list/data removed per request. Screen shows only quick stats for now.

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: null,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[_buildQuickStats(context)],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final List<_QuickStat> stats = <_QuickStat>[
      _QuickStat(
        label: 'Developer',
        count: 112,
        icon: Icons.account_balance,
        iconColor: const Color(0xFF1E88E5),
      ),
      _QuickStat(
        label: 'City',
        count: 18,
        icon: Icons.location_city,
        iconColor: const Color(0xFF1E88E5),
      ),
      _QuickStat(
        label: 'Location',
        count: 301,
        icon: Icons.map,
        iconColor: const Color(0xFF1E88E5),
      ),
      _QuickStat(
        label: 'Property Category',
        count: 2,
        icon: Icons.apartment,
        iconColor: const Color(0xFF1E88E5),
      ),
      _QuickStat(
        label: 'Property Type',
        count: 33,
        icon: Icons.playlist_add_check,
        iconColor: const Color(0xFF1E88E5),
      ),
      _QuickStat(
        label: 'Project Management',
        count: 450,
        icon: Icons.church,
        iconColor: const Color(0xFF1E88E5),
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth >= 1000) {
          crossAxisCount = 6;
        } else if (constraints.maxWidth >= 700) {
          crossAxisCount = 3;
        }
        double aspectRatio;
        if (crossAxisCount == 6) {
          aspectRatio = 0.85; // make tiles taller on very tight widths
        } else if (crossAxisCount == 3) {
          aspectRatio = 1.2;
        } else {
          aspectRatio = 1.8;
        }
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: aspectRatio,
          ),
          itemCount: stats.length,
          itemBuilder: (BuildContext context, int index) {
            final _QuickStat s = stats[index];
            return _buildQuickStatTile(context, s);
          },
        );
      },
    );
  }

  Widget _buildQuickStatTile(BuildContext context, _QuickStat stat) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(stat.icon, size: 22, color: stat.iconColor),
            const SizedBox(height: 6),
            Text(
              stat.count.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                stat.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 10.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(
    BuildContext context,
    Map<String, dynamic> customer,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SR #${customer['srNo']}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).iconTheme.color,
                ),
                onSelected: (value) {
                  _handleCustomerAction(value, customer);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Text('View Details'),
                  ),
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow(context, Icons.person, 'Name', customer['name']),
          const SizedBox(height: 8),
          _buildInfoRow(context, Icons.email, 'Email', customer['email']),
          const SizedBox(height: 8),
          _buildInfoRow(context, Icons.phone, 'Contact', customer['contact']),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            Icons.assignment_ind,
            'Assigned To',
            customer['assignedTo'],
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            context,
            Icons.person_add,
            'Created By',
            customer['createdBy'],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).iconTheme.color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Theme.of(context).iconTheme.color?.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No customers found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    // Filters removed from Property Finder per request
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Filters are not available on this screen',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _applyFilters() {}

  void _clearFilters() {}

  void _handleCustomerAction(String action, Map<String, dynamic> customer) {
    switch (action) {
      case 'view':
        _showCustomerDetails(customer);
        break;
      case 'edit':
        // TODO: Navigate to edit customer screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Edit ${customer['name']}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(customer);
        break;
    }
  }

  void _showCustomerDetails(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Customer Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${customer['name']}'),
            Text('Email: ${customer['email']}'),
            Text('Contact: ${customer['contact']}'),
            Text('Assigned To: ${customer['assignedTo']}'),
            Text('Created By: ${customer['createdBy']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Data removal disabled: Property Finder no longer shows a list
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${customer['name']} deleted'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _QuickStat {
  const _QuickStat({
    required this.label,
    required this.count,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color iconColor;
}
