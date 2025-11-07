import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../../shared/utils/helpers.dart';
import '../../../../shared/managers/auth_state_manager.dart';
import '../../../../core/utils/page_transitions.dart';
import '../../../../data/repositories/lead_repository.dart';
import 'create_lead_screen.dart';
import 'lead_detail_screen.dart';
import '../projects/add_site_visit_screen.dart';
import '../../../../data/services/database_service.dart';
import '../../../../data/models/models.dart';
// import '../../../../data/services/database_service_masters.dart' as masters;
// assign dialog implemented locally in this file for lead list

// Lead data model for pagination - extends Lead model
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
  final DateTime? lastFollowUpDate;
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
    this.lastFollowUpDate,
    this.hasSiteVisit = false,
  });

  factory LeadData.fromLead(Lead lead) {
    return LeadData(
      id: lead.id,
      leadId: lead.leadId,
      customerName: lead.customerName,
      phone: lead.phone,
      projectName: lead.projectName ?? 'No Project',
      assignedTo: lead.assignedTo,
      assignedToName: lead.assignedToName,
      status: lead.status.name,
      subStatus: lead.subStatus.name,
      timeAgo: _getTimeAgo(lead.createdAt),
      createdAt: lead.createdAt,
      lastFollowUpDate: lead.lastFollowUpDate,
      hasSiteVisit: lead.hasSiteVisit,
    );
  }

  static String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }
}

class LeadScreen extends StatefulWidget {
  const LeadScreen({super.key});

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

enum FollowUpFilter { all, today, thisWeek, overdue }

class _LeadScreenState extends State<LeadScreen> {
  // Real data from API
  int todaysFollowUp = 0;
  int todaysLead = 0;
  int totalFollowUp = 0;
  int totalLead = 0;
  int totalDuplicateVisits = 0;

  String _search = '';
  String? _filterStatus; // 'Hot' | 'Warm' | 'Cold' | null
  bool? _filterWithVisits; // true | false | null
  final FollowUpFilter _followUpFilter = FollowUpFilter.all;

  // Search debouncing
  Timer? _searchDebounceTimer;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  // Pagination (explicit page navigation)
  int _pageSize = 8;
  int _currentPage = 1; // 1-based
  List<LeadData> _pageItems = <LeadData>[];
  bool _isLoading = false;
  String? _error;
  int _totalPages = 0;

  final LeadRepository _leadRepository = LeadRepository();

  // Realtime subscription for lead updates
  supabase.RealtimeChannel? _leadsRealtimeChannel;
  bool _isRealtimeConnected = false;

  @override
  void initState() {
    super.initState();
    _loadPage(_currentPage);
    _loadStats();
    _subscribeToLeadUpdates();
  }

  @override
  void dispose() {
    _leadsRealtimeChannel?.unsubscribe();
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));

      // Load all leads to calculate stats
      final authManager = Provider.of<AuthStateManager>(context, listen: false);
      final bool isPrivileged = authManager.isAdminOrHead;
      final String? currentUserId = Helpers.getCurrentUserId();
      final response = await _leadRepository.getLeads(
        page: 1,
        limit: 1000, // Get more leads to calculate accurate stats
        assignedTo: isPrivileged ? null : currentUserId,
      );

