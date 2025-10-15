import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../utils/helpers.dart';
// import '../utils/page_transitions.dart';
// import 'add_site_visit_screen.dart';
import 'site_visit_detail_screen.dart';

class LeadDetailScreen extends StatelessWidget {
  const LeadDetailScreen({super.key, required this.leadId});

  final String leadId;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8,
      child: Scaffold(
        backgroundColor: const Color(0xFFE1F0E4),
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Lead Details', style: TextStyle(fontSize: 18)),
              Text(
                leadId,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'Assign',
              icon: Icon(
                Icons.assignment_ind_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () => _showAssignDialog(context),
            ),
            IconButton(
              tooltip: 'Dispose Lead',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _showDisposeDialog(context),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(110),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _IconAction(
                        assetPng: 'assets/icons/phone-call.png',
                        tooltip: 'Call',
                        onTap: () async {
                          await Helpers.placeCall('+91 98765 43210');
                          await Future<void>.delayed(
                            const Duration(seconds: 2),
                          );
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
                      ),
                      _IconAction(
                        assetPng: 'assets/icons/phone-call.png',
                        tooltip: 'Edit Before Call',
                        onTap: () async {
                          final String? number = await _promptPhone(
                            context,
                            initial: '+91 98765 43210',
                          );
                          if (number != null && number.trim().isNotEmpty) {
                            await Helpers.placeCall(number.trim());
                            await Future<void>.delayed(
                              const Duration(seconds: 2),
                            );
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
                          }
                        },
                        rotateTurns: 2, // rotate 180° to differentiate
                      ),
                      _IconAction(
                        assetPng: 'assets/icons/email.png',
                        tooltip: 'Email',
                        onTap: () => _launchEmail('alex.johnson@example.com'),
                      ),
                      _IconAction(
                        assetPng: 'assets/icons/conversation.png',
                        tooltip: 'SMS',
                        onTap: () => _launchSms('+91 98765 43210'),
                      ),
                      _IconAction(
                        assetPng: 'assets/icons/whatsapp.png',
                        tooltip: 'WhatsApp',
                        onTap: () => _launchWhatsApp('+91 98765 43210'),
                      ),
                      _IconAction(
                        assetPng: 'assets/icons/whatsapp.png',
                        tooltip: 'Offline WA',
                        onTap: () => _launchWhatsAppWeb('+91 98765 43210'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                    tabs: const <Tab>[
                      Tab(text: 'Lead Detail'),
                      Tab(text: 'Cross Sell'),
                      Tab(text: 'Reference'),
                      Tab(text: 'Site Visit'),
                      Tab(text: 'Task'),
                      Tab(text: 'Question'),
                      Tab(text: 'Property Option'),
                      Tab(text: 'Ticket'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            // Lead Detail tab
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _SectionCard(
                    title: '',
                    children: <Widget>[_ContactCompact()],
                  ),
                  const SizedBox(height: 12),
                  _CollapsibleCard(
                    title: 'Preferred Project & Location',
                    child: _ProjectLocationCompact(),
                  ),
                  const SizedBox(height: 12),

                  _CollapsibleCard(
                    title: 'Personal Information',
                    child: _PersonalInfoCard(),
                  ),
                  const SizedBox(height: 12),

                  // Removed Schedule Follow-up card per spec
                  _CollapsibleCard(
                    title: 'Timeline',
                    child: _TimelineCompact(),
                  ),
                  const SizedBox(height: 12),
                  _CollapsibleCard(
                    title: 'Activity & Assignment History',
                    child: _ActivityCompact(),
                  ),
                  const SizedBox(height: 72),
                ],
              ),
            ),
            // Cross Sell
            const _CrossSellTab(),
            // Reference
            const _ReferenceTab(),
            // Site Visit
            const _SiteVisitTab(),
            // Task
            const _TaskTab(),
            // Question
            const _QuestionTab(),
            // Property Option
            const _PropertyOptionTab(),
            // Ticket
            const _TicketTab(),
          ],
        ),
      ),
    );
  }

  void _showDisposeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return const _DisposeLeadDialog();
      },
    );
  }

  void _showAssignDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return const _AssignLeadDialog();
      },
    );
  }
}

class _LabelValueText extends StatelessWidget {
  const _LabelValueText({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: <TextSpan>[
          TextSpan(
            text: label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final bool showTitle = title.trim().isNotEmpty;
    final Color accent = const Color(0xFF1E88E5); // blue accent for this screen
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: <BoxShadow>[
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
              if (showTitle)
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111111),
                  ),
                ),
              if (showTitle)
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 14),
                  child: Divider(color: accent.withOpacity(0.15), height: 1),
                ),
              ...children,
            ],
          ),
        ),
        // Removed left accent bar
      ],
    );
  }
}

class _CollapsibleCard extends StatefulWidget {
  const _CollapsibleCard({required this.title, required this.child});
  final String title;
  final Widget child;
  @override
  State<_CollapsibleCard> createState() => _CollapsibleCardState();
}

class _DisposeLeadDialog extends StatefulWidget {
  const _DisposeLeadDialog();

  @override
  State<_DisposeLeadDialog> createState() => _DisposeLeadDialogState();
}

class _DisposeLeadDialogState extends State<_DisposeLeadDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> _mainOptions = <String>[
    'customer',
    'disqualified',
    'follow up',
    'hot',
    'opportunity',
    'spam',
    'test',
    'testing',
    'sub dispose',
  ];

  String? _main;
  String? _sub;
  String _initiatedBy = 'Agent';
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  final TextEditingController _remarkCtrl = TextEditingController();

  List<String> get _subOptions {
    switch ((_main ?? '').toLowerCase()) {
      case 'customer':
        return <String>['booking', 'disqualified'];
      case 'disqualified':
        return <String>[
          'less budget',
          'no response',
          'many time call performed',
          'not interested',
          'broker',
          'dead',
        ];
      case 'follow up':
        return <String>[
          'call back',
          'busy',
          'call drop',
          'client hangup',
          'not achable',
          'detailed shared',
          'future planning',
          'looking for other project',
          'call not received',
        ];
      case 'hot':
        return <String>['site visit done', 'negotiation stage', 'ready to buy'];
      case 'opportunity':
        return <String>[
          'site visit scheduled',
          'plan for site viist',
          'project finalize',
          'interested',
          'detailed shared',
        ];
      case 'spam':
        return <String>['number invalid', 'wrong number', 'marketing call'];
      default:
        return const <String>[];
    }
  }

  bool get _showInitiatedBy {
    final String m = (_main ?? '').toLowerCase();
    return m == 'customer' || m == 'disqualified' || m == 'spam';
  }

  bool get _showDateTime {
    final String m = (_main ?? '').toLowerCase();
    return m == 'follow up' || m == 'hot' || m == 'opportunity';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      scrollable: true,
      title: const Text('Dispose Lead'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, minWidth: 360),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<String>(
                initialValue: _main,
                isExpanded: true,
                items: _mainOptions
                    .map(
                      (String e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(_capitalize(e)),
                      ),
                    )
                    .toList(),
                onChanged: (String? v) => setState(() {
                  _main = v;
                  _sub = null;
                }),
                decoration: const InputDecoration(
                  labelText: 'Main Disposition',
                  hintText: 'Select main disposition',
                  border: OutlineInputBorder(),
                ),
                validator: (String? v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _sub,
                isExpanded: true,
                items: _subOptions
                    .map(
                      (String e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(_capitalize(e)),
                      ),
                    )
                    .toList(),
                onChanged: (String? v) => setState(() => _sub = v),
                decoration: const InputDecoration(
                  labelText: 'Sub Disposition',
                  hintText: 'Select sub disposition',
                  border: OutlineInputBorder(),
                ),
                validator: (String? v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              if (_showInitiatedBy) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  'Initiated by',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Agent'),
                        value: 'Agent',
                        contentPadding: EdgeInsets.zero,
                        groupValue: _initiatedBy,
                        onChanged: (String? v) =>
                            setState(() => _initiatedBy = v ?? 'Agent'),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Customer'),
                        value: 'Customer',
                        contentPadding: EdgeInsets.zero,
                        groupValue: _initiatedBy,
                        onChanged: (String? v) =>
                            setState(() => _initiatedBy = v ?? 'Customer'),
                      ),
                    ),
                  ],
                ),
              ],
              if (_showDateTime) ...<Widget>[
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final DateTime now = DateTime.now();
                          final DateTime? d = await showDatePicker(
                            context: context,
                            firstDate: DateTime(now.year - 1),
                            lastDate: DateTime(now.year + 2),
                            initialDate: _date,
                          );
                          if (d != null) setState(() => _date = d);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${_date.day}/${_date.month}/${_date.year}',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final TimeOfDay? t = await showTimePicker(
                            context: context,
                            initialTime: _time,
                          );
                          if (t != null) setState(() => _time = t);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Time',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(_time.format(context)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _remarkCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Remark',
                  hintText: 'Enter remark',
                  border: OutlineInputBorder(),
                ),
                validator: (String? v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
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
        FilledButton(onPressed: _onSave, child: const Text('Save Changes')),
      ],
    );
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    // Collect data; in real app, call API here
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Disposition saved')));
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}

