import 'package:flutter/material.dart';
import '../utils/helpers.dart';
import '../utils/page_transitions.dart';
import 'create_lead_screen.dart';
import 'lead_detail_screen.dart';
import 'add_site_visit_screen.dart';
// assign dialog implemented locally in this file for lead list

// Lead data model for pagination
class LeadData {
  final String id;
  final String leadId;
  final String customerName;
  final String phone;
  final String projectName;
  final String assignedTo;
  final String assignedToName;
  final String status;
  final String subStatus;
  final String timeAgo;
  final DateTime createdAt;
  final DateTime lastFollowUpDate;
  final bool hasSiteVisit;

  const LeadData({
    required this.id,
    required this.leadId,
    required this.customerName,
    required this.phone,
    required this.projectName,
    required this.assignedTo,
    required this.assignedToName,
    required this.status,
    required this.subStatus,
    required this.timeAgo,
    required this.createdAt,
    required this.lastFollowUpDate,
    this.hasSiteVisit = false,
  });
}

class LeadScreen extends StatefulWidget {
  const LeadScreen({super.key});

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

enum FollowUpFilter { all, today, thisWeek, overdue }

class _LeadScreenState extends State<LeadScreen> {
  // Demo counts; replace with real data
  int todaysFollowUp = 3;
  int todaysLead = 7;
  int totalFollowUp = 42;
  int totalLead = 256;
  int totalDuplicateVisits = 5;

  String _search = '';
  String? _filterStatus; // 'Hot' | 'Warm' | 'Cold' | null
  bool? _filterWithVisits; // true | false | null
  final FollowUpFilter _followUpFilter = FollowUpFilter.all;

  // Pagination (explicit page navigation)
  int _pageSize = 8;
  int _currentPage = 1; // 1-based
  List<LeadData> _pageItems = <LeadData>[];

  @override
  void initState() {
    super.initState();
    _loadPage(_currentPage);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadPage(int page) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Generate mock data for the page
      final List<LeadData> newItems = [];
      final startIndex = (page - 1) * _pageSize;
      final endIndex = startIndex + _pageSize;

      for (int i = startIndex; i < endIndex; i++) {
        // Simulate total of 1000 leads
        if (i >= 1000) break;

        final now = DateTime.now();
        final createdDate = now.subtract(Duration(days: i % 7));
        final followUpDate = now.subtract(Duration(hours: i % 24));

        newItems.add(
          LeadData(
            id: i.toString(),
            leadId:
                'RELRC-${String.fromCharCode(65 + (i % 26))}${String.fromCharCode(65 + ((i ~/ 26) % 26))}${String.fromCharCode(65 + ((i ~/ 676) % 26))}${String.fromCharCode(65 + ((i ~/ 17576) % 26))}${String.fromCharCode(65 + ((i ~/ 456976) % 26))}-${(10000 + i).toString().padLeft(5, '0')}',
            customerName: i == 0 ? 'Mayank11' : 'Customer ${i + 1}',
            phone: i == 0 ? '9816353871' : '${9000000000 + i}',
            projectName: i == 0
                ? '4s The Aurrum'
                : 'Project ${i % 3 == 0
                      ? 'Alpha'
                      : i % 3 == 1
                      ? 'Beta'
                      : 'Gamma'}',
            assignedTo: 'user_${i % 5 + 1}',
            assignedToName: i == 0
                ? 'Anita(Counsellor)(A-1)'
                : 'User ${i % 5 + 1}',
            status: i % 3 == 0
                ? 'Hot'
                : i % 3 == 1
                ? 'Warm'
                : 'Cold',
            subStatus: i % 2 == 0 ? 'New' : 'In Progress',
            timeAgo: i == 0
                ? 'Yesterday'
                : i % 3 == 0
                ? 'Today'
                : i % 3 == 1
                ? '2 days ago'
                : '3 days ago',
            createdAt: createdDate,
            lastFollowUpDate: followUpDate,
            hasSiteVisit: i % 4 == 0,
          ),
        );
      }

