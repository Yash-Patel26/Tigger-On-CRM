import 'package:flutter/material.dart';

class TicketHubScreen extends StatefulWidget {
  const TicketHubScreen({super.key});

  @override
  State<TicketHubScreen> createState() => _TicketHubScreenState();
}

class _TicketHubScreenState extends State<TicketHubScreen> {
  // Mock data
  final List<Map<String, dynamic>> _tickets = <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 'TCK-000123',
      'mobile': '+91 9876543210',
      'datetime': DateTime.now().subtract(const Duration(hours: 1)),
      'serviceType': 'Maintenance',
      'assignee': 'Anita',
      'priority': 'High',
      'status': 'Open',
    },
    <String, dynamic>{
      'id': 'TCK-000124',
      'mobile': '+91 9234567810',
      'datetime': DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      'serviceType': 'Cleaning',
      'assignee': 'Ravi',
      'priority': 'Medium',
      'status': 'In Progress',
    },
    <String, dynamic>{
      'id': 'TCK-000125',
      'mobile': '+91 9988776655',
      'datetime': DateTime.now().subtract(const Duration(days: 3)),
      'serviceType': 'Repair',
      'assignee': 'Sunil',
      'priority': 'Low',
      'status': 'Closed',
    },
  ];

  // Filters (mock)
  String? _filterStatus;
  String? _filterPriority;
  String? _filterAssignee;
  String? _filterAging; // e.g., Today, 1-3 days, 7+ days
  DateTimeRange? _filterRange;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filtered = _applyFilters(_tickets);
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
      body: ListView(
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
      if (_filterStatus != null &&
          _filterStatus!.isNotEmpty &&
          t['status'] != _filterStatus) {
        return false;
      }
      if (_filterPriority != null &&
          _filterPriority!.isNotEmpty &&
          t['priority'] != _filterPriority) {
        return false;
      }
      if (_filterAssignee != null &&
          _filterAssignee!.isNotEmpty &&
          t['assignee'] != _filterAssignee) {
        return false;
      }
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
                          items: const <String>[
                            'Open',
                            'In Progress',
                            'Closed',
                          ],
                          onChanged: (String? v) =>
                              setModalState(() => status = v),
                        ),
                        const SizedBox(height: 8),
                        _dropdownField(
                          label: 'Priority',
                          value: priority,
                          items: const <String>['High', 'Medium', 'Low'],
                          onChanged: (String? v) =>
                              setModalState(() => priority = v),
                        ),
                        const SizedBox(height: 8),
                        _dropdownField(
                          label: 'Assign to',
                          value: assignee,
                          items: const <String>['Anita', 'Ravi', 'Sunil'],
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
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CreateTicketScreen()));
  }
}

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? ticketCategory;
  String? registeredMobile;
  String? lead;
  String? ticketType;
  String? serviceType;
  String? priority;
  String? contactName;
  String? alternateNumber;
  String? issueTitle;
  String? unitNumber;
  String? assignTo;
  String? issueDescription;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: const Text('Create Ticket'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _dropdown(
              'Ticket category',
              (String? v) => ticketCategory = v,
              const <String>['Plumbing', 'Electrical', 'HVAC'],
            ),
            _text(
              'Registered mobile number',
              (String v) => registeredMobile = v,
              keyboardType: TextInputType.phone,
              validator: _requiredPhone,
            ),
            _dropdown('Lead list', (String? v) => lead = v, const <String>[
              'Lead A',
              'Lead B',
              'Lead C',
            ]),
            _dropdown(
              'Ticket type',
              (String? v) => ticketType = v,
              const <String>['Issue', 'Request'],
            ),
            _dropdown(
              'Service type',
              (String? v) => serviceType = v,
              const <String>['Maintenance', 'Repair', 'Cleaning'],
            ),
            _dropdown('Priority', (String? v) => priority = v, const <String>[
              'High',
              'Medium',
              'Low',
            ]),
            _text(
              'Contact name',
              (String v) => contactName = v,
              validator: _required,
            ),
            _text(
              'Alternate number',
              (String v) => alternateNumber = v,
              keyboardType: TextInputType.phone,
            ),
            _text(
              'Issue title',
              (String v) => issueTitle = v,
              validator: _required,
            ),
            _text('Unit number', (String v) => unitNumber = v),
            _dropdown('Assign to', (String? v) => assignTo = v, const <String>[
              'Anita',
              'Ravi',
              'Sunil',
            ]),
            _multiline('Issue description', (String v) => issueDescription = v),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Submit'),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;
  String? _requiredPhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final String digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) return 'Enter a valid phone number';
    return null;
  }

  Widget _dropdown(
    String label,
    ValueChanged<String?> onChanged,
    List<String> items,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        items: items
            .map(
              (String e) => DropdownMenuItem<String>(value: e, child: Text(e)),
            )
            .toList(),
        onChanged: onChanged,
        dropdownColor: const Color(0xFF1E1E1E),
        style: const TextStyle(color: Colors.white),
        decoration: _fieldDecoration(label),
        validator: _required,
      ),
    );
  }

  Widget _text(
    String label,
    ValueChanged<String> onChanged, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        onChanged: onChanged,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: _fieldDecoration(label),
        validator: validator,
      ),
    );
  }

  Widget _multiline(String label, ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        onChanged: onChanged,
        maxLines: 4,
        style: const TextStyle(color: Colors.white),
        decoration: _fieldDecoration(label),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
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
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ticket created (mock).')));
      Navigator.of(context).pop();
    }
  }
}