class _AssignLeadDialog extends StatefulWidget {
  const _AssignLeadDialog();

  @override
  State<_AssignLeadDialog> createState() => _AssignLeadDialogState();
}

class _AssignLeadDialogState extends State<_AssignLeadDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> _users = <String>['Anita', 'Chetan', 'Sample User'];
  String? _selected;
  final TextEditingController _descCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
              DropdownButtonFormField<String>(
                initialValue: _selected,
                isExpanded: true,
                items: _users
                    .map(
                      (String e) =>
                          DropdownMenuItem<String>(value: e, child: Text(e)),
                    )
                    .toList(),
                onChanged: (String? v) => setState(() => _selected = v),
                decoration: const InputDecoration(
                  labelText: 'Assign to',
                  border: OutlineInputBorder(),
                ),
                validator: (String? v) =>
                    v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Add assignment note',
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
  }

  void _onAssign() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Assigned to ${_selected!}')));
  }
}

class _CollapsibleCardState extends State<_CollapsibleCard> {
  late bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () => setState(() => expanded = !expanded),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                    ),
                  ],
                ),
              ),
              if (expanded) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 12),
                  child: Divider(color: primary.withOpacity(0.15), height: 1),
                ),
                widget.child,
              ],
            ],
          ),
        ),
        // Removed left accent bar
      ],
    );
  }
}

class _CrossSellTab extends StatefulWidget {
  const _CrossSellTab();
  @override
  State<_CrossSellTab> createState() => _CrossSellTabState();
}