      setState(() {
        _pageItems = newItems;
        _currentPage = page;
      });
    } catch (error) {
      // In real app, show error UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Call History',
            icon: const Icon(Icons.history_toggle_off),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Call history not available')),
              );
            },
          ),
          IconButton(
            tooltip: 'Create Lead',
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              Navigator.of(context).push(
                SmoothPageTransitions.slideFromBottom<void>(
                  child: const CreateLeadScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Filters',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Fixed header with metrics and search
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                _MetricsRow(
                  items: <_MetricItem>[
                    _MetricItem(
                      'Today\'s Follow-up',
                      todaysFollowUp,
                      Icons.event_available,
                    ),
                    _MetricItem(
                      'Today\'s Lead',
                      todaysLead,
                      Icons.person_add_alt_1,
                    ),
                    _MetricItem(
                      'Total Follow-up',
                      totalFollowUp,
                      Icons.pending_actions,
                    ),
                    _MetricItem('Total Lead', totalLead, Icons.leaderboard),
                    _MetricItem(
                      'Duplicate Visits',
                      totalDuplicateVisits,
                      Icons.copy_all_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    onChanged: (String value) {
                      setState(() => _search = value);
                      _loadPage(_currentPage);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search leads by name, id, project...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          // Controls row (page size, follow up, sort, disposition)
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  // Page size dropdown
                  GestureDetector(
                    onTap: () => _showPageSizeDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 56,
                        minHeight: 36,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            _pageSize.toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const SizedBox(width: 4),
                  // Sort button
                  GestureDetector(
                    onTap: () => _showSortDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.swap_vert,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            'Sort',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Show disposition count button
                  GestureDetector(
                    onTap: () => _showDispositionCount(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Disposition',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Count display
                  Text(
                    'Count : ${_pageItems.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Paged list (explicit navigation)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: _pageItems.length,
              itemBuilder: (BuildContext context, int index) {
                final LeadData lead = _pageItems[index];
                // Search filter
                if (_search.isNotEmpty &&
                    !lead.leadId.toLowerCase().contains(
                      _search.toLowerCase(),
                    ) &&
                    !lead.customerName.toLowerCase().contains(
                      _search.toLowerCase(),
                    ) &&
                    !lead.projectName.toLowerCase().contains(
                      _search.toLowerCase(),
                    )) {
                  return const SizedBox.shrink();
                }
                // Status filter
                if (_filterStatus != null &&
                    lead.status.toLowerCase() != _filterStatus!.toLowerCase()) {
                  return const SizedBox.shrink();
                }
                // With visits filter
                if (_filterWithVisits != null &&
                    lead.hasSiteVisit != _filterWithVisits) {
                  return const SizedBox.shrink();
                }
                // Follow-up filter
                final DateTime now = DateTime.now();
                final bool include = () {
                  switch (_followUpFilter) {
                    case FollowUpFilter.all:
                      return true;
                    case FollowUpFilter.today:
                      return lead.lastFollowUpDate.year == now.year &&
                          lead.lastFollowUpDate.month == now.month &&
                          lead.lastFollowUpDate.day == now.day;
                    case FollowUpFilter.thisWeek:
                      final DateTime start = now.subtract(
                        Duration(days: now.weekday - 1),
                      );
                      final DateTime end = start.add(const Duration(days: 7));
                      return lead.lastFollowUpDate.isAfter(
                            start.subtract(const Duration(seconds: 1)),
                          ) &&
                          lead.lastFollowUpDate.isBefore(end);
                    case FollowUpFilter.overdue:
                      return lead.lastFollowUpDate.isBefore(
                        DateTime(now.year, now.month, now.day),
                      );
                  }
                }();
                if (!include) return const SizedBox.shrink();
                return _LeadCard(leadData: lead, index: index);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: _currentPage > 1
                      ? () => _loadPage(_currentPage - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Previous'),
                ),
                const SizedBox(width: 12),
                Text(
                  'Page $_currentPage',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _pageItems.length == _pageSize
                      ? () => _loadPage(_currentPage + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return const _LeadFiltersSheet();
      },
    );
  }

  // Page size dialog
  void _showPageSizeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text('Select Page Size'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('5'),
                onTap: () {
                  setState(() => _pageSize = 5);
                  _loadPage(_currentPage);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('10'),
                onTap: () {
                  setState(() => _pageSize = 10);
                  _loadPage(_currentPage);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('20'),
                onTap: () {
                  setState(() => _pageSize = 20);
                  _loadPage(_currentPage);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Follow up type dialog removed

  // Sort dialog
  void _showSortDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text('Sort Leads'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Name (A-Z)'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sorted by Name (A-Z)')),
                  );
                },
              ),
              ListTile(
                title: const Text('Name (Z-A)'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sorted by Name (Z-A)')),
                  );
                },
              ),
              ListTile(
                title: const Text('Date (Newest)'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sorted by Date (Newest)')),
                  );
                },
              ),
              ListTile(
                title: const Text('Date (Oldest)'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sorted by Date (Oldest)')),
                  );
                },
              ),
              ListTile(
                title: const Text('Status'),
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sorted by Status')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show disposition count
  void _showDispositionCount(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text('Disposition Count'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Hot Leads'),
                trailing: Text('${(_pageItems.length * 0.3).round()}'),
              ),
              ListTile(
                title: const Text('Warm Leads'),
                trailing: Text('${(_pageItems.length * 0.4).round()}'),
              ),
              ListTile(
                title: const Text('Cold Leads'),
                trailing: Text('${(_pageItems.length * 0.3).round()}'),
              ),
              const Divider(),
              ListTile(
                title: const Text('Total'),
                trailing: Text('${_pageItems.length}'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

// Removed inline _SearchBar; replaced with compact search icon dialog

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.items});
  final List<_MetricItem> items;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final _MetricItem m in items) ...<Widget>[
            _MetricCard(
              label: m.label,
              value: m.value.toString(),
              icon: m.icon,
            ),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}

class _MetricItem {
  const _MetricItem(this.label, this.value, this.icon);
  final String label;
  final int value;
  final IconData icon;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: 190,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _panelColor(context), // 10%
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withOpacity(0.30)), // 30%
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primary.withOpacity(0.60), // 60%
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadCard extends StatelessWidget {
  const _LeadCard({required this.leadData, required this.index});
  final LeadData leadData;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
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
        children: <Widget>[
          // Top row with customer name and lead ID
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Left section - Customer info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Customer name
                    Text(
                      leadData.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Phone number
                    Text(
                      leadData.phone,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 6),
                    // Project with briefcase icon
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.business_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          leadData.projectName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Calendar with checkmark
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '-',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Counsellor info
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            leadData.assignedToName,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Last follow up date
                    Text(
                      _formatDateTime(leadData.lastFollowUpDate),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Right section - Lead ID and status
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    // Lead ID
                    Text(
                      leadData.leadId,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Time ago chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        leadData.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Date and time
                    Text(
                      _formatDateTime(leadData.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    // Building icon with dash
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Icon(
                          Icons.business_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '-',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bottom action buttons
          Row(
            children: <Widget>[
              // View button
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      SmoothPageTransitions.slideFromRight<void>(
                        child: LeadDetailScreen(leadId: leadData.leadId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('View'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Add Site Visit button
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      SmoothPageTransitions.slideFromBottom<void>(
                        child: AddSiteVisitScreen(leadId: leadData.leadId),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_location_alt_outlined, size: 16),
                  label: const Text('Site Visit'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Call button
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    await Helpers.placeCall(leadData.phone);
                    await Future<void>.delayed(const Duration(seconds: 2));
                    final String? url =
                        await Helpers.uploadLastRecordingToSupabase();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            url == null
                                ? 'No recording captured or upload failed'
                                : 'Recording uploaded',
                          ),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.phone_outlined, size: 16),
                  label: const Text('Call'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
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
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$day $month $year $displayHour:$minute $period';
  }
}

// Removed _InfoChip in favor of simple flat rows

class _LeadFiltersSheet extends StatefulWidget {
  const _LeadFiltersSheet();
  @override
  State<_LeadFiltersSheet> createState() => _LeadFiltersSheetState();
}

class _LeadFiltersSheetState extends State<_LeadFiltersSheet> {
  String leadStatus = 'Any';
  String subStatus = 'Any';
  String ndof = 'Any';
  String propertyType = 'Any';
  String categoryType = 'Any';
  String leadSource = 'Any';
  String assignTo = 'Any';
  String project = 'Any';
  String assigningAging = 'Any';
  DateTime? lastUpdate;
  String budgetType = 'Any';
  bool withVisits = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (BuildContext context, ScrollController controller) {
        return SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _Dropdown(
                label: 'Lead status',
                value: leadStatus,
                items: const <String>['Any', 'Hot', 'Warm', 'Cold'],
                onChanged: (String v) => setState(() => leadStatus = v),
              ),
              _Dropdown(
                label: 'Lead sub status',
                value: subStatus,
                items: const <String>['Any', 'New', 'In Progress', 'Closed'],
                onChanged: (String v) => setState(() => subStatus = v),
              ),
              _Dropdown(
                label: 'NDOF',
                value: ndof,
                items: const <String>['Any', '0-7', '8-15', '16-30', '30+'],
                onChanged: (String v) => setState(() => ndof = v),
              ),
              _Dropdown(
                label: 'Property type',
                value: propertyType,
                items: const <String>['Any', 'Residential', 'Commercial'],
                onChanged: (String v) => setState(() => propertyType = v),
              ),
              _Dropdown(
                label: 'Category type',
                value: categoryType,
                items: const <String>['Any', 'A', 'B', 'C'],
                onChanged: (String v) => setState(() => categoryType = v),
              ),
              _Dropdown(
                label: 'Lead source',
                value: leadSource,
                items: const <String>['Any', 'Portal', 'Walk-in', 'Referral'],
                onChanged: (String v) => setState(() => leadSource = v),
              ),
              _Dropdown(
                label: 'Assign to',
                value: assignTo,
                items: const <String>['Any', 'Me', 'Team 1', 'Team 2'],
                onChanged: (String v) => setState(() => assignTo = v),
              ),
              _Dropdown(
                label: 'Project',
                value: project,
                items: const <String>['Any', 'Project Alpha', 'Project Beta'],
                onChanged: (String v) => setState(() => project = v),
              ),
              _Dropdown(
                label: 'Assigning aging',
                value: assigningAging,
                items: const <String>[
                  'Any',
                  '0-3 days',
                  '4-7 days',
                  '8-14 days',
                  '14+ days',
                ],
                onChanged: (String v) => setState(() => assigningAging = v),
              ),
              _DatePicker(
                label: 'Last update date',
                value: lastUpdate,
                onChanged: (DateTime? d) => setState(() => lastUpdate = d),
              ),
              _Dropdown(
                label: 'Budget type',
                value: budgetType,
                items: const <String>['Any', 'Low', 'Medium', 'High'],
                onChanged: (String v) => setState(() => budgetType = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Leads with visits'),
                value: withVisits,
                onChanged: (bool v) => setState(() => withVisits = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          leadStatus = 'Any';
                          subStatus = 'Any';
                          ndof = 'Any';
                          propertyType = 'Any';
                          categoryType = 'Any';
                          leadSource = 'Any';
                          assignTo = 'Any';
                          project = 'Any';
                          assigningAging = 'Any';
                          lastUpdate = null;
                          budgetType = 'Any';
                          withVisits = false;
                        });
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: value,
            items: items
                .map(
                  (String e) =>
                      DropdownMenuItem<String>(value: e, child: Text(e)),
                )
                .toList(),
            onChanged: (String? v) {
              if (v != null) onChanged(v);
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final DateTime now = DateTime.now();
              final DateTime? picked = await showDatePicker(
                context: context,
                firstDate: DateTime(now.year - 5),
                lastDate: DateTime(now.year + 5),
                initialDate: value ?? now,
              );
              onChanged(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: _panelColor(context),
                border: Border.all(color: _panelBorderColor(context)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.event_outlined,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value != null
                          ? '${value!.day}/${value!.month}/${value!.year}'
                          : 'Select date',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color _panelColor(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  // Use unified background palette
  return isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE1F0E4);
}

Color _panelBorderColor(BuildContext context) {
  final Color primary = Theme.of(context).colorScheme.primary;
  return primary.withOpacity(0.30);
}
