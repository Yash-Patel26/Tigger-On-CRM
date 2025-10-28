import 'package:flutter/material.dart';
import 'site_visit_detail_screen.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/models.dart';

class SiteVisitScreen extends StatefulWidget {
  const SiteVisitScreen({super.key});

  @override
  State<SiteVisitScreen> createState() => _SiteVisitScreenState();
}

class _SiteVisitScreenState extends State<SiteVisitScreen> {
  String _search = '';
  Future<List<SiteVisit>>? _siteVisitsFuture;
  Map<String, int> _metrics = {};

  // Pagination state
  int _currentPage = 1;
  int _itemsPerPage = 25;
  int _totalItems = 0;
  final List<int> _pageSizeOptions = [10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    _loadSiteVisits();
  }

  Future<void> _loadSiteVisits() async {
    setState(() {
      _siteVisitsFuture = DatabaseService.getSiteVisits(
        limit: _itemsPerPage,
        page: _currentPage,
      );
    });

    // Load metrics
    await _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    try {
      final List<SiteVisit> visits = await DatabaseService.getSiteVisits(
        limit: 10000,
      );

      // Update total items count
      setState(() {
        _totalItems = visits.length;
      });
      final DateTime now = DateTime.now();
      final DateTime todayStart = DateTime(now.year, now.month, now.day);
      final DateTime todayEnd = todayStart.add(const Duration(days: 1));

      final int todaysVisits = visits
          .where(
            (v) =>
                v.createdAt.isAfter(todayStart) &&
                v.createdAt.isBefore(todayEnd),
          )
          .length;

      final int completedVisits = visits
          .where((v) => v.status == SiteVisitStatus.completed)
          .length;

      final int officeVisits = visits
          .where((v) => v.visitMode == VisitMode.office)
          .length;

      final int upcomingVisits = visits
          .where(
            (v) =>
                v.status == SiteVisitStatus.scheduled &&
                v.meetingFrom != null &&
                v.meetingFrom!.isAfter(now),
          )
          .length;

      setState(() {
        _metrics = {
          'todaysSiteVisits': todaysVisits,
          'totalSiteVisits': visits.length,
          'totalUpcomingVisits': upcomingVisits,
          'totalLapseVisits': 0, // You can implement this logic
          'completedVisits': completedVisits,
          'officeVisits': officeVisits,
        };
      });
    } catch (e) {
      // Handle error
      // Error loading metrics: $e
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _loadSiteVisits();
  }

  void _onItemsPerPageChanged(int itemsPerPage) {
    setState(() {
      _itemsPerPage = itemsPerPage;
      _currentPage = 1; // Reset to first page when changing page size
    });
    _loadSiteVisits();
  }

  int get _totalPages => (_totalItems / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Site Visits'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Filters',
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showFilters(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _MetricsRow(
            items: <_MetricItem>[
              _MetricItem(
                'Today\'s Site Visits',
                _metrics['todaysSiteVisits'] ?? 0,
                Icons.today,
              ),
              _MetricItem(
                'Total Site Visits',
                _metrics['totalSiteVisits'] ?? 0,
                Icons.place_outlined,
              ),
              _MetricItem(
                'Upcoming Visits',
                _metrics['totalUpcomingVisits'] ?? 0,
                Icons.schedule,
              ),
              _MetricItem(
                'Lapse Visits',
                _metrics['totalLapseVisits'] ?? 0,
                Icons.warning_amber,
              ),
              _MetricItem(
                'Completed Visits',
                _metrics['completedVisits'] ?? 0,
                Icons.check_circle,
              ),
              _MetricItem(
                'Office Visits',
                _metrics['officeVisits'] ?? 0,
                Icons.business,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SearchBar(onChanged: (String v) => setState(() => _search = v)),
          const SizedBox(height: 12),
          _PaginationControl(
            currentPage: _currentPage,
            totalPages: _totalPages,
            itemsPerPage: _itemsPerPage,
            totalItems: _totalItems,
            pageSizeOptions: _pageSizeOptions,
            onPageChanged: _onPageChanged,
            onItemsPerPageChanged: _onItemsPerPageChanged,
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<SiteVisit>>(
            future: _siteVisitsFuture,
            builder:
                (
                  BuildContext context,
                  AsyncSnapshot<List<SiteVisit>> snapshot,
                ) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Failed to load site visits: ${snapshot.error}',
                      ),
                    );
                  }
                  final List<SiteVisit> visits = snapshot.data ?? <SiteVisit>[];

                  // Filter visits based on search
                  final List<SiteVisit> filteredVisits = _search.isEmpty
                      ? visits
                      : visits
                            .where(
                              (visit) =>
                                  visit.customerName.toLowerCase().contains(
                                    _search.toLowerCase(),
                                  ) ||
                                  visit.projectName.toLowerCase().contains(
                                    _search.toLowerCase(),
                                  ) ||
                                  visit.srNo.toLowerCase().contains(
                                    _search.toLowerCase(),
                                  ),
                            )
                            .toList();

                  if (filteredVisits.isEmpty) {
                    return const Center(child: Text('No site visits found'));
                  }

                  return Column(
                    children: [
                      for (
                        int index = 0;
                        index < filteredVisits.length;
                        index++
                      )
                        _SiteVisitCard(siteVisit: filteredVisits[index]),
                    ],
                  );
                },
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
        return const _SiteVisitFiltersSheet();
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: _panelColor(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.search_rounded,
            color: Theme.of(context).iconTheme.color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search site visits by customer, project...',
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _panelColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 2,
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

class _SiteVisitCard extends StatelessWidget {
  const _SiteVisitCard({required this.siteVisit});
  final SiteVisit siteVisit;
  @override
  Widget build(BuildContext context) {
    final String status = siteVisit.status.toString().split('.').last;
    final Color statusColor = _getStatusColor(status);

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  siteVisit.srNo,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const Spacer(),
              _StatusChip(label: status, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.person_outline,
            label: 'Customer',
            value: siteVisit.customerName,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.location_city,
            label: 'Project',
            value: siteVisit.projectName,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.access_time,
            label: 'Meeting Hour',
            value: siteVisit.meetingFrom != null && siteVisit.meetingTo != null
                ? '${_formatTime(siteVisit.meetingFrom!)} - ${_formatTime(siteVisit.meetingTo!)}'
                : 'Not scheduled',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.flag_outlined,
            label: 'Purpose',
            value: siteVisit.purpose ?? 'Property Inspection',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.calendar_today,
            label: 'Created At',
            value: _formatDate(siteVisit.createdAt),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SiteVisitDetailScreen(
                        siteVisitId: siteVisit.id,
                        siteVisitData: siteVisit.toJson(),
                      ),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: const Text('View'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'Scheduled':
      return Colors.blue;
    case 'Completed':
      return Colors.green;
    case 'Cancelled':
      return Colors.red;
    case 'Rescheduled':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
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
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}

class _SiteVisitFiltersSheet extends StatefulWidget {
  const _SiteVisitFiltersSheet();
  @override
  State<_SiteVisitFiltersSheet> createState() => _SiteVisitFiltersSheetState();
}

class _SiteVisitFiltersSheetState extends State<_SiteVisitFiltersSheet> {
  String customerName = '';
  String contactNumber = '';
  DateTime? siteVisitDate;
  String projectList = 'Any';
  String meetingMode = 'Any';
  String scheduledBy = 'Any';
  String attendedBy = 'Any';
  String siteVisitType = 'Any';
  String meetingStatus = 'Any';

  // Real data from database
  List<String> _projectOptions = <String>['Any'];
  List<String> _userOptions = <String>['Any'];
  bool _isLoadingOptions = true;

  @override
  void initState() {
    super.initState();
    _loadFilterOptions();
  }

  Future<void> _loadFilterOptions() async {
    try {
      // Load projects
      final List<Project> projects = await DatabaseService.getProjects();
      final List<String> projectNames = projects.map((p) => p.name).toList();

      // Load users (you might need to implement getUserProfiles or similar)
      // For now, using a placeholder - you can implement this based on your user management
      final List<String> userNames = <String>[
        'Current User',
      ]; // TODO: Load real users

      setState(() {
        _projectOptions = ['Any', ...projectNames];
        _userOptions = ['Any', ...userNames];
        _isLoadingOptions = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingOptions = false;
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
              if (_isLoadingOptions)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else ...[
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
                _TextField(
                  label: 'Customer name',
                  value: customerName,
                  onChanged: (String v) => setState(() => customerName = v),
                ),
                _TextField(
                  label: 'Contact number',
                  value: contactNumber,
                  onChanged: (String v) => setState(() => contactNumber = v),
                ),
                _DatePicker(
                  label: 'Site visit date',
                  value: siteVisitDate,
                  onChanged: (DateTime? d) => setState(() => siteVisitDate = d),
                ),
                _Dropdown(
                  label: 'Project list',
                  value: projectList,
                  items: _projectOptions,
                  onChanged: (String v) => setState(() => projectList = v),
                ),
                _Dropdown(
                  label: 'Meeting mode',
                  value: meetingMode,
                  items: const <String>[
                    'Any',
                    'In-person',
                    'Video Call',
                    'Phone Call',
                  ],
                  onChanged: (String v) => setState(() => meetingMode = v),
                ),
                _Dropdown(
                  label: 'Scheduled by',
                  value: scheduledBy,
                  items: _userOptions,
                  onChanged: (String v) => setState(() => scheduledBy = v),
                ),
                _Dropdown(
                  label: 'Attended by',
                  value: attendedBy,
                  items: _userOptions,
                  onChanged: (String v) => setState(() => attendedBy = v),
                ),
                _Dropdown(
                  label: 'Site visit type',
                  value: siteVisitType,
                  items: const <String>[
                    'Any',
                    'Property Inspection',
                    'Site Survey',
                    'Client Meeting',
                  ],
                  onChanged: (String v) => setState(() => siteVisitType = v),
                ),
                _Dropdown(
                  label: 'Meeting status',
                  value: meetingStatus,
                  items: const <String>[
                    'Any',
                    'Scheduled',
                    'Completed',
                    'Cancelled',
                    'Rescheduled',
                  ],
                  onChanged: (String v) => setState(() => meetingStatus = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            customerName = '';
                            contactNumber = '';
                            siteVisitDate = null;
                            projectList = 'Any';
                            meetingMode = 'Any';
                            scheduledBy = 'Any';
                            attendedBy = 'Any';
                            siteVisitType = 'Any';
                            meetingStatus = 'Any';
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
            ],
          ),
        );
      },
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String value;
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
          TextField(
            onChanged: onChanged,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
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
  return isDark
      ? Colors.white.withOpacity(0.06)
      : Colors.black.withOpacity(0.04);
}

Color _panelBorderColor(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? Colors.white.withOpacity(0.12) : const Color(0x22000000);
}

String _formatTime(DateTime dateTime) {
  final int hour = dateTime.hour;
  final int minute = dateTime.minute;
  final String period = hour >= 12 ? 'PM' : 'AM';
  final int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
  return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
}

String _formatDate(DateTime dateTime) {
  const List<String> months = [
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
  return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
}

class _PaginationControl extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int itemsPerPage;
  final int totalItems;
  final List<int> pageSizeOptions;
  final Function(int) onPageChanged;
  final Function(int) onItemsPerPageChanged;

  const _PaginationControl({
    required this.currentPage,
    required this.totalPages,
    required this.itemsPerPage,
    required this.totalItems,
    required this.pageSizeOptions,
    required this.onPageChanged,
    required this.onItemsPerPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top row: Items per page and page info
            Row(
              children: [
                // Items per page selector with button styling
                Text('Show:', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<int>(
                    value: itemsPerPage,
                    isDense: true,
                    underline: Container(),
                    items: pageSizeOptions.map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          '$value',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        onItemsPerPageChanged(newValue);
                      }
                    },
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                const Spacer(),

                // Page info
                Flexible(
                  child: Text(
                    'Page $currentPage of $totalPages ($totalItems items)',
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Bottom row: Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: currentPage > 1
                      ? () => onPageChanged(currentPage - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous page',
                ),
                const SizedBox(width: 8),
                Text(
                  '$currentPage / $totalPages',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: currentPage < totalPages
                      ? () => onPageChanged(currentPage + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next page',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
