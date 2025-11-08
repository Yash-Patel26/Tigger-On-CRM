import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../data/services/database_service.dart';
import '../../../data/models/ticket_model.dart';
import '../widgets/lead_detail_tabs/create_ticket_form.dart';

class TicketHubScreen extends StatefulWidget {
  const TicketHubScreen({super.key});

  @override
  State<TicketHubScreen> createState() => _TicketHubScreenState();
}

class _TicketHubScreenState extends State<TicketHubScreen> {
  List<Ticket> _tickets = [];
  bool _isLoading = true;
  String? _error;
  bool _isRefreshing = false;

  // Filters
  String? _filterStatus;
  String? _filterPriority;
  String? _filterAssignee;
  String? _filterAging; // e.g., Today, 1-3 days, 7+ days
  DateTimeRange? _filterRange;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    if (!_isRefreshing) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      // Get current user ID to filter tickets assigned to this user
      final client = supabase.Supabase.instance.client;
      final currentUser = client.auth.currentUser;
      final currentUserId = currentUser?.id;

      if (currentUserId == null) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
          _isRefreshing = false;
        });
        return;
      }

      // Convert filter strings to enums
      TicketStatus? statusFilter;
      if (_filterStatus != null && _filterStatus!.isNotEmpty) {
        statusFilter = TicketStatus.values.firstWhere(
          (s) => s.displayName.toLowerCase() == _filterStatus!.toLowerCase(),
          orElse: () => TicketStatus.open,
        );
      }

      TicketPriority? priorityFilter;
      if (_filterPriority != null && _filterPriority!.isNotEmpty) {
        priorityFilter = TicketPriority.values.firstWhere(
          (p) => p.displayName.toLowerCase() == _filterPriority!.toLowerCase(),
          orElse: () => TicketPriority.medium,
        );
      }

      // Apply date range filters
      DateTime? fromDate;
      DateTime? toDate;
      if (_filterRange != null) {
        fromDate = _filterRange!.start;
        toDate = _filterRange!.end;
      }

      // Filter tickets by current user ID (assigned to this user) using DatabaseService
      final tickets = await DatabaseService.getTickets(
        status: statusFilter,
        priority: priorityFilter,
        assignedTo: currentUserId, // Filter by current user's ID
        fromDate: fromDate,
        toDate: toDate,
        page: 1,
        limit: 1000, // Get all tickets for now
      );

      setState(() {
        _tickets = tickets;
        _isLoading = false;
        _isRefreshing = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading tickets: $e';
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  Future<void> _refreshTickets() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadTickets();
  }

  // Convert Ticket to Map for UI compatibility
  Map<String, dynamic> _ticketToMap(Ticket ticket) {
    return {
      'id': ticket.ticketNumber,
      'mobile': ticket.contactMobile,
      'datetime': ticket.createdAt,
      'serviceType': ticket.serviceType.displayName,
      'assignee': ticket.assignedToName ?? 'Unassigned',
      'priority': ticket.priority.displayName,
      'status': ticket.status.displayName,
      'ticket': ticket, // Keep original ticket object for detail view
    };
  }

  @override
  Widget build(BuildContext context) {
    // Convert tickets to map format and apply filters
    final List<Map<String, dynamic>> ticketMaps = _tickets
        .map(_ticketToMap)
        .toList();
    final List<Map<String, dynamic>> filtered = _applyFilters(ticketMaps);
    final int totalToday = filtered
        .where(
          (Map<String, dynamic> t) =>
              _isSameDay(t['datetime'] as DateTime, DateTime.now()),
        )
        .length;
    final int totalAll = filtered.length;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text('Tickets'),
        actions: <Widget>[
          IconButton(
            onPressed: _refreshTickets,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          IconButton(
            onPressed: _openCreateTicket,
            icon: const Icon(Icons.add_circle_rounded),
            tooltip: 'Create',
          ),
          IconButton(
            onPressed: _openFilters,
            icon: const Icon(Icons.filter_alt_rounded),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTickets,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshTickets,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  _buildKpis(totalToday: totalToday, totalAll: totalAll),
                  const SizedBox(height: 16),
                  if (filtered.isEmpty)
                    _buildEmptyState()
                  else
                    ...filtered.map(_buildTicketCard),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }

  Widget _buildKpis({required int totalToday, required int totalAll}) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
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
          child: Row(
            children: <Widget>[
              Expanded(
                child: _kpiTile(
                  'Today\'s Tickets',
                  totalToday.toString(),
                  Icons.today_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.withOpacity(0.1),
              ),
              Expanded(
                child: _kpiTile(
                  'Total Tickets',
                  totalAll.toString(),
                  Icons.confirmation_number_rounded,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _kpiTile(String label, String value, IconData icon) {
    return Column(
      children: <Widget>[
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildTicketCard(Map<String, dynamic> t) {
    final DateTime dt = t['datetime'] as DateTime;
    final String dateStr =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final String timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return Builder(
      builder: (BuildContext context) {
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
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      t['id'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _chip(
                    t['priority'] as String,
                    _priorityColor(t['priority'] as String),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.phone_iphone,
                    color: Colors.white54,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    t['mobile'] as String,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.access_time_rounded,
                    color: Colors.white54,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$dateStr $timeStr',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  _infoIconText(
                    Icons.build_rounded,
                    t['serviceType'] as String,
                  ),
                  const SizedBox(width: 16),
                  _infoIconText(
                    Icons.person_outline_rounded,
                    'Assign: ${t['assignee']}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: () => _showTicketDetail(context, t),
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('View'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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

  Widget _infoIconText(IconData icon, String text) {
    return Row(
      children: <Widget>[
        Icon(icon, color: Theme.of(context).iconTheme.color, size: 16),
        const SizedBox(width: 6),
        Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Builder(
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
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
          child: const Center(
            child: Text('No tickets found', style: TextStyle()),
          ),
        );
      },
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _priorityColor(String p) {
    switch (p.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  List<Map<String, dynamic>> _applyFilters(List<Map<String, dynamic>> source) {
    return source.where((Map<String, dynamic> t) {
      final DateTime dt = t['datetime'] as DateTime;

      // Status filter
      if (_filterStatus != null &&
          _filterStatus!.isNotEmpty &&
          t['status'] != _filterStatus) {
        return false;
      }

      // Priority filter
      if (_filterPriority != null &&
          _filterPriority!.isNotEmpty &&
          t['priority'] != _filterPriority) {
        return false;
      }

      // Assignee filter
      if (_filterAssignee != null &&
          _filterAssignee!.isNotEmpty &&
          t['assignee'] != _filterAssignee) {
        return false;
      }

      // Aging filter
      if (_filterAging != null && _filterAging!.isNotEmpty) {
        final Duration age = DateTime.now().difference(dt);
        final bool ok = switch (_filterAging) {
          'Today' => age.inDays == 0,
          '1-3 days' => age.inDays >= 1 && age.inDays <= 3,
          '7+ days' => age.inDays >= 7,
          _ => true,
        };
        if (!ok) return false;
      }

      // Date range filter
      if (_filterRange != null) {
        if (dt.isBefore(_filterRange!.start) || dt.isAfter(_filterRange!.end)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        String? status = _filterStatus;
        String? priority = _filterPriority;
        String? assignee = _filterAssignee;
        String? aging = _filterAging;
        DateTimeRange? range = _filterRange;
        return StatefulBuilder(
          builder:
              (
                BuildContext context,
                void Function(void Function()) setModalState,
              ) {
                final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;
                return SafeArea(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      16 + viewInsets.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: const <Widget>[
                            Text(
                              'Filters',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _dropdownField(
                          label: 'Status',
                          value: status,
                          items: TicketStatus.values
                              .map((s) => s.displayName)
                              .toList(),
                          onChanged: (String? v) =>
                              setModalState(() => status = v),
                        ),
                        const SizedBox(height: 8),
                        _dropdownField(
                          label: 'Priority',
                          value: priority,
                          items: TicketPriority.values
                              .map((p) => p.displayName)
                              .toList(),
                          onChanged: (String? v) =>
                              setModalState(() => priority = v),
                        ),
                        const SizedBox(height: 8),
                        _dropdownField(
                          label: 'Assign to',
                          value: assignee,
                          items:
                              _tickets
                                  .where((t) => t.assignedToName != null)
                                  .map((t) => t.assignedToName!)
                                  .toSet()
                                  .toList()
                                ..sort(),
                          onChanged: (String? v) =>
                              setModalState(() => assignee = v),
                        ),
                        const SizedBox(height: 8),
                        _dropdownField(
                          label: 'Aging',
                          value: aging,
                          items: const <String>['Today', '1-3 days', '7+ days'],
                          onChanged: (String? v) =>
                              setModalState(() => aging = v),
                        ),
                        const SizedBox(height: 8),
                        _dateRangeField(
                          label: 'Calendar',
                          value: range,
                          onPick: () async {
                            final DateTime now = DateTime.now();
                            final DateTimeRange? picked =
                                await showDateRangePicker(
                                  context: context,
                                  firstDate: DateTime(now.year - 1),
                                  lastDate: DateTime(now.year + 1),
                                  currentDate: now,
                                  builder:
                                      (BuildContext context, Widget? child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: const ColorScheme.dark(
                                              primary: Colors.red,
                                              onPrimary: Colors.white,
                                              surface: Color(0xFF121212),
                                              onSurface: Colors.white,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                );
                            if (picked != null) {
                              setModalState(() => range = picked);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _filterStatus = null;
                                    _filterPriority = null;
                                    _filterAssignee = null;
                                    _filterAging = null;
                                    _filterRange = null;
                                  });
                                  Navigator.of(ctx).pop();
                                  // Reload tickets without filters
                                  _loadTickets();
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white24),
                                ),
                                child: const Text('Clear'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _filterStatus = status;
                                    _filterPriority = priority;
                                    _filterAssignee = assignee;
                                    _filterAging = aging;
                                    _filterRange = range;
                                  });
                                  Navigator.of(ctx).pop();
                                  // Reload tickets with new filters
                                  _loadTickets();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Apply'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
        );
      },
    );
  }

  Widget _dropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: items
              .map(
                (String e) =>
                    DropdownMenuItem<String>(value: e, child: Text(e)),
              )
              .toList(),
          dropdownColor: const Color(0xFF1E1E1E),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1E1E1E),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _dateRangeField({
    required String label,
    required DateTimeRange? value,
    required VoidCallback onPick,
  }) {
    String text;
    if (value == null) {
      text = 'Select range';
    } else {
      final String start =
          '${value.start.year}-${value.start.month}-${value.start.day}';
      final String end =
          '${value.end.year}-${value.end.month}-${value.end.day}';
      text = '$start → $end';
    }
    return Builder(
      builder: (BuildContext context) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final Color borderClr = isDark
            ? Colors.white24
            : const Color(0x22000000);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderClr),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.calendar_month_rounded,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    const SizedBox(width: 8),
                    Text(text),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openCreateTicket() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (BuildContext ctx) {
        return CreateTicketForm(
          initialLeadId: null, // No initial lead ID in ticket hub
          onTicketCreated: () {
            Navigator.of(ctx).pop();
            // Refresh tickets list after creation
            _loadTickets();
          },
        );
      },
    );
  }

  void _showTicketDetail(BuildContext context, Map<String, dynamic> ticketMap) {
    final Ticket? ticket = ticketMap['ticket'] as Ticket?;
    if (ticket == null) return;

    final DateTime dt = ticket.createdAt;
    final String dateStr =
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    final String timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    final String status = ticket.status.displayName;
    final String priority = ticket.priority.displayName;
    final Color priorityColor = _priorityColor(priority);
    final Color statusColor = _statusColor(status);

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  ticket.ticketNumber,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                tooltip: 'Close',
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Status and Priority
                  Row(
                    children: <Widget>[
                      Expanded(child: _chip('Status: $status', statusColor)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _chip('Priority: $priority', priorityColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Contact Name
                  if (ticket.contactName.isNotEmpty)
                    _detailRow(
                      Icons.person,
                      'Contact Name',
                      ticket.contactName,
                    ),
                  if (ticket.contactName.isNotEmpty) const SizedBox(height: 12),
                  // Mobile Number
                  _detailRow(
                    Icons.phone_iphone,
                    'Mobile Number',
                    ticket.contactMobile,
                  ),
                  const SizedBox(height: 12),
                  // Date and Time
                  _detailRow(
                    Icons.access_time_rounded,
                    'Date & Time',
                    '$dateStr $timeStr',
                  ),
                  const SizedBox(height: 12),
                  // Service Type
                  _detailRow(
                    Icons.build_rounded,
                    'Service Type',
                    ticket.serviceType.displayName,
                  ),
                  const SizedBox(height: 12),
                  // Assignee
                  _detailRow(
                    Icons.person_outline_rounded,
                    'Assigned To',
                    ticket.assignedToName ?? 'Unassigned',
                  ),
                  if (ticket.issueTitle.isNotEmpty) const SizedBox(height: 12),
                  // Issue Title
                  if (ticket.issueTitle.isNotEmpty)
                    _detailRow(Icons.title, 'Issue Title', ticket.issueTitle),
                  if (ticket.issueDescription.isNotEmpty)
                    const SizedBox(height: 12),
                  // Issue Description
                  if (ticket.issueDescription.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Issue Description',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticket.issueDescription,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  // Divider
                  Divider(color: Colors.grey.withOpacity(0.2), height: 24),
                  // Additional Info Section
                  Text(
                    'Ticket Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This ticket was created on $dateStr at $timeStr. '
                    'It is currently ${status.toLowerCase()} with ${priority.toLowerCase()} priority.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
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

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'in progress':
        return Colors.orange;
      case 'closed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