class _CrossSellTabState extends State<_CrossSellTab> {
  final List<Map<String, String>> _items = <Map<String, String>>[
    <String, String>{
      'category': 'Residential',
      'propertyType': 'Apartment',
      'project': 'Project Alpha',
      'allocatedTo': 'Me',
      'description': '2BHK options in Alpha',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openAddSheet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('No cross sells yet'))
                : ListView.separated(
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, String> it = _items[index];
                      return _crossSellCard(context, it);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _crossSellCard(BuildContext context, Map<String, String> it) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
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
                  it['project'] ?? '-',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.60),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.30),
                  ),
                ),
                child: Text(
                  it['category'] ?? '-',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              const Icon(Icons.apartment, size: 14),
              const SizedBox(width: 6),
              Text(it['propertyType'] ?? '-'),
              const SizedBox(width: 12),
              const Icon(Icons.person_outline, size: 14),
              const SizedBox(width: 6),
              Text('Allocated: ${it['allocatedTo'] ?? '-'}'),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            it['description'] ?? '-',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _openAddSheet() {
    String category = 'Residential';
    String propertyType = 'Apartment';
    String project = 'Project Alpha';
    String allocatedTo = 'Me';
    final TextEditingController descCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Create Cross Sell',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    items: const <String>['Residential', 'Commercial']
                        .map(
                          (String e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (String? v) =>
                        setModal(() => category = v ?? category),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: propertyType,
                    items:
                        const <String>['Apartment', 'Villa', 'Office', 'Shop']
                            .map(
                              (String e) => DropdownMenuItem<String>(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                    onChanged: (String? v) =>
                        setModal(() => propertyType = v ?? propertyType),
                    decoration: const InputDecoration(
                      labelText: 'Property Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: project,
                    items: const <String>['Project Alpha', 'Project Beta']
                        .map(
                          (String e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (String? v) =>
                        setModal(() => project = v ?? project),
                    decoration: const InputDecoration(
                      labelText: 'Project Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: allocatedTo,
                    items: const <String>['Me', 'Team 1', 'Team 2']
                        .map(
                          (String e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (String? v) =>
                        setModal(() => allocatedTo = v ?? allocatedTo),
                    decoration: const InputDecoration(
                      labelText: 'Allocated To',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _items.insert(0, <String, String>{
                            'category': category,
                            'propertyType': propertyType,
                            'project': project,
                            'allocatedTo': allocatedTo,
                            'description': descCtrl.text.trim(),
                          });
                        });
                        Navigator.of(ctx).pop();
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Create'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _ContactCompact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DateTime requestAt = DateTime.now().subtract(const Duration(days: 3));
    // In a real app, read gender from customer data
    const String gender = 'Male';
    final IconData genderIcon = gender == 'Female'
        ? Icons.female
        : gender == 'Male'
        ? Icons.male
        : Icons.transgender;
    return Column(
      children: <Widget>[
        // Header actions (badge + icons) on top row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _daysBefore(requestAt),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Gender: $gender',
              child: Icon(
                genderIcon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Edit customer',
              icon: Icon(
                Icons.edit_square,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              onPressed: () => _openEditCustomer(context),
            ),
            IconButton(
              tooltip: 'Source',
              icon: Icon(
                Icons.public,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Name moved below header actions for better wrapping when long
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Mayank11',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        // Contact numbers and email removed as requested
        _LeadInfoKeyValues(),
      ],
    );
  }
}

String _daysBefore(DateTime when) {
  final DateTime now = DateTime.now();
  final int days = now.difference(when).inDays;
  if (days <= 0) return 'Today';
  return '$days Days Before';
}

void _openEditCustomer(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) => const _EditCustomerDialog(),
  );
}

// Removed _openViewCustomer; view dialog not used from header anymore

class _EditCustomerDialog extends StatefulWidget {
  const _EditCustomerDialog();
  @override
  State<_EditCustomerDialog> createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends State<_EditCustomerDialog> {
  final TextEditingController _first = TextEditingController(text: 'Mayank');
  final TextEditingController _middle = TextEditingController();
  final TextEditingController _last = TextEditingController(text: 'K');
  final TextEditingController _email = TextEditingController(
    text: 'm*y@gm*il.com',
  );
  final TextEditingController _phone = TextEditingController(
    text: '+91 9816353871',
  );
  final TextEditingController _altPhone = TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: const Text('Edit Customer Info'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, minWidth: 320),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _first,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _middle,
                      decoration: const InputDecoration(
                        labelText: 'Middle Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _last,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _altPhone,
                      decoration: const InputDecoration(
                        labelText: 'Alternate Phone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
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
        FilledButton(
          onPressed: () {
            if (!_form.currentState!.validate()) return;
            Navigator.of(context).pop();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Customer updated')));
          },
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class _ViewCustomerDialog extends StatefulWidget {
  const _ViewCustomerDialog();
  @override
  State<_ViewCustomerDialog> createState() => _ViewCustomerDialogState();
}

class _ViewCustomerDialogState extends State<_ViewCustomerDialog> {
  String gender = 'Male';
  String marital = 'Single';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: const Text('Customer Details'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, minWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _kv(context, 'Gender', gender),
            const Divider(height: 16),
            _kv(context, 'Marital Status', marital),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _kv(BuildContext context, String label, String value) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF1A1A1A)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _LeadMetaCompact extends StatefulWidget {
  @override
  State<_LeadMetaCompact> createState() => _LeadMetaCompactState();
}

class _LeadMetaCompactState extends State<_LeadMetaCompact> {
  String status = 'Hot';
  DateTime followUp = DateTime.now().add(const Duration(days: 1));
  String source = 'Website';
  String allocatedTo = 'Rahul Sharma';
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 6),
        Text('Allocated To:$allocatedTo'),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            InkWell(
              onTap: () async {
                final DateTime now = DateTime.now();
                final DateTime? d = await showDatePicker(
                  context: context,
                  firstDate: now,
                  lastDate: DateTime(now.year + 2),
                  initialDate: followUp,
                );
                if (d != null) {
                  setState(
                    () => followUp = DateTime(
                      d.year,
                      d.month,
                      d.day,
                      followUp.hour,
                      followUp.minute,
                    ),
                  );
                }
              },
              child: Row(
                children: <Widget>[
                  const Icon(Icons.event_outlined, size: 18),
                  const SizedBox(width: 6),
                  Text(_relativeDayString(followUp)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () async {
                final TimeOfDay? t = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(followUp),
                );
                if (t != null) {
                  setState(
                    () => followUp = DateTime(
                      followUp.year,
                      followUp.month,
                      followUp.day,
                      t.hour,
                      t.minute,
                    ),
                  );
                }
              },
              child: Row(
                children: <Widget>[
                  const Icon(Icons.access_time, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '${followUp.hour.toString().padLeft(2, '0')}:${followUp.minute.toString().padLeft(2, '0')}',
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              'Day edit: 15 Dec 2024',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  String _relativeDayString(DateTime d) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime that = DateTime(d.year, d.month, d.day);
    final Duration diff = that.difference(today);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == -1) return 'Yesterday';
    if (diff.inDays == 1) return 'Tomorrow';
    if (diff.inDays.abs() < 7) {
      const List<String> weekdays = <String>[
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ];
      return weekdays[that.weekday - 1];
    }
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

class _LeadInfoKeyValues extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = Theme.of(context).textTheme.bodyMedium!
        .copyWith(color: Colors.grey[800], fontWeight: FontWeight.w700);
    final TextStyle valueStyle = Theme.of(context).textTheme.bodyMedium!
        .copyWith(color: const Color(0xFF1A1A1A), fontWeight: FontWeight.w700);
    final TextStyle linkStyle = valueStyle.copyWith(
      color: Theme.of(context).colorScheme.primary,
      fontWeight: FontWeight.w700,
    );

    Widget kv(String label, Widget value) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(child: Text(label, style: labelStyle)),
            const SizedBox(width: 12),
            Expanded(
              child: Align(alignment: Alignment.centerRight, child: value),
            ),
          ],
        ),
      );
    }

    Widget vText(String text, {bool link = false}) => Text(
      text,
      style: link ? linkStyle : valueStyle,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
      textAlign: TextAlign.right,
    );

    return Column(
      children: <Widget>[
        const Divider(height: 1),
        kv('E-Mail', vText('m*y@gm*il.com', link: true)),
        const Divider(height: 1),
        kv('Alternate Number', vText('-')),
        const Divider(height: 1),
        kv('Project Name', vText('4s The Aurrum', link: true)),
        const Divider(height: 1),
        kv('Raw Mobile', vText('9816353871', link: true)),
        const Divider(height: 1),
        kv('Allocated To', vText('Anita', link: true)),
        const Divider(height: 1),
        kv('Status', vText('-')),
        const Divider(height: 1),
        kv('Follow-Up At', vText('-')),
        const Divider(height: 1),
        kv('Purchase Plan', vText('-')),
        const Divider(height: 1),
        kv('State', vText('Haryana')),
        const Divider(height: 1),
        kv('City', vText('Gurgaon')),
        const Divider(height: 1),
        kv('Category', vText('Residential', link: true)),
        const Divider(height: 1),
        kv('Property Type', vText('Apartment', link: true)),
        const Divider(height: 1),
        kv('Occupation', vText('Software Engineer')),
        const Divider(height: 1),
        kv('Customer Location', vText('Andheri West, Mumbai')),
      ],
    );
  }
}

class _ProjectLocationCompact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Expanded(
              child: _LabelValueText(
                label: 'Project: ',
                value: 'Project Alpha',
              ),
            ),
            const _LabelValueText(label: 'City: ', value: 'Mumbai'),
          ],
        ),
        const SizedBox(height: 8),
        const _LabelValueText(label: 'State: ', value: 'Maharashtra'),
        const SizedBox(height: 4),
        const _LabelValueText(
          label: 'Customer Location: ',
          value: 'Andheri West, Mumbai',
        ),
        const SizedBox(height: 4),
        const _LabelValueText(label: 'Purchase Plan: ', value: '2 BHK'),
      ],
    );
  }
}

class _PersonalInfoCard extends StatefulWidget {
  @override
  State<_PersonalInfoCard> createState() => _PersonalInfoCardState();
}

class _PersonalInfoCardState extends State<_PersonalInfoCard> {
  DateTime? dob;
  int? age;
  String gender = 'Male';
  String maritalStatus = 'Single';
  // Employment & Professional
  String employmentType = 'Salaried';
  String itrFilingStatus = 'Filed';
  String occupation = 'Software Engineer';
  // Address
  String address = '';
  String country = 'India';
  String stateName = '';
  String city = '';
  String location = '';
  String pincode = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _LabelValueText(
                label: 'DOB: ',
                value: dob == null
                    ? '—'
                    : '${dob!.day}/${dob!.month}/${dob!.year}',
              ),
            ),
            TextButton.icon(
              onPressed: _editDob,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: _LabelValueText(
                label: 'Age: ',
                value: age?.toString() ?? '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: _LabelValueText(label: 'Gender: ', value: gender),
            ),
            TextButton.icon(
              onPressed: _editGender,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: _LabelValueText(
                label: 'Marital Status: ',
                value: maritalStatus,
              ),
            ),
            TextButton.icon(
              onPressed: _editMarital,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 16),
        // Employment details
        Row(
          children: <Widget>[
            Expanded(
              child: _LabelValueText(
                label: 'Employment Type: ',
                value: employmentType,
              ),
            ),
            TextButton.icon(
              onPressed: _editEmploymentType,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: _LabelValueText(
                label: 'ITR Filing: ',
                value: itrFilingStatus,
              ),
            ),
            TextButton.icon(
              onPressed: _editItrStatus,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: _LabelValueText(label: 'Occupation: ', value: occupation),
            ),
            TextButton.icon(
              onPressed: _editOccupation,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 16),
        // Address details
        Row(
          children: <Widget>[
            Expanded(
              child: _LabelValueText(
                label: 'Address: ',
                value: address.isEmpty ? '—' : address,
              ),
            ),
            TextButton.icon(
              onPressed: _editAddress,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: _LabelValueText(label: 'Country: ', value: country),
            ),
            TextButton.icon(
              onPressed: _editCountry,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: _LabelValueText(
                label: 'State: ',
                value: stateName.isEmpty ? '—' : stateName,
              ),
            ),
            TextButton.icon(
              onPressed: _editState,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: _LabelValueText(
                label: 'City: ',
                value: city.isEmpty ? '—' : city,
              ),
            ),
            TextButton.icon(
              onPressed: _editCity,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: _LabelValueText(
                label: 'Location: ',
                value: location.isEmpty ? '—' : location,
              ),
            ),
            TextButton.icon(
              onPressed: _editLocation,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: _LabelValueText(
                label: 'Pincode: ',
                value: pincode.isEmpty ? '—' : pincode,
              ),
            ),
            TextButton.icon(
              onPressed: _editPincode,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _editDob() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 100);
    final DateTime lastDate = now;
    final DateTime initial = dob ?? DateTime(now.year - 25, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDate: initial,
    );
    if (picked != null) {
      setState(() {
        dob = picked;
        age = _calculateAge(picked);
      });
    }
  }

  // Employment editors
  Future<void> _editEmploymentType() async {
    String temp = employmentType;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Employment Type'),
          content: StatefulBuilder(
            builder:
                (BuildContext context, void Function(void Function()) setSt) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RadioListTile<String>(
                        title: const Text('Salaried'),
                        value: 'Salaried',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Salaried'),
                      ),
                      RadioListTile<String>(
                        title: const Text('Self Employed'),
                        value: 'Self Employed',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Self Employed'),
                      ),
                      RadioListTile<String>(
                        title: const Text('Business'),
                        value: 'Business',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Business'),
                      ),
                      RadioListTile<String>(
                        title: const Text('Other'),
                        value: 'Other',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Other'),
                      ),
                    ],
                  );
                },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => employmentType = temp);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editItrStatus() async {
    String temp = itrFilingStatus;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ITR Filing Status'),
          content: StatefulBuilder(
            builder:
                (BuildContext context, void Function(void Function()) setSt) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RadioListTile<String>(
                        title: const Text('Filed'),
                        value: 'Filed',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Filed'),
                      ),
                      RadioListTile<String>(
                        title: const Text('Not Filed'),
                        value: 'Not Filed',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Not Filed'),
                      ),
                    ],
                  );
                },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => itrFilingStatus = temp);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editOccupation() async {
    final TextEditingController ctrl = TextEditingController(text: occupation);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Occupation'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Occupation',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => occupation = ctrl.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Address editors
  Future<void> _editAddress() async {
    final TextEditingController ctrl = TextEditingController(text: address);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Address'),
          content: TextField(
            controller: ctrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => address = ctrl.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editCountry() async {
    String temp = country;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Country'),
          content: StatefulBuilder(
            builder:
                (BuildContext context, void Function(void Function()) setSt) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RadioListTile<String>(
                        title: const Text('India'),
                        value: 'India',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'India'),
                      ),
                      RadioListTile<String>(
                        title: const Text('Other'),
                        value: 'Other',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Other'),
                      ),
                    ],
                  );
                },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => country = temp);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editState() async {
    final TextEditingController ctrl = TextEditingController(text: stateName);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('State'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'State',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => stateName = ctrl.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editCity() async {
    final TextEditingController ctrl = TextEditingController(text: city);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('City'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'City',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => city = ctrl.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editLocation() async {
    final TextEditingController ctrl = TextEditingController(text: location);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => location = ctrl.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editPincode() async {
    final TextEditingController ctrl = TextEditingController(text: pincode);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pincode'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pincode',
                border: OutlineInputBorder(),
              ),
              validator: (String? v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v.trim().length < 4 || v.trim().length > 10) {
                  return 'Enter valid pincode';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() => pincode = ctrl.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Age is derived from DOB; editing disabled per spec.

  Future<void> _editGender() async {
    String temp = gender;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Gender'),
          content: StatefulBuilder(
            builder:
                (BuildContext context, void Function(void Function()) setSt) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RadioListTile<String>(
                        title: const Text('Male'),
                        value: 'Male',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Male'),
                      ),
                      RadioListTile<String>(
                        title: const Text('Female'),
                        value: 'Female',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Female'),
                      ),
                      RadioListTile<String>(
                        title: const Text('Other'),
                        value: 'Other',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Other'),
                      ),
                    ],
                  );
                },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => gender = temp);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editMarital() async {
    String temp = maritalStatus;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Marital Status'),
          content: StatefulBuilder(
            builder:
                (BuildContext context, void Function(void Function()) setSt) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RadioListTile<String>(
                        title: const Text('Single'),
                        value: 'Single',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Single'),
                      ),
                      RadioListTile<String>(
                        title: const Text('Married'),
                        value: 'Married',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Married'),
                      ),
                      RadioListTile<String>(
                        title: const Text('Divorced'),
                        value: 'Divorced',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Divorced'),
                      ),
                      RadioListTile<String>(
                        title: const Text('Widowed'),
                        value: 'Widowed',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Widowed'),
                      ),
                    ],
                  );
                },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => maritalStatus = temp);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  int _calculateAge(DateTime birthDate) {
    final DateTime today = DateTime.now();
    int years = today.year - birthDate.year;
    final bool hadBirthdayThisYear =
        (today.month > birthDate.month) ||
        (today.month == birthDate.month && today.day >= birthDate.day);
    if (!hadBirthdayThisYear) years -= 1;
    return years;
  }
}

class _ProfessionalInfoCard extends StatefulWidget {
  @override
  State<_ProfessionalInfoCard> createState() => _ProfessionalInfoCardState();
}

class _ProfessionalInfoCardState extends State<_ProfessionalInfoCard> {
  String employmentType = 'Salaried';
  String itrFilingStatus = 'Filed';
  String occupation = 'Software Engineer';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(child: Text('Employment Type: $employmentType')),
            TextButton.icon(
              onPressed: _editEmploymentType,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(child: Text('ITR Filing Status: $itrFilingStatus')),
            TextButton.icon(
              onPressed: _editItrStatus,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(child: Text('Occupation: $occupation')),
            TextButton.icon(
              onPressed: _editOccupation,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _editEmploymentType() async {
    String temp = employmentType;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Employment Type'),
          content: StatefulBuilder(
            builder:
                (BuildContext context, void Function(void Function()) setSt) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RadioListTile<String>(
                        title: const Text('Salaried'),
                        value: 'Salaried',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Salaried'),
                      ),
                      RadioListTile<String>(
                        title: const Text('Self Employed'),
                        value: 'Self Employed',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Self Employed'),
                      ),
                      RadioListTile<String>(
                        title: const Text('Business'),
                        value: 'Business',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Business'),
                      ),
                      RadioListTile<String>(
                        title: const Text('Other'),
                        value: 'Other',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Other'),
                      ),
                    ],
                  );
                },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => employmentType = temp);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editItrStatus() async {
    String temp = itrFilingStatus;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ITR Filing Status'),
          content: StatefulBuilder(
            builder:
                (BuildContext context, void Function(void Function()) setSt) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RadioListTile<String>(
                        title: const Text('Filed'),
                        value: 'Filed',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Filed'),
                      ),
                      RadioListTile<String>(
                        title: const Text('Not Filed'),
                        value: 'Not Filed',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Not Filed'),
                      ),
                    ],
                  );
                },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => itrFilingStatus = temp);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editOccupation() async {
    final TextEditingController ctrl = TextEditingController(text: occupation);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Occupation'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Occupation',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => occupation = ctrl.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class _PermanentAddressCard extends StatefulWidget {
  @override
  State<_PermanentAddressCard> createState() => _PermanentAddressCardState();
}

class _PermanentAddressCardState extends State<_PermanentAddressCard> {
  String address = '';
  String country = 'India';
  String stateName = '';
  String city = '';
  String location = '';
  String pincode = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text('Address: ${address.isEmpty ? '—' : address}'),
            ),
            TextButton.icon(
              onPressed: _editAddress,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(child: Text('Country: $country')),
            TextButton.icon(
              onPressed: _editCountry,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: Text('State: ${stateName.isEmpty ? '—' : stateName}'),
            ),
            TextButton.icon(
              onPressed: _editState,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(child: Text('City: ${city.isEmpty ? '—' : city}')),
            TextButton.icon(
              onPressed: _editCity,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: Text('Location: ${location.isEmpty ? '—' : location}'),
            ),
            TextButton.icon(
              onPressed: _editLocation,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: Text('Pincode: ${pincode.isEmpty ? '—' : pincode}'),
            ),
            TextButton.icon(
              onPressed: _editPincode,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Edit'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _editAddress() async {
    final TextEditingController ctrl = TextEditingController(text: address);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Address'),
          content: TextField(
            controller: ctrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Address',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => address = ctrl.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editCountry() async {
    String temp = country;
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Country'),
          content: StatefulBuilder(
            builder:
                (BuildContext context, void Function(void Function()) setSt) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RadioListTile<String>(
                        title: const Text('India'),
                        value: 'India',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'India'),
                      ),
                      RadioListTile<String>(
                        title: const Text('Other'),
                        value: 'Other',
                        groupValue: temp,
                        onChanged: (String? v) =>
                            setSt(() => temp = v ?? 'Other'),
                      ),
                    ],
                  );
                },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => country = temp);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editState() async {
    final TextEditingController ctrl = TextEditingController(text: stateName);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('State'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'State',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => stateName = ctrl.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editCity() async {
    final TextEditingController ctrl = TextEditingController(text: city);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('City'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'City',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => city = ctrl.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editLocation() async {
    final TextEditingController ctrl = TextEditingController(text: location);
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() => location = ctrl.text.trim());
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editPincode() async {
    final TextEditingController ctrl = TextEditingController(text: pincode);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pincode'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pincode',
                border: OutlineInputBorder(),
              ),
              validator: (String? v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (v.trim().length < 4 || v.trim().length > 10) {
                  return 'Enter valid pincode';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() => pincode = ctrl.text.trim());
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

// Removed _AllocationCompact; allocation is now shown within Contact card

class _FollowUpInline extends StatefulWidget {
  @override
  State<_FollowUpInline> createState() => _FollowUpInlineState();
}

class _FollowUpInlineState extends State<_FollowUpInline> {
  DateTime date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay time = const TimeOfDay(hour: 10, minute: 0);
  bool reminder = true;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: InkWell(
            onTap: () async {
              final DateTime now = DateTime.now();
              final DateTime? d = await showDatePicker(
                context: context,
                firstDate: now,
                lastDate: DateTime(now.year + 2),
                initialDate: date,
              );
              if (d != null) setState(() => date = d);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              child: Text('${date.day}/${date.month}/${date.year}'),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: () async {
              final TimeOfDay? t = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (t != null) setState(() => time = t);
            },
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(),
              ),
              child: Text(
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: <Widget>[
            const Text('Reminder'),
            Switch(
              value: reminder,
              onChanged: (bool v) => setState(() => reminder = v),
            ),
          ],
        ),
      ],
    );
  }
}

// Removed _PreferencesCompact per request

class _TimelineCompact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _TimelineCard();
  }
}

class _ActivityCompact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ActivityLogCard(),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {},
            child: const Text('View full history'),
          ),
        ),
      ],
    );
  }
}

// Removed bottom sticky quick actions; moved to AppBar bottom

// (Removed unused _LottieAction implementation)

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.assetPng,
    required this.tooltip,
    required this.onTap,
    this.rotateTurns = 0,
  });

  final String assetPng;
  final String tooltip;
  final VoidCallback onTap;
  final int rotateTurns; // quarter turns

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Tooltip(
        message: tooltip,
        child: SizedBox(
          width: 24,
          height: 24,
          child: rotateTurns == 0
              ? Image.asset(assetPng, fit: BoxFit.contain)
              : Transform.rotate(
                  angle: rotateTurns * (math.pi / 2),
                  child: Image.asset(assetPng, fit: BoxFit.contain),
                ),
        ),
      ),
    );
  }
}

// Removed unused _showEditBeforeCallDialog

Future<String?> _promptPhone(BuildContext context, {String? initial}) async {
  final TextEditingController controller = TextEditingController(
    text: initial ?? '',
  );
  return showDialog<String>(
    context: context,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: const Text('Edit number before calling'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone number',
            border: OutlineInputBorder(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('Call'),
          ),
        ],
      );
    },
  );
}