      if (response.success && response.data != null) {
        final leads = response.data!;

        // Calculate stats
        int todaysLeadCount = 0;
        int todaysFollowUpCount = 0;
        int totalFollowUpCount = 0;
        int duplicateVisitsCount = 0;

        for (final lead in leads) {
          // Count today's leads
          if (lead.createdAt.isAfter(todayStart) &&
              lead.createdAt.isBefore(todayEnd)) {
            todaysLeadCount++;
          }

          // Count follow-ups
          if (lead.nextFollowUpDate != null) {
            totalFollowUpCount++;
            if (lead.nextFollowUpDate!.isAfter(todayStart) &&
                lead.nextFollowUpDate!.isBefore(todayEnd)) {
              todaysFollowUpCount++;
            }
          }

          // Count duplicate visits
          if (lead.isDuplicate) {
            duplicateVisitsCount++;
          }
        }

        setState(() {
          totalLead = leads.length;
          todaysLead = todaysLeadCount;
          todaysFollowUp = todaysFollowUpCount;
          totalFollowUp = totalFollowUpCount;
          totalDuplicateVisits = duplicateVisitsCount;
        });
      }
    } catch (e) {
      print('Error loading stats: $e');
      // Keep existing values on error
    }
  }

  Future<void> _loadPage(int page) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Convert filter values to LeadStatus enum
      LeadStatus? statusFilter;
      if (_filterStatus != null) {
        switch (_filterStatus!.toLowerCase()) {
          case 'hot':
            statusFilter = LeadStatus.hot;
            break;
          case 'warm':
            statusFilter = LeadStatus.warm;
            break;
          case 'cold':
            statusFilter = LeadStatus.cold;
            break;
        }
      }

      final authManager = Provider.of<AuthStateManager>(context, listen: false);
      final bool isPrivileged = authManager.isAdminOrHead;
      final String? currentUserId = Helpers.getCurrentUserId();

      final response = await _leadRepository.getLeads(
        search: _search.isNotEmpty ? _search : null,
        status: statusFilter,
        page: page,
        limit: _pageSize,
        forceRefresh: true, // Force refresh to get latest data
        assignedTo: isPrivileged ? null : currentUserId,
      );

      if (response.success && response.data != null) {
        final leads = response.data!;
        final leadDataList = leads
            .map((lead) => LeadData.fromLead(lead))
            .toList();

        setState(() {
          _pageItems = leadDataList;
          _currentPage = page;
          _isLoading = false;
          _isSearching = false;
          // Calculate total pages (this would come from API response in real implementation)
          _totalPages = (totalLead / _pageSize).ceil();
        });
      } else {
        setState(() {
          _error = response.message ?? response.error ?? 'Failed to load leads';
          _isLoading = false;
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading leads: $e';
        _isLoading = false;
        _isSearching = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _search = value;
      _isSearching = value.isNotEmpty;
    });

    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    // Set new timer for debounced search
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadPage(1); // Reset to first page when searching
    });
  }

  void _clearSearch() {
    setState(() {
      _search = '';
      _isSearching = false;
    });
    _searchController.clear();
    _loadPage(1);
  }

  void _subscribeToLeadUpdates() {
    // Listen for lead updates in real-time
    final client = supabase.Supabase.instance.client;
    _leadsRealtimeChannel = client.channel('public:leads_list');

    _leadsRealtimeChannel!
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.update,
          schema: 'public',
          table: 'leads',
          callback: (supabase.PostgresChangePayload payload) {
            if (!mounted) return;
            print('Real-time lead update received in lead list');
            print(
              'Payload event: ${payload.eventType}, old: ${payload.oldRecord}, new: ${payload.newRecord}',
            );

            // Refresh the current page and stats when any lead is updated
            _loadPage(_currentPage);
            _loadStats();
          },
        )
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.insert,
          schema: 'public',
          table: 'leads',
          callback: (supabase.PostgresChangePayload payload) {
            if (!mounted) return;
            print('Real-time lead insert received in lead list');
            print(
              'Payload event: ${payload.eventType}, old: ${payload.oldRecord}, new: ${payload.newRecord}',
            );

            // Refresh the current page and stats when a new lead is created
            _loadPage(_currentPage);
            _loadStats();
          },
        )
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.delete,
          schema: 'public',
          table: 'leads',
          callback: (supabase.PostgresChangePayload payload) {
            if (!mounted) return;
            print('Real-time lead delete received in lead list');
            print(
              'Payload event: ${payload.eventType}, old: ${payload.oldRecord}, new: ${payload.newRecord}',
            );

            // Refresh the current page and stats when a lead is deleted
            _loadPage(_currentPage);
            _loadStats();
          },
        )
        .subscribe();

    // Set connection status after subscription
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isRealtimeConnected = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leads'),
        actions: <Widget>[
          // Real-time connection indicator
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isRealtimeConnected ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: _isRealtimeConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  _isRealtimeConnected ? 'Live' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isRealtimeConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadPage(_currentPage); // Refresh current page
              _loadStats(); // Refresh stats
            },
          ),
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
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search leads by name, id, project...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _search.isNotEmpty
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isSearching && _search.isNotEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: _clearSearch,
                                  tooltip: 'Clear search',
                                ),
                              ],
                            )
                          : null,
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
                  // Count display with search indicator
                  Text(
                    _search.isNotEmpty
                        ? 'Search results: ${_pageItems.length}'
                        : 'Count: ${_pageItems.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _search.isNotEmpty
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Paged list (explicit navigation)
          Expanded(child: _buildLeadList()),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: _currentPage > 1 && !_isLoading
                      ? () => _loadPage(_currentPage - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Previous'),
                ),
                const SizedBox(width: 12),
                Text(
                  'Page $_currentPage${_totalPages > 0 ? ' of $_totalPages' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _currentPage < _totalPages && !_isLoading
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

  Widget _buildLeadList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading leads...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading leads',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadPage(_currentPage),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_pageItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _search.isNotEmpty ? Icons.search_off : Icons.inbox_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              _search.isNotEmpty ? 'No search results found' : 'No leads found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _search.isNotEmpty
                  ? 'Try different search terms or clear the search'
                  : 'Try adjusting your filters',
              style: const TextStyle(color: Colors.grey),
            ),
            if (_search.isNotEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _pageItems.length,
      itemBuilder: (BuildContext context, int index) {
        final LeadData lead = _pageItems[index];
        // Search filter
        if (_search.isNotEmpty &&
            !lead.leadId.toLowerCase().contains(_search.toLowerCase()) &&
            !lead.customerName.toLowerCase().contains(_search.toLowerCase()) &&
            !lead.projectName.toLowerCase().contains(_search.toLowerCase())) {
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
              return lead.lastFollowUpDate?.year == now.year &&
                  lead.lastFollowUpDate?.month == now.month &&
                  lead.lastFollowUpDate?.day == now.day;
            case FollowUpFilter.thisWeek:
              final DateTime start = now.subtract(
                Duration(days: now.weekday - 1),
              );
              final DateTime end = start.add(const Duration(days: 7));
              return lead.lastFollowUpDate?.isAfter(start) == true &&
                  lead.lastFollowUpDate?.isBefore(end) == true;
            case FollowUpFilter.overdue:
              return lead.lastFollowUpDate?.isBefore(
                    DateTime(now.year, now.month, now.day),
                  ) ==
                  true;
          }
        }();
        if (!include) return const SizedBox.shrink();
        return _LeadCard(leadData: lead, index: index);
      },
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
                trailing: Text(
                  '${_pageItems.where((lead) => lead.status == LeadStatus.hot).length}',
                ),
              ),
              ListTile(
                title: const Text('Warm Leads'),
                trailing: Text(
                  '${_pageItems.where((lead) => lead.status == LeadStatus.warm).length}',
                ),
              ),
              ListTile(
                title: const Text('Cold Leads'),
                trailing: Text(
                  '${_pageItems.where((lead) => lead.status == LeadStatus.cold).length}',
                ),
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
          // Header line: Name (left) and Lead ID (right) baseline-aligned
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Text(
                  leadData.customerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      leadData.leadId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Two-column body below the header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Left section - Customer details (without name)
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
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
                      leadData.lastFollowUpDate != null
                          ? _formatDateTime(leadData.lastFollowUpDate!)
                          : 'No follow-up',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              // Right section - status info (without ID)
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
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
                    // Visit icon with visit marker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Icon(
                          Icons.visibility_outlined,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: _LeadVisitInline(leadId: leadData.leadId),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bottom action buttons - Two rows to prevent overflow
          Column(
            children: <Widget>[
              // First row - View and Assign
              Row(
                children: <Widget>[
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
                  Consumer<AuthStateManager>(
                    builder: (context, authManager, _) {
                      if (authManager.isAdminOrHead) {
                        return Expanded(
                          child: FilledButton.icon(
                            onPressed: () =>
                                _showAssignDialog(context, leadData.leadId),
                            icon: const Icon(
                              Icons.assignment_ind_outlined,
                              size: 16,
                            ),
                            label: const Text('Assign'),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Second row - Site Visit and Call
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          SmoothPageTransitions.slideFromBottom<void>(
                            child: AddSiteVisitScreen(leadId: leadData.leadId),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add_location_alt_outlined,
                        size: 16,
                      ),
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
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        await Helpers.placeCallAndLog(
                          phone: leadData.phone,
                          leadId: leadData.id,
                          direction: 'outbound',
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Call completed')),
                          );
                        }
                      },
                      icon: const Icon(Icons.call_outlined, size: 16),
                      label: const Text('Call'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
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

class _LeadVisitInline extends StatelessWidget {
  const _LeadVisitInline({required this.leadId});
  final String leadId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SiteVisit>>(
      future: DatabaseService.getSiteVisits(leadId: leadId, limit: 1),
      builder: (BuildContext context, AsyncSnapshot<List<SiteVisit>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 12,
            width: 12,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }
        if (snapshot.hasError) {
          return const Text('-', style: TextStyle(fontSize: 14));
        }
        final List<SiteVisit> visits = snapshot.data ?? <SiteVisit>[];
        if (visits.isEmpty) {
          return const Text('No visits', style: TextStyle(fontSize: 14));
        }
        // Show the actual visit date instead of "Has visit"
        final visit = visits.first;
        final visitDate = visit.meetingFrom ?? visit.createdAt;
        return Text(
          _formatShortDateTime(visitDate),
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        );
      },
    );
  }

  String _formatShortDateTime(DateTime dateTime) {
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
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$day $month $displayHour:$minute $period';
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

  // Real data from database
  List<String> _projectOptions = <String>['Any'];
  bool _isLoadingProjects = true;
  String budgetType = 'Any';
  bool withVisits = false;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final List<Project> projects = await DatabaseService.getProjects();
      final List<String> projectNames = projects.map((p) => p.name).toList();
      setState(() {
        _projectOptions = ['Any', ...projectNames];
        _isLoadingProjects = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProjects = false;
      });
    }
  }

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
              _isLoadingProjects
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _Dropdown(
                      label: 'Project',
                      value: project,
                      items: _projectOptions,
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

// Assign dialog functionality for lead cards
void _showAssignDialog(BuildContext context, String leadId) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return _AssignLeadDialog(leadId: leadId);
    },
  );
}

class _AssignLeadDialog extends StatefulWidget {
  const _AssignLeadDialog({required this.leadId});
  final String leadId;

  @override
  State<_AssignLeadDialog> createState() => _AssignLeadDialogState();
}

class _AssignLeadDialogState extends State<_AssignLeadDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descCtrl = TextEditingController();
  String? _selectedUserId;
  String _selectedUserName = '';

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateManager>(
      builder: (context, authManager, _) {
        if (!authManager.isAdminOrHead) {
          return AlertDialog(
            title: const Text('Access Denied'),
            content: const Text('Only admin and head users can assign leads.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        }

        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text('Assign Lead'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520, minWidth: 320),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Assign To'),
                  const SizedBox(height: 6),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future:
                        DatabaseServiceUsersAndDisposition.getAssignableUsers(),
                    builder:
                        (
                          BuildContext context,
                          AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
                        ) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          final String? currentUserId =
                              Helpers.getCurrentUserId();
                          // Raw list
                          List<Map<String, dynamic>> users =
                              snapshot.data ?? <Map<String, dynamic>>[];
                          // Exclude admin/head from assignees if role field present
                          users = users.where((u) {
                            final role = (u['role'] as String?)?.toLowerCase();
                            if (role == 'admin' || role == 'head') return false;
                            return true;
                          }).toList();
                          // Prevent assigning to self (especially for admin/head)
                          users = users
                              .where(
                                (u) => (u['id'] as String?) != currentUserId,
                              )
                              .toList();

                          return DropdownButtonFormField<String>(
                            initialValue: _selectedUserId,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Select user',
                            ),
                            items: users.map((Map<String, dynamic> user) {
                              final role = user['role'] as String?;
                              return DropdownMenuItem<String>(
                                value: user['id'] as String,
                                child: Text(
                                  role != null && role.isNotEmpty
                                      ? '${user['name']} (${role.toString()})'
                                      : (user['name'] as String),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _selectedUserId = value;
                                _selectedUserName =
                                    users.firstWhere(
                                          (Map<String, dynamic> user) =>
                                              user['id'] == value,
                                        )['name']
                                        as String;
                              });
                            },
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a user';
                              }
                              // Block self-assign as an extra guard
                              if (value == Helpers.getCurrentUserId()) {
                                return 'You cannot assign a lead to yourself';
                              }
                              return null;
                            },
                          );
                        },
                  ),
                  const SizedBox(height: 12),
                  const Text('Description'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Assignment description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(onPressed: _onAssign, child: const Text('Assign')),
          ],
        );
      },
    );
  }

  void _onAssign() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop();

    if (_selectedUserId != null) {
      _assignLead();
    }
  }

  Future<void> _assignLead() async {
    try {
      // First, resolve the human-readable lead ID to UUID
      final Lead? lead = await DatabaseService.getLeadById(widget.leadId);
      if (lead == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Lead not found')));
        }
        return;
      }

      // Store old assignee for logging
      final String oldAssignee = lead.assignedToName;

      await DatabaseService.updateLeadAssignment(
        leadId: lead.id, // Use the UUID instead of human-readable ID
        assignedToId: _selectedUserId!,
        assignedToName: _selectedUserName,
      );

      // Log the assignment change for timeline/activity tracking
      await DatabaseServiceMasters.logLeadAssignment(
        leadId: lead.id,
        oldAssignee: oldAssignee,
        newAssignee: _selectedUserName,
        performedBy: Helpers.getCurrentUserId() ?? 'system',
        performedByName: await Helpers.getCurrentUserName(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Assigned to $_selectedUserName')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to assign: $e')));
      }
    }
  }
}
