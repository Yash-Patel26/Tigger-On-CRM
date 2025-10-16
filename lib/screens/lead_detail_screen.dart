import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../utils/helpers.dart';
// import '../utils/page_transitions.dart';
// import 'add_site_visit_screen.dart';
import 'site_visit_detail_screen.dart';
import '../models/lead_model.dart';
import '../repositories/lead_repository.dart';
import '../models/project_model.dart';
import '../repositories/project_repository.dart';
import '../services/api_service.dart';
import 'project_detail_screen.dart';

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
            // Inline options are now generated where used to avoid unused warnings
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
            Text(
              'Referred To Details',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _referredToCard(context),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.withOpacity(0.2)),
            const SizedBox(height: 12),
            Text(
              'Referred By Details',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _referredByCard(context),
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
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _kvSmall(
                  context,
                  'Referred To Name',
                  '${r['firstName'] ?? ''} ${r['middleName'] ?? ''} ${r['lastName'] ?? ''}'
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .trim(),
                  isLink: true,
                  onTap: () {
                    final String? leadId = r['leadId'];
                    if (leadId == null || leadId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lead not linked to this reference'),
                        ),
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext ctx) =>
                            LeadDetailScreen(leadId: leadId),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _kvSmall(context, 'Referred Date', _formatNowDateTime()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _referredToCard(BuildContext context) {
    final Map<String, String> r = _refs.isNotEmpty
        ? _refs.first
        : <String, String>{};
    return _refCard(context, r);
  }

  Widget _referredByCard(BuildContext context) {
    if (_refs.length < 2) {
      return Container(
        width: double.infinity,
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
        child: const Center(child: Text("Didn't Refer By Anyone")),
      );
    }
    final Map<String, String> r = _refs[1];
    return _refCard(context, r);
  }

  Widget _kvSmall(
    BuildContext context,
    String keyLabel,
    String value, {
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          keyLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        isLink
            ? InkWell(
                onTap: onTap,
                child: Text(
                  value.isEmpty ? '-' : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              )
            : Text(
                value.isEmpty ? '-' : value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
      ],
    );
  }

  String _formatNowDateTime() {
    final DateTime now = DateTime.now();
    final String day = now.day.toString().padLeft(2, '0');
    const List<String> months = <String>[
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
    final String mon = months[now.month - 1];
    final String year = now.year.toString();
    int h = now.hour;
    final bool pm = h >= 12;
    h = h % 12;
    if (h == 0) h = 12;
    final String hh = h.toString().padLeft(2, '0');
    final String mm = now.minute.toString().padLeft(2, '0');
    return '$day $mon $year $hh:$mm ${pm ? 'Pm' : 'Am'}';
  }

  void _openAddRefSheet() {
    final TextEditingController fCtrl = TextEditingController();
    final TextEditingController mCtrl = TextEditingController();
    final TextEditingController lCtrl = TextEditingController();
    final TextEditingController cCtrl = TextEditingController();
    final TextEditingController eCtrl = TextEditingController();
    final TextEditingController noteCtrl = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
          child: Form(
            key: formKey,
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
                Text(
                  'Reference First Name *',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: fCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Reference First Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? v) => (v == null || v.trim().isEmpty)
                      ? 'First name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  'Reference Middle Name',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: mCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Reference Middle Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Reference Last Name',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: lCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Reference Last Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Reference Contact *',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: cCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: 'Reference Contact',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? v) => (v == null || v.trim().isEmpty)
                      ? 'Contact is required'
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  'Reference Email *',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: eCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Reference Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (String? v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Email is required';
                    final bool ok = RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(v.trim());
                    return ok ? null : 'Enter a valid email';
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Reference Requirement Note',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: noteCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Reference Requirement Note',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (!(formKey.currentState?.validate() ?? false)) return;
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
                      _createLeadFromReference(
                        firstName: fCtrl.text.trim(),
                        middleName: mCtrl.text.trim(),
                        lastName: lCtrl.text.trim(),
                        contact: cCtrl.text.trim(),
                        email: eCtrl.text.trim(),
                        note: noteCtrl.text.trim(),
                      );
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Create'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _createLeadFromReference({
    required String firstName,
    required String middleName,
    required String lastName,
    required String contact,
    required String email,
    required String note,
  }) async {
    final String fullName = <String>[
      firstName,
      middleName,
      lastName,
    ].where((String s) => s.trim().isNotEmpty).join(' ');
    final Lead lead = Lead(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      leadId: 'LD-${DateTime.now().millisecondsSinceEpoch % 100000}',
      customerName: fullName.isEmpty ? 'Reference Lead' : fullName,
      email: email,
      phone: contact,
      status: LeadStatus.warm,
      subStatus: LeadSubStatus.newLead,
      source: LeadSource.referral,
      propertyType: PropertyType.residential,
      categoryType: CategoryType.b,
      assignedTo: 'self',
      assignedToName: 'Me',
      createdBy: 'self',
      createdByName: 'Me',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      requirements: note.isEmpty ? null : note,
    );

    try {
      final LeadRepository repo = LeadRepository();
      final response = await repo.createLead(lead);
      if (!mounted) return;
      // Attach a usable leadId to newest reference so tapping the name can open details
      if (_refs.isNotEmpty) {
        final String resolvedLeadId =
            response.data?.leadId ?? response.data?.id ?? lead.leadId;
        setState(() {
          _refs.first['leadId'] = resolvedLeadId;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.success
                ? 'Lead created from reference'
                : (response.message ?? 'Failed to create lead'),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to create lead')));
    }
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
      'status': 'Scheduled',
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
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _kvSmall(context, 'Date', _formatVisitDate(v['from'])),
                const SizedBox(height: 10),
                _kvSmall(context, 'Purpose', v['purpose'] ?? '-'),
                const SizedBox(height: 10),
                _kvSmall(context, 'Location', v['location'] ?? '-'),
                const SizedBox(height: 10),
                _kvSmall(context, 'Status', v['status'] ?? 'Scheduled'),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _kvSmall(context, 'Appointed To', v['attender'] ?? '-'),
                const SizedBox(height: 10),
                _kvSmall(context, 'Mode', v['mode'] ?? '-'),
                const SizedBox(height: 10),
                _kvSmall(context, 'Address', v['address'] ?? '-'),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Text(
                      'Action',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext ctx) =>
                                SiteVisitDetailScreen(
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
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Icon(
                          Icons.visibility,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
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

  Widget _kvSmall(BuildContext context, String keyLabel, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          keyLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, maxLines: 2, overflow: TextOverflow.ellipsis),
      ],
    );
  }

  String _formatVisitDate(String? from) {
    if (from == null || from.isEmpty) return '-';
    try {
      final List<String> parts = from.split(' ');
      final List<String> d = parts[0].split('-');
      final List<String> t = parts[1].split(':');
      final int y = int.parse(d[0]);
      final int m = int.parse(d[1]);
      final int day = int.parse(d[2]);
      int h = int.parse(t[0]);
      final int min = int.parse(t[1]);
      final bool pm = h >= 12;
      h = h % 12;
      if (h == 0) h = 12;
      final String hh = h.toString().padLeft(2, '0');
      final String mm = min.toString().padLeft(2, '0');
      return '${_monthName(m)} ${day.toString().padLeft(2, '0')}, $y\n$hh:$mm ${pm ? 'PM' : 'AM'}';
    } catch (_) {
      return from;
    }
  }

  String _monthName(int m) {
    const List<String> names = <String>[
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
    if (m < 1 || m > 12) return '-';
    return names[m - 1];
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
            // (Options computed inline where needed to avoid unused warnings)
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
      'title': 'Follow up with customer',
      'desc':
          'Call the customer to discuss shortlisted properties and next steps. Share brochure and pricing details via email as requested.',
      'assign': 'Me',
      'priority': 'High',
      'status': 'Open',
    },
    <String, String>{
      'title': 'Schedule site visit',
      'desc':
          'Coordinate a site visit for Saturday afternoon. Confirm availability with the customer and project sales office.',
      'assign': 'Anita',
      'priority': 'Medium',
      'status': 'In Progress',
    },
    <String, String>{
      'title': 'Share loan options',
      'desc':
          'Send comparative home loan options from partner banks along with eligibility checklist and required documents.',
      'assign': 'Chetan',
      'priority': 'Low',
      'status': 'Completed',
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
                        ...tasks.asMap().entries.map(
                          (MapEntry<int, Map<String, String>> e) => Container(
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
                                  e.value['title'] ?? '-',
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(e.value['desc'] ?? '-'),
                                const SizedBox(height: 4),
                                Text(
                                  'Assign To: ${e.value['assign']} • Priority: ${e.value['priority']} • Status: ${e.value['status']}',
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _openChangeStatusDialog(e.key),
                                      icon: const Icon(
                                        Icons.sync_alt_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Change Status'),
                                    ),
                                    const SizedBox(width: 8),
                                    FilledButton.icon(
                                      onPressed: () =>
                                          _openEditTaskDialog(e.key),
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        size: 18,
                                      ),
                                      label: const Text('Edit'),
                                    ),
                                  ],
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
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            return AlertDialog(
              title: const Text('Create Task'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _datePicker(
                              context,
                              'Start Date *',
                              startDate,
                              (DateTime d) => setModal(() => startDate = d),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _timePicker(
                              context,
                              'Start Time *',
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
                              'End Date *',
                              endDate,
                              (DateTime d) => setModal(() => endDate = d),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _timePicker(
                              context,
                              'End Time *',
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
                                labelText: 'Assign To *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (String? v) =>
                                  (v == null || v.isEmpty) ? 'Required' : null,
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
                                labelText: 'Priority *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (String? v) =>
                                  (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
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
                  label: const Text('Add Task'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openChangeStatusDialog(int index) {
    final List<String> statuses = <String>[
      'Open',
      'In Progress',
      'Completed',
      'Cancelled',
    ];
    String selected = tasks[index]['status'] ?? 'Open';
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateDialog) {
            return AlertDialog(
              title: const Text('Change Status'),
              content: DropdownButtonFormField<String>(
                value: selected,
                items: statuses
                    .map(
                      (String s) =>
                          DropdownMenuItem<String>(value: s, child: Text(s)),
                    )
                    .toList(),
                onChanged: (String? v) =>
                    setStateDialog(() => selected = v ?? selected),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    setState(() {
                      tasks[index]['status'] = selected;
                    });
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openEditTaskDialog(int index) {
    final TextEditingController titleCtrl = TextEditingController(
      text: tasks[index]['title'] ?? '',
    );
    final TextEditingController descCtrl = TextEditingController(
      text: tasks[index]['desc'] ?? '',
    );
    String assignTo = tasks[index]['assign'] ?? 'Me';
    String priority = tasks[index]['priority'] ?? 'Medium';
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: titleCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? v) =>
                            (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: assignTo,
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
                          labelText: 'Assign To *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: priority,
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
                          labelText: 'Priority *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    setState(() {
                      tasks[index]['title'] = titleCtrl.text.trim();
                      tasks[index]['desc'] = descCtrl.text.trim();
                      tasks[index]['assign'] = assignTo;
                      tasks[index]['priority'] = priority;
                    });
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
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
  final Map<int, String> _selectedProjectByIndex = <int, String>{};
  List<Project> _projects = <Project>[];
  final List<Map<String, String>> _items = <Map<String, String>>[
    {
      'category': 'Residential',
      'propertyType': '2 BHK Apartment',
      'projectName': 'Green Valley Heights',
      'optionType': 'Fresh',
      'state': 'Gujarat',
      'city': 'Ahmedabad',
      'location': 'Gift City',
    },
    {
      'category': 'Commercial',
      'propertyType': 'Office Space',
      'projectName': 'Business Park Plaza',
      'optionType': 'Resale',
      'state': 'Maharashtra',
      'city': 'Mumbai',
      'location': 'BKC',
    },
    {
      'category': 'Residential',
      'propertyType': '3 BHK Villa',
      'projectName': 'Luxury Gardens',
      'optionType': 'Fresh',
      'state': 'Haryana',
      'city': 'Gurugram',
      'location': 'NH 48, Part 2',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final ProjectRepository repo = ProjectRepository();
      final ApiResponse<List<Project>> res = await repo.getProjects(limit: 50);
      if (!mounted) return;
      setState(() {
        _projects = res.data ?? <Project>[];
      });
    } catch (_) {
      // Fallback demo data if API not available
      setState(() {
        _projects = <Project>[
          Project(
            id: 'p1',
            name: 'Green Valley Heights',
            developerId: 'd1',
            developerName: 'GV Dev',
            type: ProjectType.residential,
            status: ProjectStatus.planning,
            city: 'Ahmedabad',
            state: 'Gujarat',
            startingPrice: 4500000,
            isActive: true,
            createdBy: 'sys',
            createdByName: 'System',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Project(
            id: 'p2',
            name: 'Business Park Plaza',
            developerId: 'd2',
            developerName: 'BP Dev',
            type: ProjectType.commercial,
            status: ProjectStatus.planning,
            city: 'Mumbai',
            state: 'Maharashtra',
            startingPrice: 12000000,
            isActive: true,
            createdBy: 'sys',
            createdByName: 'System',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
      });
    }
  }

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
                onPressed: _openAddPropertyOptionScreen,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Select',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey.shade700,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Checkbox(
                                          value: false,
                                          onChanged: null,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Project',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey.shade700,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['projectName'] ?? '-',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Action',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey.shade700,
                                              ),
                                        ),
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: <Widget>[
                                            _actionChip(
                                              Icons.visibility,
                                              Colors.blue,
                                              onTap: () {
                                                final String? pid =
                                                    _selectedProjectByIndex[index];
                                                Project? proj;
                                                if (pid != null &&
                                                    pid.isNotEmpty) {
                                                  try {
                                                    proj = _projects.firstWhere(
                                                      (Project p) =>
                                                          p.id == pid,
                                                    );
                                                  } catch (_) {
                                                    proj = _projects.isNotEmpty
                                                        ? _projects.first
                                                        : null;
                                                  }
                                                }
                                                final Map<String, dynamic>
                                                payload = <String, dynamic>{
                                                  'name':
                                                      proj?.name ??
                                                      (item['projectName'] ??
                                                          '-'),
                                                  'category':
                                                      item['category'] ??
                                                      'Residential',
                                                  'currentPrice':
                                                      proj?.maxPrice ??
                                                      proj?.startingPrice,
                                                  'launchPrice':
                                                      proj?.startingPrice,
                                                  'price': proj?.startingPrice,
                                                  'reraNo': proj?.reraNumber,
                                                  'reraAuthority': 'HRERA',
                                                  'location': item['location'],
                                                  'city': item['city'],
                                                  'state': item['state'],
                                                };
                                                Navigator.of(context).push(
                                                  MaterialPageRoute<void>(
                                                    builder:
                                                        (BuildContext ctx) =>
                                                            ProjectDetailScreen(
                                                              project: payload,
                                                            ),
                                                  ),
                                                );
                                              },
                                            ),
                                            _actionChip(
                                              Icons.link,
                                              Colors.teal,
                                              onTap: () {
                                                final String url =
                                                    _buildPropertyOptionUrl(
                                                      item,
                                                    );
                                                Clipboard.setData(
                                                  ClipboardData(text: url),
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('URL copied'),
                                                  ),
                                                );
                                              },
                                            ),
                                            _actionChip(
                                              Icons.chat_bubble,
                                              Colors.lightBlue,
                                              onTap: () {
                                                final String msg =
                                                    _buildShareMessage(item);
                                                Clipboard.setData(
                                                  ClipboardData(text: msg),
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Message copied',
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            _actionChip(
                                              Icons.share,
                                              Colors.green,
                                              onTap: () async {
                                                final String msg =
                                                    _buildShareMessage(item);
                                                final Uri wa = Uri.parse(
                                                  'https://wa.me/?text=${Uri.encodeComponent(msg)}',
                                                );
                                                if (await canLaunchUrl(wa)) {
                                                  await launchUrl(
                                                    wa,
                                                    mode: LaunchMode
                                                        .externalApplication,
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Unable to open WhatsApp',
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                            _actionChip(
                                              Icons.delete,
                                              Colors.red,
                                              onTap: () {
                                                setState(() {
                                                  _items.removeAt(index);
                                                });
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Deleted'),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Property Type',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey.shade700,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item['category'] ?? '-',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Project/Inventories sections removed per request
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

  // Removed key/value badges display

  // Removed project dropdown and inventory list per requirement.

  Widget _actionChip(IconData icon, Color color, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  String _buildPropertyOptionUrl(Map<String, String> item) {
    final String name = Uri.encodeComponent(item['projectName'] ?? 'project');
    return 'https://tiggeron.com/projects/$name';
  }

  String _buildShareMessage(Map<String, String> item) {
    final String name = item['projectName'] ?? '-';
    final String cat = item['category'] ?? '-';
    final String loc = [
      item['city'],
      item['state'],
    ].where((e) => (e ?? '').isNotEmpty).join(', ');
    final String url = _buildPropertyOptionUrl(item);
    return 'Check out $name ($cat) at $loc\n$url';
  }

  Future<void> _openAddPropertyOptionScreen() async {
    final Map<String, String>? result = await Navigator.of(context).push(
      MaterialPageRoute<Map<String, String>>(
        builder: (BuildContext ctx) => const CreatePropertyOptionScreen(),
      ),
    );
    if (result != null) {
      setState(() {
        _items.insert(0, result);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Property option created')));
    }
  }
}

class CreatePropertyOptionScreen extends StatefulWidget {
  const CreatePropertyOptionScreen();
  @override
  State<CreatePropertyOptionScreen> createState() =>
      _CreatePropertyOptionScreenState();
}

class _CreatePropertyOptionScreenState
    extends State<CreatePropertyOptionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String optionType = '';
  String projectName = '';
  String category = '';
  String propertyType = '';
  String stateValue = '';
  String cityValue = '';
  String location = '';
  final TextEditingController _descCtrl = TextEditingController();
  final List<Project> _projects = <Project>[];
  final Set<String> _selectedProjectIds = <String>{};

  void _clear() {
    setState(() {
      optionType = projectName = category = propertyType = stateValue =
          cityValue = location = '';
      _descCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Property Option')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _label('Option Type *'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: optionType.isEmpty ? null : optionType,
                      items: const <String>['Fresh', 'Resale']
                          .map(
                            (String e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (String? v) =>
                          setState(() => optionType = v ?? optionType),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select',
                      ),
                      validator: (String? v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _label('Project Name *'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: projectName.isEmpty ? null : projectName,
                      items:
                          const <String>[
                                'Green Valley Heights',
                                'Business Park Plaza',
                                'Luxury Gardens',
                              ]
                              .map(
                                (String e) => DropdownMenuItem<String>(
                                  value: e,
                                  child: Text(e),
                                ),
                              )
                              .toList(),
                      onChanged: (String? v) =>
                          setState(() => projectName = v ?? projectName),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select',
                      ),
                      validator: (String? v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _label('Category'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: category.isEmpty ? null : category,
                      items: const <String>['Residential', 'Commercial']
                          .map(
                            (String e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (String? v) =>
                          setState(() => category = v ?? category),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _label('Property Type'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: propertyType.isEmpty ? null : propertyType,
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
                          setState(() => propertyType = v ?? propertyType),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _label('State'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: stateValue.isEmpty ? null : stateValue,
                                items:
                                    const <String>[
                                          'Gujarat',
                                          'Maharashtra',
                                          'Haryana',
                                        ]
                                        .map(
                                          (String e) =>
                                              DropdownMenuItem<String>(
                                                value: e,
                                                child: Text(e),
                                              ),
                                        )
                                        .toList(),
                                onChanged: (String? v) => setState(
                                  () => stateValue = v ?? stateValue,
                                ),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Select',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _label('City'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: cityValue.isEmpty ? null : cityValue,
                                items:
                                    const <String>[
                                          'Ahmedabad',
                                          'Mumbai',
                                          'Gurugram',
                                        ]
                                        .map(
                                          (String e) =>
                                              DropdownMenuItem<String>(
                                                value: e,
                                                child: Text(e),
                                              ),
                                        )
                                        .toList(),
                                onChanged: (String? v) =>
                                    setState(() => cityValue = v ?? cityValue),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Select',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _label('Location'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: location.isEmpty ? null : location,
                      items: const <String>['Gift City', 'NH 48, Part 2']
                          .map(
                            (String e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (String? v) =>
                          setState(() => location = v ?? location),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        OutlinedButton(
                          onPressed: _clear,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Projects list card
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.list_alt,
                          size: 18,
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Projects',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(height: 220, child: _buildProjectsList()),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Inventories list card
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.list_alt,
                          size: 18,
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Inventories',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(height: 220, child: _buildInventoriesList()),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Save button
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    final Map<String, String> payload = <String, String>{
                      'optionType': optionType,
                      'projectName': projectName,
                      'category': category,
                      'propertyType': propertyType,
                      'state': stateValue,
                      'city': cityValue,
                      'location': location,
                    };
                    Navigator.of(context).pop(payload);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(
    t,
    style: Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
  );

  Widget _buildProjectsList() {
    // Use repository if available; for now build demo if empty
    final List<Project> items = _projects.isNotEmpty
        ? _projects
        : <Project>[
            Project(
              id: 'p1',
              name: '32 Milestone',
              developerId: 'd1',
              developerName: 'XYZ Dev',
              type: ProjectType.residential,
              status: ProjectStatus.planning,
              city: 'Gurugram',
              state: 'Haryana',
              startingPrice: 15000,
              priceUnit: 'Square Feet',
              isActive: true,
              createdBy: 'sys',
              createdByName: 'System',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
            Project(
              id: 'p2',
              name: '3B Homes Pataudi One',
              developerId: 'd2',
              developerName: 'ABC Dev',
              type: ProjectType.residential,
              status: ProjectStatus.planning,
              city: 'Gurugram',
              state: 'Haryana',
              startingPrice: 0,
              isActive: true,
              createdBy: 'sys',
              createdByName: 'System',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ];

    return Scrollbar(
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (BuildContext context, int i) {
          final Project p = items[i];
          final bool checked = _selectedProjectIds.contains(p.id);
          final String typeText =
              p.type.name[0].toUpperCase() + p.type.name.substring(1);
          final String startText =
              p.startingPrice != null && p.startingPrice! > 0
              ? '₹ ${p.startingPrice!.toStringAsFixed(0)} / ${p.priceUnit ?? ''}'
                    .trim()
              : '-';
          final String locationText = <String?>[
            p.address,
            p.city,
            p.state,
          ].where((String? s) => (s ?? '').isNotEmpty).join(', ');

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(
                value: checked,
                onChanged: (bool? v) {
                  setState(() {
                    if (v == true) {
                      _selectedProjectIds.add(p.id);
                    } else {
                      _selectedProjectIds.remove(p.id);
                    }
                  });
                },
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: <Widget>[
                        Text(
                          p.name,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text('/', style: Theme.of(context).textTheme.bodySmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Text(
                            typeText,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: <TextSpan>[
                          const TextSpan(
                            text: 'Starting From : ',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: startText,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: <TextSpan>[
                          const TextSpan(
                            text: 'Location : ',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: locationText.isEmpty ? '-' : locationText,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInventoriesList() {
    final List<Map<String, String>> inventories = <Map<String, String>>[
      <String, String>{
        'name': '2 BHK',
        'project': 'ADORE THE SELECT PREMIA',
        'type': 'Appartments',
      },
      <String, String>{
        'name': '3 BHK',
        'project': 'Green Valley Heights',
        'type': 'Appartments',
      },
      <String, String>{
        'name': 'Retail-12',
        'project': 'Business Park Plaza',
        'type': 'Shop',
      },
    ];

    return Scrollbar(
      child: ListView.separated(
        itemCount: inventories.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (BuildContext context, int i) {
          final Map<String, String> inv = inventories[i];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Checkbox(value: false, onChanged: null),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          inv['name'] ?? '-',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text('/', style: Theme.of(context).textTheme.bodySmall),
                        Text(
                          inv['project'] ?? '-',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: <TextSpan>[
                          const TextSpan(
                            text: 'Type : ',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: inv['type'] ?? '-',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
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
      'createdAt': "${0}", // placeholder to be set in initState
    },
    {
      'id': 'TKT-002',
      'title': 'Document Verification Delay',
      'description':
          'KYC documents are taking longer than expected to get verified.',
      'createdBy': 'Anita',
      'priority': 'Medium',
      'createdAt': "${0}",
    },
    {
      'id': 'TKT-003',
      'title': 'Site Visit Scheduling',
      'description':
          'Need to coordinate site visit for multiple customers on the same day.',
      'createdBy': 'Chetan',
      'priority': 'Low',
      'createdAt': "${0}",
    },
  ];

  @override
  void initState() {
    super.initState();
    // Stamp demo data with creation times spread over hours for display
    final DateTime now = DateTime.now();
    _items[0]['createdAt'] = now
        .subtract(const Duration(hours: 1))
        .toIso8601String();
    if (_items.length > 1) {
      _items[1]['createdAt'] = now
          .subtract(const Duration(hours: 5))
          .toIso8601String();
    }
    if (_items.length > 2) {
      _items[2]['createdAt'] = now
          .subtract(const Duration(hours: 23))
          .toIso8601String();
    }
    setState(() {});
  }

  String _formatRelative(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    DateTime? ts;
    try {
      ts = DateTime.tryParse(iso)?.toLocal();
    } catch (_) {
      ts = null;
    }
    if (ts == null) return '-';
    final Duration diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    final int days = diff.inDays;
    return days == 1 ? '1d ago' : '${days}d ago';
  }

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
                                  Expanded(
                                    child: Tooltip(
                                      message: item['id'] ?? '-',
                                      child: Text(
                                        item['id'] ?? '-',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
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
                              Tooltip(
                                message: item['title'] ?? '-',
                                child: Text(
                                  item['title'] ?? '-',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              if ((item['description'] ?? '')
                                  .isNotEmpty) ...<Widget>[
                                const SizedBox(height: 6),
                                Tooltip(
                                  message: item['description']!,
                                  child: Text(
                                    item['description']!,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade400,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatRelative(item['createdAt']),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: <Widget>[
                                  OutlinedButton.icon(
                                    onPressed: () => _viewTicket(item),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      side: BorderSide(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withOpacity(0.4),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.visibility_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('View'),
                                  ),
                                  FilledButton.icon(
                                    onPressed: () =>
                                        _openEditTicketSheet(index),
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('Edit'),
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

  void _viewTicket(Map<String, String> item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => TicketDetailScreen(ticket: item)),
    );
  }

  void _openEditTicketSheet(int index) {
    final Map<String, String> item = _items[index];
    final TextEditingController idCtrl = TextEditingController(
      text: item['id'] ?? '',
    );
    final TextEditingController titleCtrl = TextEditingController(
      text: item['title'] ?? '',
    );
    final TextEditingController descCtrl = TextEditingController(
      text: item['description'] ?? '',
    );
    String createdBy = item['createdBy'] ?? 'Me';
    String priority = item['priority'] ?? 'Medium';

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
                        'Edit Ticket',
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
                          value: createdBy,
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
                          value: priority,
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
                          _items[index] = <String, String>{
                            'id': idCtrl.text.trim(),
                            'title': titleCtrl.text.trim(),
                            'description': descCtrl.text.trim(),
                            'createdBy': createdBy,
                            'priority': priority,
                          };
                        });
                        Navigator.of(ctx).pop();
                      },
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Save'),
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

  void _openCreateTicketSheet() {
    final TextEditingController registeredMobileCtrl = TextEditingController();
    final TextEditingController contactNameCtrl = TextEditingController();
    final TextEditingController issueTitleCtrl = TextEditingController();
    final TextEditingController alternateMobileCtrl = TextEditingController();
    final TextEditingController unitNumberCtrl = TextEditingController();
    final TextEditingController issueDescriptionCtrl = TextEditingController();

    String? ticketCategory = 'Customer';
    String? leadList;
    String? vendorList;
    String? ticketType;
    String? serviceType;
    String? priority = 'Low';
    String? assignTo;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Single column form layout (with conditional fields)
                  Builder(
                    builder: (BuildContext context) {
                      final bool isInternal = ticketCategory == 'Internal';
                      final bool isVendor = ticketCategory == 'Vendor';
                      return Column(
                        children: <Widget>[
                          _buildDropdownField(
                            'Ticket Category*',
                            ticketCategory,
                            const <String>['Customer', 'Vendor', 'Internal'],
                            (String? v) => setModal(() => ticketCategory = v),
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),

                          if (!isInternal)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Expanded(
                                  child: _buildTextField(
                                    'Registered Mobile*',
                                    registeredMobileCtrl,
                                    isRequired: true,
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Fetching details...'),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Fetch Details'),
                                  ),
                                ),
                              ],
                            ),
                          if (!isInternal) const SizedBox(height: 16),

                          if (!isInternal && !isVendor)
                            _buildDropdownField(
                              'Lead List*',
                              leadList,
                              List<String>.generate(12, (int i) {
                                if (i == 0) return 'Mayank11 · 9816353871';
                                return 'Customer ${i + 1} · ${9000000000 + i}';
                              }),
                              (String? v) => setModal(() => leadList = v),
                              isRequired: true,
                            ),
                          if (!isInternal && !isVendor)
                            const SizedBox(height: 16),

                          if (!isInternal && isVendor)
                            _buildDropdownField(
                              'Vendor List*',
                              vendorList,
                              const <String>['Skyline Builders', 'GreenHomes'],
                              (String? v) => setModal(() => vendorList = v),
                              isRequired: true,
                            ),
                          if (!isInternal && isVendor)
                            const SizedBox(height: 16),

                          _buildDropdownField(
                            'Service Type*',
                            serviceType,
                            const <String>[
                              'Maintenance',
                              'Repair',
                              'Cleaning',
                              'Installation',
                            ],
                            (String? v) => setModal(() => serviceType = v),
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField('Contact Name', contactNameCtrl),
                          const SizedBox(height: 16),

                          _buildTextField('Issue Title', issueTitleCtrl),
                          const SizedBox(height: 16),

                          _buildDropdownField(
                            'Assign To',
                            assignTo,
                            const <String>['Anita', 'Ravi', 'Sunil', 'Chetan'],
                            (String? v) => setModal(() => assignTo = v),
                          ),
                          const SizedBox(height: 16),

                          _buildDropdownField(
                            'Ticket Type*',
                            ticketType,
                            const <String>[
                              'Issue',
                              'Request',
                              'Complaint',
                              'Enquiry',
                            ],
                            (String? v) => setModal(() => ticketType = v),
                            isRequired: true,
                          ),
                          const SizedBox(height: 16),

                          _buildDropdownField(
                            'Priority',
                            priority,
                            const <String>['Low', 'Medium', 'High', 'Critical'],
                            (String? v) => setModal(() => priority = v),
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            'Alternate Mobile Number',
                            alternateMobileCtrl,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),

                          _buildTextField('Unit Number', unitNumberCtrl),
                          const SizedBox(height: 16),

                          _buildTextField(
                            'Issues Description',
                            issueDescriptionCtrl,
                            maxLines: 4,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Create Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final bool isInternal = ticketCategory == 'Internal';
                        final bool isVendor = ticketCategory == 'Vendor';
                        final bool needMobile = !isInternal;
                        final bool needLead = !isInternal && !isVendor;
                        final bool needVendor = !isInternal && isVendor;

                        final bool missingMobile =
                            needMobile &&
                            registeredMobileCtrl.text.trim().isEmpty;
                        final bool missingLead = needLead && (leadList == null);
                        final bool missingVendor =
                            needVendor && (vendorList == null);
                        final bool missingService = serviceType == null;
                        final bool missingType = ticketType == null;

                        if (ticketCategory == null ||
                            missingMobile ||
                            missingLead ||
                            missingVendor ||
                            missingService ||
                            missingType) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all required fields'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _items.insert(0, <String, String>{
                            'id':
                                'TKT-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                            'title': issueTitleCtrl.text.trim().isNotEmpty
                                ? issueTitleCtrl.text.trim()
                                : 'Ticket for ${registeredMobileCtrl.text.trim()}',
                            'description':
                                issueDescriptionCtrl.text.trim().isNotEmpty
                                ? issueDescriptionCtrl.text.trim()
                                : 'Category: $ticketCategory, Type: $ticketType, Service: $serviceType',
                            'createdBy': assignTo ?? 'Me',
                            'priority': priority ?? 'Low',
                          });
                        });
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ticket created successfully'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            hintText: 'Select',
            hintStyle: TextStyle(color: Colors.grey.shade500),
          ),
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          dropdownColor: Colors.white,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.green, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            hintText: label,
            hintStyle: TextStyle(color: Colors.grey.shade500),
          ),
          style: const TextStyle(color: Colors.black87, fontSize: 14),
        ),
      ],
    );
  }
}

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({super.key, required this.ticket});

  final Map<String, String> ticket;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  late String _status;
  late String _assignedTo;
  final List<Map<String, String>> _allocationLogs = <Map<String, String>>[];
  final List<Map<String, String>> _dispositionLogs = <Map<String, String>>[];
  final List<Map<String, String>> _conversationLogs = <Map<String, String>>[];

  @override
  void initState() {
    super.initState();
    _status = 'Open';
    _assignedTo = '-';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _header(context),
          const SizedBox(height: 12),
          _meta(context),
          const SizedBox(height: 16),
          DefaultTabController(
            length: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  decoration: _cardDecoration(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: const TabBar(
                    indicatorColor: Colors.blue,
                    labelColor: Colors.black,
                    tabs: <Widget>[
                      Tab(text: 'Ticket Info'),
                      Tab(text: 'Customer Info'),
                      Tab(text: 'Conversation'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 240,
                  child: TabBarView(
                    children: <Widget>[
                      _infoPanel(context),
                      _customerInfo(context),
                      _conversation(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          DefaultTabController(
            length: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  decoration: _cardDecoration(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: const TabBar(
                    indicatorColor: Colors.blue,
                    labelColor: Colors.black,
                    tabs: <Widget>[
                      Tab(text: 'Disposition Logs'),
                      Tab(text: 'Allocation Logs'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: TabBarView(
                    children: <Widget>[
                      _dispositionLogsView(context),
                      _allocationLogsView(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.ticket['title'] ?? '-',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              Text(
                'Ticket Id : ${widget.ticket['id'] ?? '-'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              Chip(label: Text(widget.ticket['priority'] ?? '-')),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              OutlinedButton(
                onPressed: _openDispositionSheet,
                child: const Text('Disposition'),
              ),
              FilledButton(
                onPressed: _status == 'Disposed' ? null : _openAssignSheet,
                child: const Text('Assign'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _meta(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        children: <Widget>[
          _metaRow(context, 'Created At', _nowString()),
          _divider(),
          _metaRow(context, 'Status', _status),
          _divider(),
          _metaRow(context, 'Issue Related To', widget.ticket['title'] ?? '-'),
          _divider(),
          _metaRow(context, 'Contact Number', '-'),
          _divider(),
          _metaRow(context, 'Priority', widget.ticket['priority'] ?? '-'),
          _divider(),
          _metaRow(context, 'Assigned By', widget.ticket['createdBy'] ?? '-'),
          _divider(),
          _metaRow(context, 'Assigned To', _assignedTo),
        ],
      ),
    );
  }

  Widget _infoPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _twoCol(
              context,
              'Service Category',
              'Customer',
              'Service Name',
              '—',
            ),
            const SizedBox(height: 12),
            _twoCol(
              context,
              'Service Type',
              'General Query',
              'Alternate Mobile Number',
              '—',
            ),
            const SizedBox(height: 12),
            _twoCol(
              context,
              'Issue Title',
              widget.ticket['title'] ?? '-',
              'Unit Number',
              '—',
            ),
            const SizedBox(height: 12),
            _twoCol(
              context,
              'Contact Person',
              widget.ticket['createdBy'] ?? '-',
              'Priority',
              widget.ticket['priority'] ?? '-',
            ),
            const SizedBox(height: 16),
            Text('Description', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            Text(
              widget.ticket['description']?.trim().isEmpty == true
                  ? '—'
                  : widget.ticket['description']!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _twoCol(
    BuildContext context,
    String l1,
    String v1,
    String l2,
    String v2,
  ) {
    return Row(
      children: <Widget>[
        Expanded(child: _kv(context, l1, v1)),
        const SizedBox(width: 16),
        Expanded(child: _kv(context, l2, v2)),
      ],
    );
  }

  Widget _kv(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _metaRow(BuildContext context, String k, String v) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(k)),
        Text(v, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget _divider() => Divider(color: Colors.grey.withOpacity(0.2));

  BoxDecoration _cardDecoration() => BoxDecoration(
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
  );

  String _nowString() {
    final DateTime now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')} ${_month(now.month)} ${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _month(int m) {
    const List<String> names = <String>[
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
    return names[(m - 1).clamp(0, 11)];
  }

  Widget _customerInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _twoCol(context, 'Customer Name', '—', 'Contact Number', '—'),
            const SizedBox(height: 12),
            _twoCol(context, 'Email', '—', 'City', '—'),
            const SizedBox(height: 12),
            Text('Address', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 6),
            const Text('—'),
          ],
        ),
      ),
    );
  }

  Widget _conversation(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Conversation',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _openReplySheet,
                  child: const Text('Reply'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Replied By',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Replied At',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            if (_conversationLogs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('No replies yet.'),
              )
            else
              ..._conversationLogs.map((Map<String, String> log) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Text(log['repliedBy'] ?? '-')),
                      Expanded(
                        child: Text(
                          log['repliedAt'] ?? '-',
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _openReplySheet() {
    String repliedBy = 'Agent';
    final TextEditingController messageCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Add Reply',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text('Replied By'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: repliedBy,
                items: const <String>['Agent', 'Customer']
                    .map(
                      (String e) =>
                          DropdownMenuItem<String>(value: e, child: Text(e)),
                    )
                    .toList(),
                onChanged: (String? v) => repliedBy = v ?? repliedBy,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              const Text('Message'),
              const SizedBox(height: 6),
              TextFormField(
                controller: messageCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write your reply... ',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _conversationLogs.insert(0, <String, String>{
                        'repliedBy': repliedBy,
                        'repliedAt': _nowString(),
                        'message': messageCtrl.text.trim(),
                      });
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Reply added')),
                    );
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _allocationLogsView(BuildContext context) {
    if (_allocationLogs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: const Center(child: Text('No allocation logs')),
      );
    }
    return ListView.separated(
      itemCount: _allocationLogs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext _, int i) {
        final Map<String, String> log = _allocationLogs[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _metaRow(context, 'Assigned By', log['assignedBy'] ?? '-'),
              _divider(),
              _metaRow(context, 'Assigned To', log['assignedTo'] ?? '-'),
              _divider(),
              _metaRow(context, 'Assigned At', log['assignedAt'] ?? '-'),
              const SizedBox(height: 6),
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                (log['description'] ?? '').isEmpty ? '—' : log['description']!,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _dispositionLogsView(BuildContext context) {
    if (_dispositionLogs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: const Center(child: Text('No disposition logs')),
      );
    }
    return ListView.separated(
      itemCount: _dispositionLogs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext _, int i) {
        final Map<String, String> log = _dispositionLogs[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _metaRow(context, 'Disposed At', log['disposedAt'] ?? '-'),
              _divider(),
              _metaRow(context, 'Disposed By', log['disposedBy'] ?? '-'),
              _divider(),
              _metaRow(context, 'Disposed From', log['disposedFrom'] ?? '-'),
            ],
          ),
        );
      },
    );
  }

  void _openAssignSheet() {
    String selected = _assignedTo == '-' ? 'Abhishek' : _assignedTo;
    final TextEditingController descCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Assign Ticket',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text('Assign To'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selected,
                items:
                    const <String>[
                          'Abhishek',
                          'Anita',
                          'Ravi',
                          'Sunil',
                          'Chetan',
                        ]
                        .map(
                          (String e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                onChanged: (String? v) => selected = v ?? selected,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              const Text('Description'),
              const SizedBox(height: 6),
              TextFormField(
                controller: descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _assignedTo = selected;
                      _allocationLogs.insert(0, <String, String>{
                        'assignedBy': 'Me',
                        'assignedTo': selected,
                        'assignedAt': _nowString(),
                        'description': descCtrl.text.trim(),
                      });
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Assigned to $selected')),
                    );
                  },
                  child: const Text('Assign'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDispositionSheet() {
    String mainDisp = 'New';
    String subDisp = 'Created';
    DateTime date = DateTime.now();
    TimeOfDay time = const TimeOfDay(hour: 13, minute: 0);
    bool initiatedByAgent = true; // false => Customer
    final TextEditingController remarkCtrl = TextEditingController();

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
                bottom: 16 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Text(
                        'Ticket Disposition',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
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

                  // Main Disposition
                  DropdownButtonFormField<String>(
                    value: mainDisp,
                    items:
                        const <String>[
                              'New',
                              'In Progress',
                              'Follow-up',
                              'Closed',
                            ]
                            .map(
                              (String e) => DropdownMenuItem<String>(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                    onChanged: (String? v) =>
                        setModal(() => mainDisp = v ?? mainDisp),
                    decoration: const InputDecoration(
                      labelText: 'Main Disposition *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Sub Disposition
                  DropdownButtonFormField<String>(
                    value: subDisp,
                    items:
                        const <String>[
                              'Created',
                              'Called',
                              'Rescheduled',
                              'Resolved',
                            ]
                            .map(
                              (String e) => DropdownMenuItem<String>(
                                value: e,
                                child: Text(e),
                              ),
                            )
                            .toList(),
                    onChanged: (String? v) =>
                        setModal(() => subDisp = v ?? subDisp),
                    decoration: const InputDecoration(
                      labelText: 'Sub Disposition *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Follow-Up Date Time
                  const Text('Follow-Up Date Time *'),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final DateTime? d = await showDatePicker(
                              context: ctx,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 365),
                              ),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                              initialDate: date,
                            );
                            if (d != null) setModal(() => date = d);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final TimeOfDay? t = await showTimePicker(
                              context: ctx,
                              initialTime: time,
                            );
                            if (t != null) setModal(() => time = t);
                          },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              '${time.hourOfPeriod.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} ${time.period == DayPeriod.am ? 'am' : 'pm'}',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Initiated By
                  const Text('Initiated By'),
                  const SizedBox(height: 6),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Agent'),
                          selected: initiatedByAgent,
                          onSelected: (bool s) =>
                              setModal(() => initiatedByAgent = true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('Customer'),
                          selected: !initiatedByAgent,
                          onSelected: (bool s) =>
                              setModal(() => initiatedByAgent = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Remark
                  TextFormField(
                    controller: remarkCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Remark',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (mainDisp.isEmpty || subDisp.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please complete required fields'),
                            ),
                          );
                          return;
                        }
                        setState(() {
                          _dispositionLogs.insert(0, <String, String>{
                            'disposedAt': _nowString(),
                            'disposedBy': initiatedByAgent
                                ? 'Agent'
                                : 'Customer',
                            'disposedFrom': initiatedByAgent
                                ? 'System'
                                : 'Portal',
                          });
                        });
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Disposition saved')),
                        );
                      },
                      child: const Text('Save Changes'),
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