void _launchSms(String phoneNumber) async {
  final Uri uri = Uri(scheme: 'sms', path: phoneNumber);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

void _launchEmail(String email) async {
  final Uri uri = Uri(
    scheme: 'mailto',
    path: email,
    query: 'subject=Lead Inquiry',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

void _launchWhatsApp(String phoneNumber) async {
  String clean = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  if (!clean.startsWith('91') && clean.length == 10) clean = '91$clean';
  final Uri uri = Uri.parse('https://wa.me/$clean');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

void _launchWhatsAppWeb(String phoneNumber) async {
  String clean = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  if (!clean.startsWith('91') && clean.length == 10) clean = '91$clean';
  final Uri uri = Uri.parse('https://web.whatsapp.com/send?phone=$clean');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _ReferenceTab extends StatefulWidget {
  const _ReferenceTab();
  @override
  State<_ReferenceTab> createState() => _ReferenceTabState();
}

class _ReferenceTabState extends State<_ReferenceTab> {
  final List<Map<String, String>> _refs = <Map<String, String>>[
    <String, String>{
      'firstName': 'Rahul',
      'middleName': '',
      'lastName': 'Verma',
      'contact': '+91 98765 11111',
      'email': 'rahul.verma@example.com',
      'note': 'Looking for 2BHK near city center.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openAddRefSheet,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Reference'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _refs.isEmpty
                  ? const Center(child: Text('No references yet'))
                  : ListView.separated(
                      itemCount: _refs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, String> r = _refs[index];
                        return _refCard(context, r);
                      },
                    ),
            ),
            // Removed Referred To/By detail cards from Reference tab per request
          ],
        ),
      ),
    );
  }

  Widget _refCard(BuildContext context, Map<String, String> r) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
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
                  '${r['firstName'] ?? ''} ${r['lastName'] ?? ''}'.trim(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                r['contact'] ?? '-',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(r['email'] ?? '-', maxLines: 1, overflow: TextOverflow.ellipsis),
          if ((r['note'] ?? '').isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Text(r['note']!, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }

  void _openAddRefSheet() {
    final TextEditingController fCtrl = TextEditingController();
    final TextEditingController mCtrl = TextEditingController();
    final TextEditingController lCtrl = TextEditingController();
    final TextEditingController cCtrl = TextEditingController();
    final TextEditingController eCtrl = TextEditingController();
    final TextEditingController noteCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Create Reference',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: fCtrl,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: mCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Middle Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: lCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: cCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Contact',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: eCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: noteCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Requirement Note',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _refs.insert(0, <String, String>{
                        'firstName': fCtrl.text.trim(),
                        'middleName': mCtrl.text.trim(),
                        'lastName': lCtrl.text.trim(),
                        'contact': cCtrl.text.trim(),
                        'email': eCtrl.text.trim(),
                        'note': noteCtrl.text.trim(),
                      });
                    });
                    Navigator.of(ctx).pop();
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Create Reference'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SiteVisitTab extends StatefulWidget {
  const _SiteVisitTab();
  @override
  State<_SiteVisitTab> createState() => _SiteVisitTabState();
}

class _SiteVisitTabState extends State<_SiteVisitTab> {
  final List<Map<String, String>> _visits = <Map<String, String>>[
    <String, String>{
      'contact': '+91 98765 43210',
      'leadRef': 'LD-1001123567',
      'name': 'Alex Johnson',
      'attender': 'Riya',
      'purpose': 'Project briefing',
      'mode': 'Onsite',
      'from': '2025-09-25 11:00',
      'to': '2025-09-25 12:00',
      'location': 'Gift City',
      'address': 'Plot 21, Gift City, Gandhinagar',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openAddVisitSheet,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Site Visit'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _visits.isEmpty
                  ? const Center(child: Text('No site visits yet'))
                  : ListView.separated(
                      itemCount: _visits.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, String> v = _visits[index];
                        return _visitCard(context, v);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _visitCard(BuildContext context, Map<String, String> v) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
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
                  v['name'] ?? '-',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.60),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.30),
                  ),
                ),
                child: Text(
                  v['mode'] ?? '-',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              const Icon(Icons.call_outlined, size: 14),
              const SizedBox(width: 6),
              Text(v['contact'] ?? '-'),
              const SizedBox(width: 12),
              const Icon(Icons.person_outline, size: 14),
              const SizedBox(width: 6),
              Text('Allocated: ${v['attender'] ?? '-'}'),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              const Icon(Icons.flag_outlined, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  v['purpose'] ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              const Icon(Icons.schedule, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${v['from']} → ${v['to']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              const Icon(Icons.location_on_outlined, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${v['location']} • ${v['address']}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (BuildContext ctx) => SiteVisitDetailScreen(
                      siteVisitId: v['leadRef'] ?? 'SITEVISIT',
                      siteVisitData: <String, dynamic>{
                        'contact': v['contact'],
                        'leadRef': v['leadRef'],
                        'name': v['name'],
                        'attender': v['attender'],
                        'purpose': v['purpose'],
                        'mode': v['mode'],
                        'from': v['from'],
                        'to': v['to'],
                        'location': v['location'],
                        'address': v['address'],
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('View'),
            ),
          ),
        ],
      ),
    );
  }

  void _openAddVisitSheet() {
    final TextEditingController contactCtrl = TextEditingController();
    final TextEditingController leadRefCtrl = TextEditingController();
    final TextEditingController nameCtrl = TextEditingController();
    final TextEditingController attenderCtrl = TextEditingController();
    final TextEditingController purposeCtrl = TextEditingController();
    final TextEditingController locationCtrl = TextEditingController();
    final TextEditingController addressCtrl = TextEditingController();
    DateTime from = DateTime.now();
    DateTime to = DateTime.now().add(const Duration(hours: 1));
    String mode = 'Onsite';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Create Site Visit',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contactCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Customer Contact',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: leadRefCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Lead Reference ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: attenderCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Meeting Attender',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: purposeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Meeting Purpose',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: mode,
                    items: const <String>['Onsite', 'Office']
                        .map(
                          (String e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (String? v) => setModal(() => mode = v ?? mode),
                    decoration: const InputDecoration(
                      labelText: 'Meeting Mode',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _dateTimePicker(
                    context,
                    'From',
                    from,
                    (DateTime d) => setModal(() => from = d),
                  ),
                  const SizedBox(height: 12),
                  _dateTimePicker(
                    context,
                    'To',
                    to,
                    (DateTime d) => setModal(() => to = d),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Meeting Location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Meeting Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _visits.insert(0, <String, String>{
                            'contact': contactCtrl.text.trim(),
                            'leadRef': leadRefCtrl.text.trim(),
                            'name': nameCtrl.text.trim(),
                            'attender': attenderCtrl.text.trim(),
                            'purpose': purposeCtrl.text.trim(),
                            'mode': mode,
                            'from':
                                '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')} ${from.hour.toString().padLeft(2, '0')}:${from.minute.toString().padLeft(2, '0')}',
                            'to':
                                '${to.year}-${to.month.toString().padLeft(2, '0')}-${to.day.toString().padLeft(2, '0')} ${to.hour.toString().padLeft(2, '0')}:${to.minute.toString().padLeft(2, '0')}',
                            'location': locationCtrl.text.trim(),
                            'address': addressCtrl.text.trim(),
                          });
                        });
                        Navigator.of(ctx).pop();
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Create Site Visit'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TaskTab extends StatefulWidget {
  const _TaskTab();
  @override
  State<_TaskTab> createState() => _TaskTabState();
}

class _TaskTabState extends State<_TaskTab> {
  final List<Map<String, String>> tasks = <Map<String, String>>[
    <String, String>{
      'title': 'Follow up',
      'desc': 'Call customer',
      'assign': 'Anita',
      'priority': 'High',
      'status': 'Open',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openCreateTaskSheet,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Task'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text('No tasks yet'))
                  : ListView(
                      children: <Widget>[
                        ...tasks.map(
                          (Map<String, String> t) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: <BoxShadow>[
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
                                Text(
                                  t['title'] ?? '-',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(t['desc'] ?? '-'),
                                const SizedBox(height: 4),
                                Text(
                                  'Assign To: ${t['assign']} • Priority: ${t['priority']} • Status: ${t['status']}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCreateTaskSheet() {
    final TextEditingController titleCtrl = TextEditingController();
    final TextEditingController descCtrl = TextEditingController();
    DateTime startDate = DateTime.now();
    TimeOfDay startTime = const TimeOfDay(hour: 10, minute: 0);
    DateTime endDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);
    String assignTo = 'Me';
    String priority = 'Medium';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Create Task',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _datePicker(
                          context,
                          'Start Date',
                          startDate,
                          (DateTime d) => setModal(() => startDate = d),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _timePicker(
                          context,
                          'Start Time',
                          startTime,
                          (TimeOfDay t) => setModal(() => startTime = t),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _datePicker(
                          context,
                          'End Date',
                          endDate,
                          (DateTime d) => setModal(() => endDate = d),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _timePicker(
                          context,
                          'End Time',
                          endTime,
                          (TimeOfDay t) => setModal(() => endTime = t),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: assignTo,
                          items: const <String>['Me', 'Anita', 'Chetan']
                              .map(
                                (String e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                          onChanged: (String? v) =>
                              setModal(() => assignTo = v ?? assignTo),
                          decoration: const InputDecoration(
                            labelText: 'Assign To',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: priority,
                          items: const <String>['Low', 'Medium', 'High']
                              .map(
                                (String e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                          onChanged: (String? v) =>
                              setModal(() => priority = v ?? priority),
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          tasks.insert(0, <String, String>{
                            'title': titleCtrl.text.trim(),
                            'desc': descCtrl.text.trim(),
                            'assign': assignTo,
                            'priority': priority,
                            'status': 'Open',
                          });
                        });
                        Navigator.of(ctx).pop();
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Create Task'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _QuestionTab extends StatefulWidget {
  const _QuestionTab();
  @override
  State<_QuestionTab> createState() => _QuestionTabState();
}

class _QuestionTabState extends State<_QuestionTab> {
  final List<Map<String, String>> _items = <Map<String, String>>[
    {
      'title': 'What is the payment plan for this project?',
      'notes':
          'Customer wants to know about EMI options and down payment requirements.',
    },
    {
      'title': 'Are there any ongoing offers or discounts?',
      'notes':
          'Interested in current promotional schemes and early bird discounts.',
    },
    {
      'title': 'What is the possession timeline?',
      'notes': 'Customer needs to plan their move-in date accordingly.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openAddQuestionSheet,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Question'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('No questions added yet'))
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, String> q = _items[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: <BoxShadow>[
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
                              Text(
                                q['title'] ?? '-',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              if ((q['notes'] ?? '').isNotEmpty) ...<Widget>[
                                const SizedBox(height: 6),
                                Text(
                                  q['notes']!,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddQuestionSheet() {
    final TextEditingController titleCtrl = TextEditingController();
    final TextEditingController notesCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Add Question',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Create Question',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Create Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      _items.insert(0, <String, String>{
                        'title': titleCtrl.text.trim(),
                        'notes': notesCtrl.text.trim(),
                      });
                    });
                    Navigator.of(ctx).pop();
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Create Question'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PropertyOptionTab extends StatefulWidget {
  const _PropertyOptionTab();
  @override
  State<_PropertyOptionTab> createState() => _PropertyOptionTabState();
}

class _PropertyOptionTabState extends State<_PropertyOptionTab> {
  final List<Map<String, String>> _items = <Map<String, String>>[
    {
      'category': 'Residential',
      'propertyType': '2 BHK Apartment',
      'projectName': 'Green Valley Heights',
      'description':
          'Spacious 2 BHK with modern amenities and great connectivity.',
    },
    {
      'category': 'Commercial',
      'propertyType': 'Office Space',
      'projectName': 'Business Park Plaza',
      'description':
          'Premium office space in prime business district with excellent facilities.',
    },
    {
      'category': 'Residential',
      'propertyType': '3 BHK Villa',
      'projectName': 'Luxury Gardens',
      'description':
          'Exclusive villa with private garden and premium finishes.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openAddPropertyOptionSheet,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Property Option'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('No property options added yet'))
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, String> item = _items[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: <BoxShadow>[
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
                                  Chip(
                                    label: Text(item['category'] ?? '-'),
                                    backgroundColor: Colors.blue.shade100,
                                    labelStyle: TextStyle(
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text(item['propertyType'] ?? '-'),
                                    backgroundColor: Colors.green.shade100,
                                    labelStyle: TextStyle(
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['projectName'] ?? '-',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              if ((item['description'] ?? '')
                                  .isNotEmpty) ...<Widget>[
                                const SizedBox(height: 6),
                                Text(
                                  item['description']!,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddPropertyOptionSheet() {
    String category = 'Residential';
    String propertyType = 'Apartment';
    final TextEditingController projectCtrl = TextEditingController();
    final TextEditingController descCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Create Property Option',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: category,
                          items: const <String>['Residential', 'Commercial']
                              .map(
                                (String e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                          onChanged: (String? v) =>
                              setModal(() => category = v ?? category),
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: propertyType,
                          items:
                              const <String>[
                                    'Apartment',
                                    'Villa',
                                    'Office',
                                    'Shop',
                                  ]
                                  .map(
                                    (String e) => DropdownMenuItem<String>(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (String? v) =>
                              setModal(() => propertyType = v ?? propertyType),
                          decoration: const InputDecoration(
                            labelText: 'Property Type',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: projectCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Create Project Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Create Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _items.insert(0, <String, String>{
                            'category': category,
                            'propertyType': propertyType,
                            'projectName': projectCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                          });
                        });
                        Navigator.of(ctx).pop();
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Create Property Option'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TicketTab extends StatefulWidget {
  const _TicketTab();
  @override
  State<_TicketTab> createState() => _TicketTabState();
}

class _TicketTabState extends State<_TicketTab> {
  final List<Map<String, String>> _items = <Map<String, String>>[
    {
      'id': 'TKT-001',
      'title': 'Payment Processing Issue',
      'description':
          'Customer facing difficulties with online payment gateway during booking process.',
      'createdBy': 'Me',
      'priority': 'High',
    },
    {
      'id': 'TKT-002',
      'title': 'Document Verification Delay',
      'description':
          'KYC documents are taking longer than expected to get verified.',
      'createdBy': 'Anita',
      'priority': 'Medium',
    },
    {
      'id': 'TKT-003',
      'title': 'Site Visit Scheduling',
      'description':
          'Need to coordinate site visit for multiple customers on the same day.',
      'createdBy': 'Chetan',
      'priority': 'Low',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openCreateTicketSheet,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Ticket'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('No tickets created yet'))
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, String> item = _items[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: <BoxShadow>[
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
                                  Text(
                                    item['id'] ?? '-',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const Spacer(),
                                  Chip(
                                    label: Text(item['priority'] ?? '-'),
                                    backgroundColor: _getPriorityColor(
                                      item['priority'] ?? 'Medium',
                                    ),
                                    labelStyle: TextStyle(
                                      color: _getPriorityTextColor(
                                        item['priority'] ?? 'Medium',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['title'] ?? '-',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              if ((item['description'] ?? '')
                                  .isNotEmpty) ...<Widget>[
                                const SizedBox(height: 6),
                                Text(
                                  item['description']!,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Created by ${item['createdBy'] ?? '-'}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    // Use unified palette background for all priorities
    return const Color(0xFFE1F0E4);
  }

  Color _getPriorityTextColor(String priority) {
    // Black text on the new light background
    return Colors.black87;
  }

  void _openCreateTicketSheet() {
    final TextEditingController idCtrl = TextEditingController();
    final TextEditingController titleCtrl = TextEditingController();
    final TextEditingController descCtrl = TextEditingController();
    String createdBy = 'Me';
    String priority = 'Medium';
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        'Create Ticket',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: idCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: createdBy,
                          items: const <String>['Me', 'Anita', 'Chetan']
                              .map(
                                (String e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                          onChanged: (String? v) =>
                              setModal(() => createdBy = v ?? createdBy),
                          decoration: const InputDecoration(
                            labelText: 'Created By',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: priority,
                          items: const <String>['Low', 'Medium', 'High']
                              .map(
                                (String e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                          onChanged: (String? v) =>
                              setModal(() => priority = v ?? priority),
                          decoration: const InputDecoration(
                            labelText: 'Priority',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          _items.insert(0, <String, String>{
                            'id': idCtrl.text.trim(),
                            'title': titleCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                            'createdBy': createdBy,
                            'priority': priority,
                          });
                        });
                        Navigator.of(ctx).pop();
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Create'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

Widget _datePicker(
  BuildContext context,
  String label,
  DateTime value,
  ValueChanged<DateTime> onChanged,
) {
  return InkWell(
    onTap: () async {
      final DateTime? d = await showDatePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2035),
        initialDate: value,
      );
      if (d != null) onChanged(d);
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: Text('${value.day}/${value.month}/${value.year}'),
    ),
  );
}

Widget _timePicker(
  BuildContext context,
  String label,
  TimeOfDay value,
  ValueChanged<TimeOfDay> onChanged,
) {
  return InkWell(
    onTap: () async {
      final TimeOfDay? t = await showTimePicker(
        context: context,
        initialTime: value,
      );
      if (t != null) onChanged(t);
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: Text(
        '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
      ),
    ),
  );
}

Widget _dateTimePicker(
  BuildContext context,
  String label,
  DateTime value,
  ValueChanged<DateTime> onChanged,
) {
  return InkWell(
    onTap: () async {
      final DateTime? d = await showDatePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2035),
        initialDate: value,
      );
      if (d != null) onChanged(d);
    },
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: Text('${value.day}/${value.month}/${value.year}'),
    ),
  );
}

// Removed unused _DetailRow; compact label/value widgets are used elsewhere

// Deprecated _ActionButtons replaced by _QuickActionsStickyRow

// Removed unused _actionButton helper

// Removed _HeaderCard per request

class _StatusUpdateCard extends StatefulWidget {
  @override
  State<_StatusUpdateCard> createState() => _StatusUpdateCardState();
}

class _StatusUpdateCardState extends State<_StatusUpdateCard> {
  String status = 'Hot';
  String subStatus = 'New';
  final TextEditingController reasonCtrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Status & Sub-status',
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: status,
                items: const <String>['Hot', 'Warm', 'Cold']
                    .map(
                      (String e) =>
                          DropdownMenuItem<String>(value: e, child: Text(e)),
                    )
                    .toList(),
                onChanged: (String? v) => setState(() => status = v ?? status),
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: subStatus,
                items: const <String>['New', 'In Progress', 'Closed']
                    .map(
                      (String e) =>
                          DropdownMenuItem<String>(value: e, child: Text(e)),
                    )
                    .toList(),
                onChanged: (String? v) =>
                    setState(() => subStatus = v ?? subStatus),
                decoration: const InputDecoration(
                  labelText: 'Sub-status',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: reasonCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Reason / Notes',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Status updated')));
            },
            child: const Text('Update'),
          ),
        ),
      ],
    );
  }
}

class _FollowUpSchedulerCard extends StatefulWidget {
  @override
  State<_FollowUpSchedulerCard> createState() => _FollowUpSchedulerCardState();
}

class _FollowUpSchedulerCardState extends State<_FollowUpSchedulerCard> {
  DateTime date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay time = const TimeOfDay(hour: 10, minute: 0);
  bool reminder = true;
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Schedule Follow-up',
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: () async {
                  final DateTime now = DateTime.now();
                  final DateTime? d = await showDatePicker(
                    context: context,
                    firstDate: now,
                    lastDate: DateTime(now.year + 2),
                    initialDate: date,
                  );
                  if (d != null) setState(() => date = d);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text('${date.day}/${date.month}/${date.year}'),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final TimeOfDay? t = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (t != null) setState(() => time = t);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Time',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Reminder'),
          value: reminder,
          onChanged: (bool v) => setState(() => reminder = v),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Follow-up set for ${date.day}/${date.month}/${date.year} ${time.format(context)}',
                  ),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}

class _PreferencesCard extends StatefulWidget {
  @override
  State<_PreferencesCard> createState() => _PreferencesCardState();
}

class _PreferencesCardState extends State<_PreferencesCard> {
  String project = 'Project Alpha';
  String unitType = '2 BHK';
  RangeValues budget = const RangeValues(40, 80);
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Project & Unit Preferences',
      children: <Widget>[
        DropdownButtonFormField<String>(
          initialValue: project,
          items:
              const <String>['Project Alpha', 'Project Beta', 'Project Gamma']
                  .map(
                    (String e) =>
                        DropdownMenuItem<String>(value: e, child: Text(e)),
                  )
                  .toList(),
          onChanged: (String? v) => setState(() => project = v ?? project),
          decoration: const InputDecoration(
            labelText: 'Preferred Project',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: unitType,
          items: const <String>['1 BHK', '2 BHK', '3 BHK', 'Penthouse']
              .map(
                (String e) =>
                    DropdownMenuItem<String>(value: e, child: Text(e)),
              )
              .toList(),
          onChanged: (String? v) => setState(() => unitType = v ?? unitType),
          decoration: const InputDecoration(
            labelText: 'Unit Type',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Text('Budget (Lacs)', style: Theme.of(context).textTheme.labelLarge),
        RangeSlider(
          values: budget,
          min: 10,
          max: 200,
          divisions: 38,
          labels: RangeLabels(
            budget.start.toStringAsFixed(0),
            budget.end.toStringAsFixed(0),
          ),
          onChanged: (RangeValues v) => setState(() => budget = v),
        ),
      ],
    );
  }
}

// _MediaAttachmentsCard removed from Lead Detail tab

class _TimelineCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<_TimelineItem> items = <_TimelineItem>[
      _TimelineItem(
        'Note added',
        'Discussed budget range',
        DateTime.now().subtract(const Duration(hours: 2)),
        Icons.note_alt_outlined,
      ),
      _TimelineItem(
        'Call',
        'Call connected for 3m 12s',
        DateTime.now().subtract(const Duration(days: 1)),
        Icons.call_outlined,
      ),
      _TimelineItem(
        'Site visit',
        'Scheduled for tomorrow 11:00 AM',
        DateTime.now().subtract(const Duration(days: 2)),
        Icons.location_on_outlined,
      ),
    ];
    return _SectionCard(
      title: 'Timeline',
      children: <Widget>[
        for (final _TimelineItem it in items) ...<Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                it.icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      it.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(it.desc),
                    const SizedBox(height: 2),
                    Text(
                      _fmt(it.time),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 16),
        ],
      ],
    );
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
}

class _TimelineItem {
  const _TimelineItem(this.title, this.desc, this.time, this.icon);
  final String title;
  final String desc;
  final DateTime time;
  final IconData icon;
}

class _ActivityLogCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> logs = <Map<String, String>>[
      <String, String>{
        'by': 'Anita',
        'action': 'Updated status to Warm',
        'at': '2025-09-20 10:15',
      },
      <String, String>{
        'by': 'Chetan',
        'action': 'Assigned to Team 2',
        'at': '2025-09-18 15:42',
      },
    ];
    return _SectionCard(
      title: 'Activity & Assignment History',
      children: <Widget>[
        ...logs.map(
          (Map<String, String> l) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history),
            title: Text(l['action'] ?? '-'),
            subtitle: Text('${l['by']} • ${l['at']}'),
          ),
        ),
      ],
    );
  }
}

// Removed _badge helper

// Removed _iconText helper

// Removed legacy panel color helpers; all cards use white + shadow now
