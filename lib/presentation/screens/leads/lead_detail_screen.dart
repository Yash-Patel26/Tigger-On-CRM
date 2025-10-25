import 'package:flutter/material.dart';
import 'package:realtime_client/realtime_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'dart:math' as math;
import '../../../../shared/utils/helpers.dart';
import '../projects/site_visit_detail_screen.dart';
import '../../../../data/repositories/lead_repository.dart';
import '../../../../data/repositories/site_visit_repository.dart';
import '../../../../data/repositories/task_repository.dart';
import '../../../../data/repositories/ticket_repository.dart';
import '../../../../data/services/api_service.dart' as api;
import '../../../../data/services/database_service.dart';
import '../../../../data/services/database_service_masters.dart' as masters;
import '../../../../data/services/master_data_service.dart';
import '../../../../data/models/models.dart';

class LeadDetailScreen extends StatefulWidget {
  const LeadDetailScreen({super.key, required this.leadId});

  final String leadId;

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  final LeadRepository _leadRepository = LeadRepository();

  late Future<Lead> _leadFuture;
  RealtimeChannel? _leadRealtimeChannel;
  bool _isRealtimeConnected = false;

  @override
  void initState() {
    super.initState();
    _leadFuture = _fetchLead();
    _subscribeToLeadUpdates();
  }

  Future<Lead> _fetchLead() async {
    final response = await _leadRepository.getLead(widget.leadId);
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.error ?? 'Failed to load lead');
  }

  void refreshLead() {
    if (!mounted) return;
    setState(() {
      _leadFuture = _fetchLead();
    });
  }

  void _subscribeToLeadUpdates() {
    // Listen for updates to this lead and refresh UI in realtime
    final client = supabase.Supabase.instance.client;
    _leadRealtimeChannel = client.channel('public:leads:${widget.leadId}');

    _leadRealtimeChannel!
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.update,
          schema: 'public',
          table: 'leads',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: widget.leadId,
          ),
          callback: (PostgresChangePayload payload) {
            if (!mounted) return;
            print('Real-time update received for lead: ${widget.leadId}');
            print(
              'Payload event: ${payload.eventType}, old: ${payload.oldRecord}, new: ${payload.newRecord}',
            );

            // Refresh the lead data
            setState(() {
              _leadFuture = _fetchLead();
            });

            // Show a subtle notification that the data was updated
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lead information updated'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          },
        )
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.insert,
          schema: 'public',
          table: 'leads',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: widget.leadId,
          ),
          callback: (PostgresChangePayload payload) {
            if (!mounted) return;
            print('Real-time insert received for lead: ${widget.leadId}');
            setState(() {
              _leadFuture = _fetchLead();
            });
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
  void dispose() {
    _leadRealtimeChannel?.unsubscribe();
    super.dispose();
  }

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
                widget.leadId,
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
                  child: FutureBuilder<Lead>(
                    future: _leadFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final lead = snapshot.data!;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            _IconAction(
                              assetPng: 'assets/icons/phone-call.png',
                              tooltip: 'Call',
                              onTap: () async {
                                await Helpers.placeCall(lead.phone);
                                await Future<void>.delayed(
                                  const Duration(seconds: 2),
                                );
                                final String? url =
                                    await Helpers.uploadLastRecordingToSupabase();

                                // Log call activity with recording URL if available
                                try {
                                  final currentUser = supabase
                                      .Supabase
                                      .instance
                                      .client
                                      .auth
                                      .currentUser;
                                  final String userId =
                                      currentUser?.id ?? 'system';
                                  final String userName =
                                      (currentUser?.userMetadata?['name']
                                          as String?) ??
                                      'System User';

                                  await masters
                                      .DatabaseServiceMasters.logCallInitiated(
                                    leadId: lead.id,
                                    phoneNumber: lead.phone,
                                    performedBy: userId,
                                    performedByName: userName,
                                    recordingUrl: url,
                                  );
                                } catch (e) {
                                  print(
                                    'Warning: Failed to log call activity: $e',
                                  );
                                }

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
                                  initial: lead.phone,
                                );
                                if (number != null &&
                                    number.trim().isNotEmpty) {
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
                              onTap: () => _launchEmail(lead.email, lead.id),
                            ),
                            _IconAction(
                              assetPng: 'assets/icons/conversation.png',
                              tooltip: 'SMS',
                              onTap: () => _launchSms(lead.phone, lead.id),
                            ),
                            _IconAction(
                              assetPng: 'assets/icons/whatsapp.png',
                              tooltip: 'WhatsApp',
                              onTap: () => _launchWhatsApp(lead.phone, lead.id),
                            ),
                            _IconAction(
                              assetPng: 'assets/icons/whatsapp.png',
                              tooltip: 'Offline WA',
                              onTap: () =>
                                  _launchWhatsAppWeb(lead.phone, lead.id),
                            ),
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return const Center(
                          child: Text('Error loading lead data'),
                        );
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
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
        body: FutureBuilder<Lead>(
          future: _leadFuture,
          builder: (BuildContext context, AsyncSnapshot<Lead> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Failed to load lead: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final Lead lead = snapshot.data!;
            return TabBarView(
              children: <Widget>[
                // Lead Detail tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _SectionCard(
                        title: '',
                        children: <Widget>[_ContactCompact(lead: lead)],
                      ),
                      const SizedBox(height: 12),
                      _LazyCollapsibleCard(
                        title: 'Preferred Project & Location',
                        childBuilder: () =>
                            _LazyProjectLocationCompact(leadId: lead.id),
                      ),
                      const SizedBox(height: 12),

                      _CollapsibleCard(
                        title: 'Personal Information',
                        action: IconButton(
                          onPressed: () =>
                              _showEditPersonalInfoDialog(context, lead),
                          icon: const Icon(Icons.edit, size: 20),
                          tooltip: 'Edit Personal Information',
                        ),
                        child: _PersonalInfoCard(lead: lead),
                      ),
                      const SizedBox(height: 12),

                      _CollapsibleCard(
                        title: 'Timeline',
                        child: _TabbedTimelineCard(leadId: lead.id),
                      ),
                      const SizedBox(height: 12),
                      _CollapsibleCard(
                        title: 'Activity & Assignment History',
                        child: _ActivityCompact(leadId: lead.id),
                      ),
                      const SizedBox(height: 72),
                    ],
                  ),
                ),
                // Cross Sell
                _CrossSellTab(leadId: lead.id),
                // Reference
                _ReferenceTab(leadId: lead.id),
                // Site Visit
                _SiteVisitTab(leadId: lead.id),
                // Task
                _TaskTab(leadId: lead.id),
                // Question
                const _QuestionTab(),
                // Property Option
                const _PropertyOptionTab(),
                // Ticket
                _TicketTab(leadId: lead.id),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showDisposeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return _DisposeLeadDialog(leadId: widget.leadId);
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
      ],
    );
  }
}

class _CollapsibleCard extends StatefulWidget {
  const _CollapsibleCard({
    required this.title,
    required this.child,
    this.action,
  });
  final String title;
  final Widget child;
  final Widget? action;
  @override
  State<_CollapsibleCard> createState() => _CollapsibleCardState();
}

class _LazyCollapsibleCard extends StatefulWidget {
  const _LazyCollapsibleCard({required this.title, required this.childBuilder});
  final String title;
  final Widget Function() childBuilder;
  @override
  State<_LazyCollapsibleCard> createState() => _LazyCollapsibleCardState();
}

class _LazyCollapsibleCardState extends State<_LazyCollapsibleCard> {
  late bool expanded = false;
  Widget? _cachedChild;
  bool _hasLoaded = false;

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
                onTap: () {
                  setState(() {
                    expanded = !expanded;
                    if (expanded && !_hasLoaded) {
                      _cachedChild = widget.childBuilder();
                      _hasLoaded = true;
                    }
                  });
                },
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
                _cachedChild ?? const SizedBox.shrink(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DisposeLeadDialog extends StatefulWidget {
  const _DisposeLeadDialog({required this.leadId});

  final String leadId;

  @override
  State<_DisposeLeadDialog> createState() => _DisposeLeadDialogState();
}

class _DisposeLeadDialogState extends State<_DisposeLeadDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _statusId;
  String? _subStatusId;
  String _initiatedBy = 'Agent';
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  final TextEditingController _remarkCtrl = TextEditingController();

  bool get _showInitiatedBy {
    // Show initiated by radio buttons for all dispositions
    return _statusId != null && _statusId!.isNotEmpty;
  }

  bool get _showDateTime {
    // Check if we have a status ID and if it matches Follow Up or Hot UUIDs
    if (_statusId == null || _statusId!.isEmpty) return false;

    // Follow Up UUID: b50e8400-e29b-41d4-a716-446655440010
    // Hot UUID: b50e8400-e29b-41d4-a716-446655440011
    return _statusId == 'b50e8400-e29b-41d4-a716-446655440010' || // Follow Up
        _statusId == 'b50e8400-e29b-41d4-a716-446655440011'; // Hot
  }

  Future<String?> _getLeadUuidFromLeadId(String leadId) async {
    try {
      final response = await supabase.Supabase.instance.client
          .from('leads')
          .select('id')
          .eq('lead_id', leadId)
          .single();
      return response['id'] as String?;
    } catch (e) {
      print('Error fetching lead UUID: $e');
      return null;
    }
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
              FutureBuilder<List<Map<String, dynamic>>>(
                future: masters.DatabaseServiceMasters.getLeadStatuses(),
                builder:
                    (
                      BuildContext _,
                      AsyncSnapshot<List<Map<String, dynamic>>> snap,
                    ) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) return const Text('Failed to load');
                      final List<Map<String, dynamic>> items =
                          snap.data ?? <Map<String, dynamic>>[];
                      return DropdownButtonFormField<String>(
                        initialValue: _statusId,
                        isExpanded: true,
                        items: items
                            .map(
                              (Map<String, dynamic> s) =>
                                  DropdownMenuItem<String>(
                                    value: (s['id'] ?? '') as String,
                                    child: Text(
                                      _capitalize((s['name'] ?? '-') as String),
                                    ),
                                  ),
                            )
                            .toList(),
                        onChanged: (String? v) => setState(() {
                          _statusId = v;
                          _subStatusId = null;
                        }),
                        decoration: const InputDecoration(
                          labelText: 'Main Disposition',
                          hintText: 'Select main disposition',
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      );
                    },
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _statusId == null
                    ? Future<List<Map<String, dynamic>>>.value(
                        <Map<String, dynamic>>[],
                      )
                    : masters.DatabaseServiceMasters.getLeadSubStatuses(
                        _statusId!,
                      ),
                builder:
                    (
                      BuildContext _,
                      AsyncSnapshot<List<Map<String, dynamic>>> snap,
                    ) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const SizedBox.shrink();
                      }
                      if (snap.hasError) return const Text('Failed to load');
                      final List<Map<String, dynamic>> items =
                          snap.data ?? <Map<String, dynamic>>[];
                      return DropdownButtonFormField<String>(
                        initialValue: _subStatusId,
                        isExpanded: true,
                        items: items
                            .map(
                              (Map<String, dynamic> s) =>
                                  DropdownMenuItem<String>(
                                    value: (s['id'] ?? '') as String,
                                    child: Text(
                                      _capitalize((s['name'] ?? '-') as String),
                                    ),
                                  ),
                            )
                            .toList(),
                        onChanged: (String? v) =>
                            setState(() => _subStatusId = v),
                        decoration: const InputDecoration(
                          labelText: 'Sub Disposition',
                          hintText: 'Select sub disposition',
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      );
                    },
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
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Next Follow-up Date & Time ',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                                TextSpan(
                                  text: '*',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.red,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This field is required for Follow Up and Hot dispositions',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final DateTime now = DateTime.now();
                          final DateTime? d = await showDatePicker(
                            context: context,
                            firstDate: now, // Only allow future dates
                            lastDate: DateTime(now.year + 2),
                            initialDate: _date.isBefore(now) ? now : _date,
                          );
                          if (d != null) setState(() => _date = d);
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date *',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
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
                          final DateTime now = DateTime.now();
                          final TimeOfDay currentTime = TimeOfDay.fromDateTime(
                            now,
                          );
                          final TimeOfDay initialTime =
                              _date.day == now.day &&
                                  _date.month == now.month &&
                                  _date.year == now.year
                              ? TimeOfDay(
                                  hour: currentTime.hour,
                                  minute: currentTime.minute + 1,
                                ) // Set to next minute if today
                              : _time;

                          final TimeOfDay? t = await showTimePicker(
                            context: context,
                            initialTime: initialTime,
                          );
                          if (t != null) setState(() => _time = t);
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Time *',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
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

  void _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate date/time for Follow Up and Hot dispositions
    if (_showDateTime) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );

      if (selectedDateTime.isBefore(now)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Follow-up date and time must be in the future',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
        return;
      }
    }

    try {
      // Get current user info
      final currentUser = supabase.Supabase.instance.client.auth.currentUser;
      final String userId = currentUser?.id ?? 'system';
      final String userName =
          (currentUser?.userMetadata?['name'] as String?) ?? 'System User';

      // Combine date and time
      final DateTime disposedAt = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );

      // Get the lead ID from the widget parameter
      final String leadIdString = widget.leadId;

      if (leadIdString.isEmpty) {
        throw Exception('Lead ID not found');
      }

      // Convert lead_id to UUID by fetching from database
      final leadUuid = await _getLeadUuidFromLeadId(leadIdString);
      if (leadUuid == null) {
        throw Exception('Lead not found in database');
      }

      // Save disposition to database
      await masters.DatabaseServiceMasters.createDisposition(
        leadId: leadUuid,
        mainDispositionId: _statusId!,
        subDispositionId: _subStatusId!,
        disposedAt: disposedAt,
        disposedBy: _initiatedBy.toLowerCase(),
        disposedFrom: 'system',
        remarks: _remarkCtrl.text.trim().isNotEmpty
            ? _remarkCtrl.text.trim()
            : null,
        performedBy: userId,
        performedByName: userName,
      );

      // Get disposition names for logging
      final mainDispositionName = await _getDispositionName(_statusId!, true);
      final subDispositionName = await _getDispositionName(
        _subStatusId!,
        false,
      );

      // Log disposition activity
      await masters.DatabaseServiceMasters.logDispositionActivity(
        leadId: leadUuid,
        mainDispositionName: mainDispositionName,
        subDispositionName: subDispositionName,
        disposedBy: _initiatedBy.toLowerCase(),
        performedBy: userId,
        performedByName: userName,
        remarks: _remarkCtrl.text.trim().isNotEmpty
            ? _remarkCtrl.text.trim()
            : null,
      );

      // Update lead status based on disposition
      await _updateLeadStatusFromDisposition(
        leadId: leadUuid,
        mainDispositionName: mainDispositionName,
        subDispositionName: subDispositionName,
        performedBy: userId,
        performedByName: userName,
      );

      // Create follow-up task if needed
      await masters.DatabaseServiceMasters.createDispositionFollowUp(
        leadId: leadUuid,
        mainDispositionName: mainDispositionName,
        subDispositionName: subDispositionName,
        performedBy: userId,
        performedByName: userName,
        // Use current lead's assigned user for follow-up
        assignedTo:
            null, // Will be assigned to current user or lead's assigned user
        assignedToName: null,
      );

      Navigator.of(context).pop();

      // Refresh lead data to show updated follow-up date
      final parent = context.findAncestorStateOfType<_LeadDetailScreenState>();
      if (parent != null) {
        parent.refreshLead();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disposition saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save disposition: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to get disposition name by ID
  Future<String> _getDispositionName(String dispositionId, bool isMain) async {
    try {
      if (isMain) {
        final mains =
            await DatabaseServiceUsersAndDisposition.getTicketDispositionMains();
        final main = mains.firstWhere((m) => m['id'] == dispositionId);
        return main['name'] as String;
      } else {
        final subs =
            await DatabaseServiceUsersAndDisposition.getTicketDispositionSubs(
              dispositionId,
            );
        final sub = subs.firstWhere((s) => s['id'] == dispositionId);
        return sub['name'] as String;
      }
    } catch (e) {
      return 'Unknown Disposition';
    }
  }

  // Helper method to update lead status based on disposition
  Future<void> _updateLeadStatusFromDisposition({
    required String leadId,
    required String mainDispositionName,
    required String subDispositionName,
    required String performedBy,
    required String performedByName,
  }) async {
    try {
      // Determine new lead status based on disposition
      String newStatus = _determineLeadStatusFromDisposition(
        mainDispositionName,
        subDispositionName,
      );
      String newSubStatus = _determineLeadSubStatusFromDisposition(
        mainDispositionName,
        subDispositionName,
      );

      // Prepare update data
      Map<String, dynamic> updateData = {
        'status': newStatus,
        'sub_status': newSubStatus,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Update follow-up date for Follow Up and Hot dispositions
      if (_showDateTime) {
        final followUpDateTime = DateTime(
          _date.year,
          _date.month,
          _date.day,
          _time.hour,
          _time.minute,
        );
        updateData['last_follow_up_date'] = followUpDateTime.toIso8601String();
        updateData['next_follow_up_date'] = followUpDateTime.toIso8601String();
      }

      // Update lead status and follow-up date
      await DatabaseService.patchLead(leadId, updateData);

      // Log status change activity
      await masters.DatabaseServiceMasters.logLeadStatusChange(
        leadId: leadId,
        oldStatus: 'Previous Status',
        newStatus: '$newStatus - $newSubStatus',
        performedBy: performedBy,
        performedByName: performedByName,
      );
    } catch (e) {
      // Don't fail the entire disposition if status update fails
      print('Warning: Failed to update lead status: $e');
    }
  }

  // Helper method to determine lead status from disposition
  String _determineLeadStatusFromDisposition(
    String mainDisposition,
    String subDisposition,
  ) {
    final lowerMain = mainDisposition.toLowerCase();
    final lowerSub = subDisposition.toLowerCase();

    // Hot dispositions
    if (lowerMain.contains('hot') ||
        lowerSub.contains('urgent') ||
        lowerMain.contains('interested') ||
        lowerSub.contains('interested')) {
      return 'hot';
    }

    // Warm dispositions
    if (lowerMain.contains('warm') ||
        lowerSub.contains('considering') ||
        lowerMain.contains('negotiation') ||
        lowerSub.contains('negotiation')) {
      return 'warm';
    }

    // Cold dispositions
    if (lowerMain.contains('cold') ||
        lowerSub.contains('not_interested') ||
        lowerMain.contains('rejected') ||
        lowerSub.contains('rejected')) {
      return 'cold';
    }

    // Default to warm for other dispositions
    return 'warm';
  }

  // Helper method to determine lead sub-status from disposition
  String _determineLeadSubStatusFromDisposition(
    String mainDisposition,
    String subDisposition,
  ) {
    final lowerMain = mainDisposition.toLowerCase();
    final lowerSub = subDisposition.toLowerCase();

    // Closed dispositions
    if (lowerMain.contains('closed') ||
        lowerSub.contains('closed') ||
        lowerMain.contains('converted') ||
        lowerSub.contains('converted') ||
        lowerMain.contains('booked') ||
        lowerSub.contains('booked')) {
      return 'closed';
    }

    // In progress dispositions
    if (lowerMain.contains('follow') ||
        lowerSub.contains('follow') ||
        lowerMain.contains('negotiation') ||
        lowerSub.contains('negotiation') ||
        lowerMain.contains('pending') ||
        lowerSub.contains('pending')) {
      return 'inProgress';
    }

    // Default to new lead for other dispositions
    return 'newLead';
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
  final TextEditingController _descCtrl = TextEditingController();
  String? _selectedUserId;
  String _selectedUserName = '';

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
              FutureBuilder<List<Map<String, dynamic>>>(
                future: DatabaseServiceUsersAndDisposition.getAssignableUsers(),
                builder:
                    (
                      BuildContext _,
                      AsyncSnapshot<List<Map<String, dynamic>>> snap,
                    ) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) return const Text('Failed to load');
                      final List<Map<String, dynamic>> users =
                          snap.data ?? <Map<String, dynamic>>[];
                      return DropdownButtonFormField<String>(
                        initialValue: _selectedUserId,
                        isExpanded: true,
                        items: users
                            .map(
                              (Map<String, dynamic> u) =>
                                  DropdownMenuItem<String>(
                                    value: (u['id'] ?? '') as String,
                                    child: Text((u['name'] ?? '-') as String),
                                  ),
                            )
                            .toList(),
                        onChanged: (String? v) => setState(() {
                          _selectedUserId = v;
                          final Map<String, dynamic> sel = users.firstWhere(
                            (Map<String, dynamic> e) => e['id'] == v,
                            orElse: () => <String, dynamic>{},
                          );
                          _selectedUserName = (sel['name'] ?? '-') as String;
                        }),
                        decoration: const InputDecoration(
                          labelText: 'Assign to',
                          border: OutlineInputBorder(),
                        ),
                        validator: (String? v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      );
                    },
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
    // Find active lead id from ancestor
    final _LeadDetailScreenState? parent = context
        .findAncestorStateOfType<_LeadDetailScreenState>();
    if (parent != null && _selectedUserId != null) {
      parent._leadFuture.then((Lead lead) async {
        try {
          // Get current lead data to log old assignee
          final Lead currentLead = await parent._leadFuture;
          await DatabaseService.updateLeadAssignment(
            leadId: lead.id,
            assignedToId: _selectedUserId!,
            assignedToName: _selectedUserName,
          );

          // Log the assignment change
          await masters.DatabaseServiceMasters.logLeadAssignment(
            leadId: lead.id,
            oldAssignee: currentLead.assignedToName,
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
      });
    }
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
                    if (widget.action != null) ...[
                      widget.action!,
                      const SizedBox(width: 8),
                    ],
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
      ],
    );
  }
}

class _CrossSellTab extends StatefulWidget {
  const _CrossSellTab({required this.leadId});
  final String leadId;
  @override
  State<_CrossSellTab> createState() => _CrossSellTabState();
}

class _CrossSellTabState extends State<_CrossSellTab> {
  late Future<List<Map<String, dynamic>>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = DatabaseService.getLeadCrossSells(leadId: widget.leadId);
  }

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
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _itemsFuture,
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Failed to load cross sells'),
                      );
                    }
                    final items = snapshot.data ?? <Map<String, dynamic>>[];
                    if (items.isEmpty) {
                      return const Center(child: Text('No cross sells yet'));
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> it = items[index];
                        return _crossSellCard(context, it);
                      },
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }

  Widget _crossSellCard(BuildContext context, Map<String, dynamic> it) {
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
                  (it['project_name'] ?? it['project'] ?? '-') as String,
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
                  (it['category'] ?? '-') as String,
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
              Text(
                (it['property_type'] ?? it['propertyType'] ?? '-') as String,
              ),
              const SizedBox(width: 12),
              const Icon(Icons.person_outline, size: 14),
              const SizedBox(width: 6),
              Text(
                'Assigned: ${(it['assigned_to_name'] ?? it['assignedTo'] ?? '-') as String}',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            (it['description'] ?? '-') as String,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _openAddSheet() {
    String category = '';
    String propertyType = '';
    String project = '';
    String? projectId;
    String allocatedTo = '';
    String? allocatedToId;
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
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future:
                        masters.DatabaseServiceMasters.getPropertyCategories(),
                    builder:
                        (
                          BuildContext _,
                          AsyncSnapshot<List<Map<String, dynamic>>> snap,
                        ) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snap.hasError) {
                            return const Text('Failed to load categories');
                          }
                          final List<Map<String, dynamic>> cats =
                              snap.data ?? <Map<String, dynamic>>[];
                          return DropdownButtonFormField<String>(
                            initialValue: category.isEmpty ? null : category,
                            items: cats
                                .map(
                                  (Map<String, dynamic> c) =>
                                      DropdownMenuItem<String>(
                                        value: (c['name'] ?? '-') as String,
                                        child: Text(
                                          (c['name'] ?? '-') as String,
                                        ),
                                      ),
                                )
                                .toList(),
                            onChanged: (String? v) =>
                                setModal(() => category = v ?? category),
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: masters.DatabaseServiceMasters.getPropertyTypes(),
                    builder:
                        (
                          BuildContext _,
                          AsyncSnapshot<List<Map<String, dynamic>>> snap,
                        ) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snap.hasError) {
                            return const Text('Failed to load property types');
                          }
                          final List<Map<String, dynamic>> types =
                              snap.data ?? <Map<String, dynamic>>[];
                          return DropdownButtonFormField<String>(
                            initialValue: propertyType.isEmpty
                                ? null
                                : propertyType,
                            items: types
                                .map(
                                  (Map<String, dynamic> t) =>
                                      DropdownMenuItem<String>(
                                        value: (t['name'] ?? '-') as String,
                                        child: Text(
                                          (t['name'] ?? '-') as String,
                                        ),
                                      ),
                                )
                                .toList(),
                            onChanged: (String? v) => setModal(
                              () => propertyType = v ?? propertyType,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Property Type',
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Project>>(
                    future: DatabaseService.getProjects(limit: 200),
                    builder:
                        (BuildContext _, AsyncSnapshot<List<Project>> snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snap.hasError) {
                            return const Text('Failed to load projects');
                          }
                          final List<Project> projs = snap.data ?? <Project>[];
                          return DropdownButtonFormField<String>(
                            initialValue: projectId,
                            items: projs
                                .map(
                                  (Project p) => DropdownMenuItem<String>(
                                    value: p.id,
                                    child: Text(p.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (String? v) => setModal(() {
                              projectId = v;
                              Project? selected;
                              if (v != null) {
                                for (final Project e in projs) {
                                  if (e.id == v) {
                                    selected = e;
                                    break;
                                  }
                                }
                              }
                              project = selected?.name ?? '';
                            }),
                            decoration: const InputDecoration(
                              labelText: 'Project Name',
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future:
                        DatabaseServiceUsersAndDisposition.getAssignableUsers(),
                    builder:
                        (
                          BuildContext _,
                          AsyncSnapshot<List<Map<String, dynamic>>> snap,
                        ) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snap.hasError) {
                            return const Text('Failed to load assignees');
                          }
                          final List<Map<String, dynamic>> users =
                              snap.data ?? <Map<String, dynamic>>[];
                          return DropdownButtonFormField<String>(
                            initialValue: allocatedToId,
                            items: users
                                .map(
                                  (Map<String, dynamic> u) =>
                                      DropdownMenuItem<String>(
                                        value: (u['id'] ?? '') as String,
                                        child: Text(
                                          (u['name'] ?? '-') as String,
                                        ),
                                      ),
                                )
                                .toList(),
                            onChanged: (String? v) => setModal(() {
                              allocatedToId = v;
                              final Map<String, dynamic> user = users
                                  .firstWhere(
                                    (Map<String, dynamic> e) => e['id'] == v,
                                    orElse: () => <String, dynamic>{},
                                  );
                              allocatedTo = (user['name'] ?? '-') as String;
                            }),
                            decoration: const InputDecoration(
                              labelText: 'Assigned To',
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
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
                      onPressed: () async {
                        try {
                          // Auto-create a minimal linked lead based on context
                          final String inferredName = [
                            project.trim().isEmpty ? null : project.trim(),
                            category.trim().isEmpty ? null : category.trim(),
                            propertyType.trim().isEmpty
                                ? null
                                : propertyType.trim(),
                          ].whereType<String>().join(' ');
                          final Lead linkedLead =
                              await DatabaseService.createLeadMinimal(
                                customerName: inferredName.isEmpty
                                    ? 'Cross-sell Lead'
                                    : 'Cross-sell: $inferredName',
                                source: LeadSource.referral,
                              );

                          await DatabaseService.createLeadCrossSell(
                            leadId: widget.leadId,
                            category: category,
                            propertyType: propertyType,
                            projectId: projectId,
                            projectName: project,
                            assignedToName: allocatedTo,
                            assignedToId: allocatedToId,
                            description: descCtrl.text.trim(),
                            linkedLeadId: linkedLead.id,
                          );
                          if (!mounted) return;
                          setState(() {
                            _itemsFuture = DatabaseService.getLeadCrossSells(
                              leadId: widget.leadId,
                            );
                          });
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '✅ Cross sell created successfully! A new lead has been linked.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 4),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                        }
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
  const _ContactCompact({required this.lead});
  final Lead lead;
  @override
  Widget build(BuildContext context) {
    final DateTime requestAt = lead.createdAt;
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
                Icons.edit,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              onPressed: () => _openEditCustomer(context, lead),
            ),
            const SizedBox(width: 8),
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
            lead.customerName.isEmpty ? '-' : lead.customerName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        _LeadInfoKeyValues(lead: lead),
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

void _openEditCustomer(BuildContext context, Lead lead) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) => _EditCustomerDialog(lead: lead),
  );
}

class _EditCustomerDialog extends StatefulWidget {
  const _EditCustomerDialog({required this.lead});

  final Lead lead;

  @override
  State<_EditCustomerDialog> createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends State<_EditCustomerDialog> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _alternatePhoneController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isSaving = false;
  late final String _leadId;

  @override
  void initState() {
    super.initState();
    // Seed from the provided lead synchronously to avoid loading spinner
    _leadId = widget.lead.id;
    _populateFields(widget.lead);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _alternatePhoneController.dispose();
    super.dispose();
  }

  void _populateFields(Lead lead) {
    // Parse the customer name into parts
    final List<String> nameParts = lead.customerName.split(' ');
    _firstNameController.text = nameParts.isNotEmpty ? nameParts[0] : '';
    _lastNameController.text = nameParts.length > 1 ? nameParts.last : '';

    // Middle name is everything between first and last
    if (nameParts.length > 2) {
      _middleNameController.text = nameParts
          .sublist(1, nameParts.length - 1)
          .join(' ');
    }

    _emailController.text = lead.email;
    _phoneController.text = lead.phone;
    _alternatePhoneController.text = lead.alternatePhone ?? '';
  }

  Future<void> _saveCustomerData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Combine name parts
      final List<String> nameParts = [
        _firstNameController.text.trim(),
        _middleNameController.text.trim(),
        _lastNameController.text.trim(),
      ].where((part) => part.isNotEmpty).toList();

      final String fullName = nameParts.join(' ');

      // Update the lead on server using the more robust method
      await DatabaseService.updateLeadPersonalInfo(
        leadId: _leadId,
        name: fullName,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        alternatePhone: _alternatePhoneController.text.trim().isEmpty
            ? null
            : _alternatePhoneController.text.trim(),
      );

      // Prepare optimistic updated lead for instant UI update
      final Lead updatedLead = widget.lead.copyWith(
        customerName: fullName,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        alternatePhone: _alternatePhoneController.text.trim().isEmpty
            ? null
            : _alternatePhoneController.text.trim(),
      );

      if (mounted) {
        // Optimistically update parent UI immediately and then refresh in background
        final _LeadDetailScreenState? parent = context
            .findAncestorStateOfType<_LeadDetailScreenState>();
        if (parent != null) {
          parent.setState(() {
            parent._leadFuture = Future<Lead>.value(updatedLead);
          });
          parent.refreshLead();
        }

        // Close dialog
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer information updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update customer: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: const Text('Edit Customer Information'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          minWidth: 350,
          maxHeight: 600,
        ),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name fields
                const Text(
                  'Name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _middleNameController,
                  decoration: const InputDecoration(
                    labelText: 'Middle Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                // Contact fields
                const Text(
                  'Contact Information',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    if (value.trim().length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _alternatePhoneController,
                  decoration: const InputDecoration(
                    labelText: 'Alternate Phone',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_android),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _saveCustomerData,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Save Changes'),
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
        Text('Assigned To:$allocatedTo'),
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
  const _LeadInfoKeyValues({required this.lead});
  final Lead lead;
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
        kv('E-Mail', vText(lead.email.isEmpty ? '-' : lead.email, link: true)),
        const Divider(height: 1),
        kv('Alternate Number', vText(lead.alternatePhone ?? '-')),
        const Divider(height: 1),
        kv('Project Name', vText(lead.projectName ?? '-', link: true)),
        const Divider(height: 1),
        kv(
          'Raw Mobile',
          vText(lead.phone.isEmpty ? '-' : lead.phone, link: true),
        ),
        const Divider(height: 1),
        kv(
          'Assigned To',
          vText(
            lead.assignedToName.isEmpty ? '-' : lead.assignedToName,
            link: true,
          ),
        ),
        const Divider(height: 1),
        kv('Status', vText(lead.status.toString().split('.').last)),
        const Divider(height: 1),
        kv(
          'Follow-Up At',
          vText(
            lead.nextFollowUpDate == null
                ? '-'
                : lead.nextFollowUpDate!.toLocal().toString(),
          ),
        ),
        const Divider(height: 1),
        kv('Purchase Plan', vText(lead.budgetRange ?? '-')),
        const Divider(height: 1),
        kv('State', vText(lead.state ?? '-')),
        const Divider(height: 1),
        kv('City', vText(lead.city ?? '-')),
        const Divider(height: 1),
        kv(
          'Category',
          vText(lead.categoryType.toString().split('.').last, link: true),
        ),
        const Divider(height: 1),
        kv(
          'Property Type',
          vText(lead.propertyType.toString().split('.').last, link: true),
        ),
        const Divider(height: 1),
        kv('Occupation', vText('-')),
        const Divider(height: 1),
        kv('Customer Location', vText(lead.address ?? '-')),
      ],
    );
  }
}

class _ProjectLocationCompact extends StatelessWidget {
  const _ProjectLocationCompact({required this.lead});
  final Lead lead;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Project Information
        if (lead.projectName != null && lead.projectName!.isNotEmpty) ...[
          _LabelValueText(
            label: 'Preferred Project: ',
            value: lead.projectName!,
          ),
          const SizedBox(height: 8),
        ],

        // Location Information
        if (lead.state != null && lead.state!.isNotEmpty) ...[
          _LabelValueText(label: 'State: ', value: lead.state!),
          const SizedBox(height: 4),
        ],
        if (lead.city != null && lead.city!.isNotEmpty) ...[
          _LabelValueText(label: 'City: ', value: lead.city!),
          const SizedBox(height: 4),
        ],
        if (lead.location != null && lead.location!.isNotEmpty) ...[
          _LabelValueText(label: 'Location: ', value: lead.location!),
          const SizedBox(height: 4),
        ],

        // Customer Address
        if (lead.address != null && lead.address!.isNotEmpty) ...[
          _LabelValueText(label: 'Customer Address: ', value: lead.address!),
          const SizedBox(height: 4),
        ],

        // Budget Information
        if (lead.budgetRange != null && lead.budgetRange!.isNotEmpty) ...[
          _LabelValueText(label: 'Budget Range: ', value: lead.budgetRange!),
          const SizedBox(height: 4),
        ],

        // Requirements/Notes
        if (lead.requirements != null && lead.requirements!.isNotEmpty) ...[
          _LabelValueText(label: 'Requirements: ', value: lead.requirements!),
          const SizedBox(height: 4),
        ],

        // Property Type and Category
        Row(
          children: <Widget>[
            Expanded(
              child: _LabelValueText(
                label: 'Property Type: ',
                value: _formatPropertyType(lead.propertyType),
              ),
            ),
            Expanded(
              child: _LabelValueText(
                label: 'Category: ',
                value: _formatCategoryType(lead.categoryType),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatPropertyType(PropertyType type) {
    switch (type) {
      case PropertyType.residential:
        return 'Residential';
      case PropertyType.commercial:
        return 'Commercial';
      case PropertyType.industrial:
        return 'Industrial';
      case PropertyType.land:
        return 'Land';
    }
  }

  String _formatCategoryType(CategoryType type) {
    switch (type) {
      case CategoryType.a:
        return 'A Category';
      case CategoryType.b:
        return 'B Category';
      case CategoryType.c:
        return 'C Category';
    }
  }
}

class _LazyProjectLocationCompact extends StatefulWidget {
  const _LazyProjectLocationCompact({required this.leadId});
  final String leadId;

  @override
  State<_LazyProjectLocationCompact> createState() =>
      _LazyProjectLocationCompactState();
}

class _LazyProjectLocationCompactState
    extends State<_LazyProjectLocationCompact> {
  late Future<ApiResponse<Lead>> _leadFuture;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    // Don't load data immediately
  }

  void _loadData() {
    if (!_hasLoaded) {
      setState(() {
        _leadFuture = LeadRepository().getLead(widget.leadId);
        _hasLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasLoaded) {
      return Column(
        children: [
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Load Project & Location Details'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      );
    }

    return FutureBuilder<ApiResponse<Lead>>(
      future: _leadFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text('Failed to load data: ${snapshot.error}'),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _loadData, child: const Text('Retry')),
                ],
              ),
            ),
          );
        }

        final response = snapshot.data!;
        if (!response.success || response.data == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load data: ${response.message ?? 'Unknown error'}',
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: _loadData, child: const Text('Retry')),
                ],
              ),
            ),
          );
        }

        final lead = response.data!;
        return _ProjectLocationCompact(lead: lead);
      },
    );
  }
}

class _PersonalInfoCard extends StatefulWidget {
  final Lead lead;

  const _PersonalInfoCard({required this.lead});

  @override
  State<_PersonalInfoCard> createState() => _PersonalInfoCardState();
}

class _PersonalInfoCardState extends State<_PersonalInfoCard> {
  late DateTime? dob;
  late int? age;
  late String gender;
  late String maritalStatus;
  // Employment & Professional
  late String employmentType;
  late String itrFilingStatus;
  late String occupation;
  // Address
  late String address;
  late String country;
  late String stateName;
  late String city;
  late String location;
  late String pincode;

  @override
  void initState() {
    super.initState();
    _initializeFromLead();
  }

  void _initializeFromLead() {
    // Initialize from lead data - use actual database values
    dob = widget.lead.dob;
    age = widget.lead.age;
    gender = widget.lead.gender ?? '';
    maritalStatus = widget.lead.maritalStatus ?? '';
    employmentType = widget.lead.employmentType ?? '';
    itrFilingStatus = widget.lead.itrFilingStatus ?? '';
    occupation = widget.lead.occupation ?? '';
    address = widget.lead.address ?? '';
    country = widget.lead.country ?? '';
    stateName = widget.lead.stateName ?? '';
    city = widget.lead.city ?? '';
    location = widget.lead.location ?? '';
    pincode = widget.lead.pincode ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _LabelValueText(
          label: 'DOB: ',
          value: dob == null ? '—' : '${dob!.day}/${dob!.month}/${dob!.year}',
        ),
        const SizedBox(height: 8),
        _LabelValueText(label: 'Age: ', value: age?.toString() ?? '—'),
        const SizedBox(height: 8),
        _LabelValueText(
          label: 'Gender: ',
          value: gender.isEmpty ? 'Not specified' : gender,
        ),
        const SizedBox(height: 8),
        _LabelValueText(
          label: 'Marital Status: ',
          value: maritalStatus.isEmpty ? 'Not specified' : maritalStatus,
        ),
        const SizedBox(height: 12),
        const Divider(height: 16),
        // Employment details
        _LabelValueText(
          label: 'Employment Type: ',
          value: employmentType.isEmpty ? 'Not specified' : employmentType,
        ),
        const SizedBox(height: 8),
        _LabelValueText(
          label: 'ITR Filing: ',
          value: itrFilingStatus.isEmpty ? 'Not specified' : itrFilingStatus,
        ),
        const SizedBox(height: 8),
        _LabelValueText(
          label: 'Occupation: ',
          value: occupation.isEmpty ? 'Not specified' : occupation,
        ),
        const SizedBox(height: 12),
        const Divider(height: 16),
        // Address details
        _LabelValueText(
          label: 'Address: ',
          value: address.isEmpty ? 'Not specified' : address,
        ),
        const SizedBox(height: 8),
        _LabelValueText(
          label: 'Country: ',
          value: country.isEmpty ? 'Not specified' : country,
        ),
        const SizedBox(height: 8),
        _LabelValueText(
          label: 'State: ',
          value: stateName.isEmpty ? 'Not specified' : stateName,
        ),
        const SizedBox(height: 8),
        _LabelValueText(
          label: 'City: ',
          value: city.isEmpty ? 'Not specified' : city,
        ),
        const SizedBox(height: 8),
        _LabelValueText(
          label: 'Location: ',
          value: location.isEmpty ? 'Not specified' : location,
        ),
        const SizedBox(height: 8),
        _LabelValueText(
          label: 'Pincode: ',
          value: pincode.isEmpty ? 'Not specified' : pincode,
        ),
      ],
    );
  }
}

// Edit Personal Information Dialog
void _showEditPersonalInfoDialog(BuildContext context, Lead lead) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) => _EditPersonalInfoDialog(lead: lead),
  );
}

class _EditPersonalInfoDialog extends StatefulWidget {
  final Lead lead;

  const _EditPersonalInfoDialog({required this.lead});

  @override
  State<_EditPersonalInfoDialog> createState() =>
      _EditPersonalInfoDialogState();
}

class _EditPersonalInfoDialogState extends State<_EditPersonalInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _alternatePhoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _occupationController;

  DateTime? _selectedDob;
  String _selectedGender = '';
  String _selectedMaritalStatus = '';
  String _selectedEmploymentType = '';
  String _selectedItrStatus = '';

  // Master data lists
  List<GenderMaster> _genders = [];
  List<MaritalStatusMaster> _maritalStatuses = [];
  List<EmploymentTypeMaster> _employmentTypes = [];
  List<ItrFilingStatusMaster> _itrFilingStatuses = [];

  bool _isLoadingMasterData = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadMasterData();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.lead.name);
    _emailController = TextEditingController(text: widget.lead.email);
    _phoneController = TextEditingController(text: widget.lead.phone);
    _alternatePhoneController = TextEditingController(
      text: widget.lead.alternatePhone ?? '',
    );
    _addressController = TextEditingController(text: widget.lead.address ?? '');
    _cityController = TextEditingController(text: widget.lead.city ?? '');
    _stateController = TextEditingController(text: widget.lead.stateName ?? '');
    _pincodeController = TextEditingController(text: widget.lead.pincode ?? '');
    _occupationController = TextEditingController(
      text: widget.lead.occupation ?? '',
    );

    _selectedDob = widget.lead.dob;
    _selectedGender = widget.lead.gender ?? '';
    _selectedMaritalStatus = widget.lead.maritalStatus ?? '';
    _selectedEmploymentType = widget.lead.employmentType ?? '';
    _selectedItrStatus = widget.lead.itrFilingStatus ?? '';
  }

  Future<void> _loadMasterData() async {
    try {
      final results = await Future.wait([
        MasterDataService.getGenderMaster(),
        MasterDataService.getMaritalStatusMaster(),
        MasterDataService.getEmploymentTypeMaster(),
        MasterDataService.getItrFilingStatusMaster(),
      ]);

      setState(() {
        _genders = results[0] as List<GenderMaster>;
        _maritalStatuses = results[1] as List<MaritalStatusMaster>;
        _employmentTypes = results[2] as List<EmploymentTypeMaster>;
        _itrFilingStatuses = results[3] as List<ItrFilingStatusMaster>;
        _isLoadingMasterData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMasterData = false;
      });
      print('Error loading master data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _alternatePhoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit Personal Information',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      const Text(
                        'Basic Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty == true
                                ? 'Name is required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty == true
                                ? 'Email is required'
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Phone',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value?.isEmpty == true
                                ? 'Phone is required'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _alternatePhoneController,
                            decoration: const InputDecoration(
                              labelText: 'Alternate Phone',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Stack in a column for small widths to avoid Row overflow
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          InkWell(
                            onTap: _selectDateOfBirth,
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Date of Birth',
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _selectedDob == null
                                    ? 'Select Date'
                                    : '${_selectedDob!.day}/${_selectedDob!.month}/${_selectedDob!.year}',
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _isLoadingMasterData
                              ? const CircularProgressIndicator()
                              : DropdownButtonFormField<String>(
                                  initialValue: _selectedGender.isEmpty
                                      ? null
                                      : _selectedGender,
                                  decoration: const InputDecoration(
                                    labelText: 'Gender',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _genders
                                      .map(
                                        (GenderMaster gender) =>
                                            DropdownMenuItem<String>(
                                              value: gender.name,
                                              child: Text(gender.name),
                                            ),
                                      )
                                      .toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedGender = newValue ?? '';
                                    });
                                  },
                                ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _isLoadingMasterData
                          ? const CircularProgressIndicator()
                          : DropdownButtonFormField<String>(
                              initialValue: _selectedMaritalStatus.isEmpty
                                  ? null
                                  : _selectedMaritalStatus,
                              decoration: const InputDecoration(
                                labelText: 'Marital Status',
                                border: OutlineInputBorder(),
                              ),
                              items: _maritalStatuses
                                  .map(
                                    (MaritalStatusMaster status) =>
                                        DropdownMenuItem<String>(
                                          value: status.name,
                                          child: Text(status.name),
                                        ),
                                  )
                                  .toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedMaritalStatus = newValue ?? '';
                                });
                              },
                            ),

                      const SizedBox(height: 24),

                      // Professional Information
                      const Text(
                        'Professional Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _isLoadingMasterData
                              ? const CircularProgressIndicator()
                              : DropdownButtonFormField<String>(
                                  initialValue: _selectedEmploymentType.isEmpty
                                      ? null
                                      : _selectedEmploymentType,
                                  decoration: const InputDecoration(
                                    labelText: 'Employment Type',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _employmentTypes
                                      .map(
                                        (EmploymentTypeMaster type) =>
                                            DropdownMenuItem<String>(
                                              value: type.name,
                                              child: Text(type.name),
                                            ),
                                      )
                                      .toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedEmploymentType = newValue ?? '';
                                    });
                                  },
                                ),
                          const SizedBox(height: 12),
                          _isLoadingMasterData
                              ? const CircularProgressIndicator()
                              : DropdownButtonFormField<String>(
                                  initialValue: _selectedItrStatus.isEmpty
                                      ? null
                                      : _selectedItrStatus,
                                  decoration: const InputDecoration(
                                    labelText: 'ITR Filing Status',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _itrFilingStatuses
                                      .map(
                                        (ItrFilingStatusMaster status) =>
                                            DropdownMenuItem<String>(
                                              value: status.name,
                                              child: Text(status.name),
                                            ),
                                      )
                                      .toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedItrStatus = newValue ?? '';
                                    });
                                  },
                                ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _occupationController,
                        decoration: const InputDecoration(
                          labelText: 'Occupation',
                          border: OutlineInputBorder(),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Address Information
                      const Text(
                        'Address Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _stateController,
                            decoration: const InputDecoration(
                              labelText: 'State',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pincodeController,
                        decoration: const InputDecoration(
                          labelText: 'Pincode',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: _savePersonalInfo,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDob ??
          DateTime.now().subtract(const Duration(days: 25 * 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 100 * 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  Future<void> _savePersonalInfo() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Update lead information in database
      await DatabaseService.updateLeadPersonalInfo(
        leadId: widget.lead.id,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        alternatePhone: _alternatePhoneController.text,
        dob: _selectedDob,
        gender: _selectedGender,
        maritalStatus: _selectedMaritalStatus,
        employmentType: _selectedEmploymentType,
        itrFilingStatus: _selectedItrStatus,
        occupation: _occupationController.text,
        address: _addressController.text,
        city: _cityController.text,
        stateName: _stateController.text,
        pincode: _pincodeController.text,
      );

      if (mounted) {
        // Trigger immediate refresh of lead data for real-time update
        final _LeadDetailScreenState? parent = context
            .findAncestorStateOfType<_LeadDetailScreenState>();
        if (parent != null) {
          parent.refreshLead();
        }

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personal information updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating information: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

class _TimelineCompact extends StatefulWidget {
  const _TimelineCompact({required this.leadId});
  final String leadId;

  @override
  State<_TimelineCompact> createState() => _TimelineCompactState();
}

class _TimelineCompactState extends State<_TimelineCompact> {
  List<Map<String, dynamic>> _timelineItems = [];
  bool _isLoading = true;
  supabase.RealtimeChannel? _timelineChannel;

  @override
  void initState() {
    super.initState();
    _loadTimeline();
    _subscribeToTimelineUpdates();
  }

  @override
  void dispose() {
    _timelineChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadTimeline() async {
    try {
      final response = await LeadRepository().getLeadTimeline(widget.leadId);
      if (mounted) {
        setState(() {
          _timelineItems = response.data ?? <Map<String, dynamic>>[];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _subscribeToTimelineUpdates() {
    final client = supabase.Supabase.instance.client;
    _timelineChannel = client
        .channel('timeline_${widget.leadId}')
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.all,
          schema: 'public',
          table: 'lead_activities',
          filter: supabase.PostgresChangeFilter(
            type: supabase.PostgresChangeFilterType.eq,
            column: 'lead_id',
            value: widget.leadId,
          ),
          callback: (supabase.PostgresChangePayload payload) {
            _loadTimeline(); // Reload timeline when activities change
          },
        )
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.update,
          schema: 'public',
          table: 'leads',
          filter: supabase.PostgresChangeFilter(
            type: supabase.PostgresChangeFilterType.eq,
            column: 'id',
            value: widget.leadId,
          ),
          callback: (supabase.PostgresChangePayload payload) {
            _loadTimeline(); // Reload timeline when lead is updated
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_timelineItems.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No timeline events'),
      );
    }

    return _TimelineCard(items: _timelineItems);
  }
}

class _ActivityCompact extends StatefulWidget {
  const _ActivityCompact({required this.leadId});
  final String leadId;

  @override
  State<_ActivityCompact> createState() => _ActivityCompactState();
}

class _ActivityCompactState extends State<_ActivityCompact> {
  late Future<List<LeadActivity>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = masters.DatabaseServiceMasters.getLeadActivities(
      leadId: widget.leadId,
      limit: 5, // Show only recent 5 activities
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ActivityLogCard(activitiesFuture: _activitiesFuture),
        const SizedBox(height: 8),
        _EnhancedActivitySections(leadId: widget.leadId),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              // TODO: Navigate to full activity history screen
            },
            child: const Text('View full history'),
          ),
        ),
      ],
    );
  }
}

class _EnhancedActivitySections extends StatefulWidget {
  const _EnhancedActivitySections({required this.leadId});
  final String leadId;

  @override
  State<_EnhancedActivitySections> createState() =>
      _EnhancedActivitySectionsState();
}

class _EnhancedActivitySectionsState extends State<_EnhancedActivitySections> {
  late Future<List<Map<String, dynamic>>> _crossSellsFuture;
  late Future<List<Map<String, dynamic>>> _referencesFuture;
  late Future<api.ApiResponse<List<SiteVisit>>> _siteVisitsFuture;
  late Future<api.ApiResponse<List<Task>>> _tasksFuture;
  late Future<api.ApiResponse<List<Ticket>>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _crossSellsFuture = DatabaseService.getLeadCrossSells(
      leadId: widget.leadId,
    );
    _referencesFuture = DatabaseService.getLeadReferences(
      leadId: widget.leadId,
    );
    _siteVisitsFuture = SiteVisitRepository().getSiteVisitsByLead(
      widget.leadId,
    );
    _tasksFuture = TaskRepository().getTasksByLead(widget.leadId);
    _ticketsFuture = TicketRepository().getTicketsByLead(widget.leadId);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          title: 'Cross Sell',
          icon: Icons.sell,
          color: Colors.blue,
          future: _crossSellsFuture,
          onTap: () => _navigateToTab(1), // Cross Sell tab index
        ),
        const SizedBox(height: 8),
        _buildSectionCard(
          title: 'Reference',
          icon: Icons.people,
          color: Colors.green,
          future: _referencesFuture,
          onTap: () => _navigateToTab(2), // Reference tab index
        ),
        const SizedBox(height: 8),
        _buildSectionCard(
          title: 'Site Visit',
          icon: Icons.location_on,
          color: Colors.orange,
          future: _siteVisitsFuture,
          onTap: () => _navigateToTab(3), // Site Visit tab index
        ),
        const SizedBox(height: 8),
        _buildSectionCard(
          title: 'Task',
          icon: Icons.task,
          color: Colors.purple,
          future: _tasksFuture,
          onTap: () => _navigateToTab(4), // Task tab index
        ),
        const SizedBox(height: 8),
        _buildSectionCard(
          title: 'Question',
          icon: Icons.help,
          color: Colors.teal,
          future: Future.value([]), // Questions are static for now
          onTap: () => _navigateToTab(5), // Question tab index
        ),
        const SizedBox(height: 8),
        _buildSectionCard(
          title: 'Property Option',
          icon: Icons.home,
          color: Colors.indigo,
          future: Future.value([]), // Property options are static for now
          onTap: () => _navigateToTab(6), // Property Option tab index
        ),
        const SizedBox(height: 8),
        _buildSectionCard(
          title: 'Ticket',
          icon: Icons.support_agent,
          color: Colors.red,
          future: _ticketsFuture,
          onTap: () => _navigateToTab(7), // Ticket tab index
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required Future future,
    required VoidCallback onTap,
  }) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink(); // Don't show loading for individual sections
        }

        final bool hasData =
            snapshot.hasData &&
            snapshot.data != null &&
            (snapshot.data is api.ApiResponse
                ? (snapshot.data as api.ApiResponse).data != null &&
                      (snapshot.data as api.ApiResponse).data!.isNotEmpty
                : (snapshot.data as List).isNotEmpty);

        if (!hasData) {
          return const SizedBox.shrink(); // Don't show sections with no data
        }

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Tap to view details',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToTab(int tabIndex) {
    // Find the DefaultTabController and navigate to the specific tab
    final tabController = DefaultTabController.of(context);
    tabController.animateTo(tabIndex);
  }
}

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

void _launchSms(String phoneNumber, String leadId) async {
  final Uri uri = Uri(scheme: 'sms', path: phoneNumber);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);

    // Log SMS activity
    try {
      final currentUser = supabase.Supabase.instance.client.auth.currentUser;
      final String userId = currentUser?.id ?? 'system';
      final String userName =
          (currentUser?.userMetadata?['name'] as String?) ?? 'System User';

      await masters.DatabaseServiceMasters.logMessageInitiated(
        leadId: leadId,
        phoneNumber: phoneNumber,
        performedBy: userId,
        performedByName: userName,
      );
    } catch (e) {
      print('Warning: Failed to log SMS activity: $e');
    }
  }
}

void _launchEmail(String email, String leadId) async {
  final Uri uri = Uri(
    scheme: 'mailto',
    path: email,
    query: 'subject=Lead Inquiry',
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);

    // Log email activity
    try {
      final currentUser = supabase.Supabase.instance.client.auth.currentUser;
      final String userId = currentUser?.id ?? 'system';
      final String userName =
          (currentUser?.userMetadata?['name'] as String?) ?? 'System User';

      await masters.DatabaseServiceMasters.logEmailInitiated(
        leadId: leadId,
        emailAddress: email,
        performedBy: userId,
        performedByName: userName,
      );
    } catch (e) {
      print('Warning: Failed to log email activity: $e');
    }
  }
}

void _launchWhatsApp(String phoneNumber, String leadId) async {
  String clean = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  if (!clean.startsWith('91') && clean.length == 10) clean = '91$clean';
  final Uri uri = Uri.parse('https://wa.me/$clean');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);

    // Log WhatsApp activity
    try {
      final currentUser = supabase.Supabase.instance.client.auth.currentUser;
      final String userId = currentUser?.id ?? 'system';
      final String userName =
          (currentUser?.userMetadata?['name'] as String?) ?? 'System User';

      await masters.DatabaseServiceMasters.logWhatsAppInitiated(
        leadId: leadId,
        phoneNumber: phoneNumber,
        performedBy: userId,
        performedByName: userName,
        isOffline: false,
      );
    } catch (e) {
      print('Warning: Failed to log WhatsApp activity: $e');
    }
  }
}

void _launchWhatsAppWeb(String phoneNumber, String leadId) async {
  String clean = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
  if (!clean.startsWith('91') && clean.length == 10) clean = '91$clean';
  final Uri uri = Uri.parse('https://web.whatsapp.com/send?phone=$clean');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);

    // Log offline WhatsApp activity
    try {
      final currentUser = supabase.Supabase.instance.client.auth.currentUser;
      final String userId = currentUser?.id ?? 'system';
      final String userName =
          (currentUser?.userMetadata?['name'] as String?) ?? 'System User';

      await masters.DatabaseServiceMasters.logWhatsAppInitiated(
        leadId: leadId,
        phoneNumber: phoneNumber,
        performedBy: userId,
        performedByName: userName,
        isOffline: true,
      );
    } catch (e) {
      print('Warning: Failed to log offline WhatsApp activity: $e');
    }
  }
}

class _ReferenceTab extends StatefulWidget {
  const _ReferenceTab({required this.leadId});
  final String leadId;
  @override
  State<_ReferenceTab> createState() => _ReferenceTabState();
}

class _ReferenceTabState extends State<_ReferenceTab> {
  late Future<List<Map<String, dynamic>>> _refsFutureTo;
  late Future<List<Map<String, dynamic>>> _refsFutureBy;

  @override
  void initState() {
    super.initState();
    _refsFutureTo = DatabaseService.getLeadReferences(
      leadId: widget.leadId,
      direction: 'to',
    );
    _refsFutureBy = DatabaseService.getLeadReferences(
      leadId: widget.leadId,
      direction: 'by',
    );
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

  Widget _refCard(
    BuildContext context,
    Map<String, String> r,
    String nameLabel,
  ) {
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
                  nameLabel,
                  // Accept both snake_case (DB) and camelCase (UI) keys
                  '${r['first_name'] ?? r['firstName'] ?? ''} '
                          '${r['middle_name'] ?? r['middleName'] ?? ''} '
                          '${r['last_name'] ?? r['lastName'] ?? ''}'
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .trim(),
                  isLink: true,
                  onTap: () {
                    // Linked lead id can be snake_case
                    final String? leadId = r['linked_lead_id'] ?? r['leadId'];
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
                _kvSmall(
                  context,
                  'Contact',
                  (r['contact'] ?? r['phone'] ?? '').trim(),
                ),
                const SizedBox(height: 8),
                _kvSmall(context, 'Email', (r['email'] ?? '').trim()),
                const SizedBox(height: 8),
                if ((r['note'] ?? '').trim().isNotEmpty)
                  _kvSmall(context, 'Note', (r['note'] ?? '').trim()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _referredToCard(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _refsFutureTo,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
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
                child: const Center(child: Text('Failed to load')),
              );
            }
            final List<Map<String, dynamic>> items =
                snapshot.data ?? <Map<String, dynamic>>[];
            if (items.isEmpty) {
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
                child: const Center(child: Text("Didn't Refer To Anyone")),
              );
            }
            return Column(
              children: items
                  .map(
                    (Map<String, dynamic> r) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _refCard(
                        context,
                        r.map((k, v) => MapEntry(k, v?.toString() ?? '')),
                        'Referred To Name',
                      ),
                    ),
                  )
                  .toList(),
            );
          },
    );
  }

  Widget _referredByCard(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _refsFutureBy,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
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
                child: const Center(child: Text('Failed to load')),
              );
            }
            final items = snapshot.data ?? <Map<String, dynamic>>[];
            if (items.isEmpty) {
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
            return Column(
              children: items
                  .map(
                    (Map<String, dynamic> r) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _refCard(
                        context,
                        r.map((k, v) => MapEntry(k, v?.toString() ?? '')),
                        'Referred By Name',
                      ),
                    ),
                  )
                  .toList(),
            );
          },
    );
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
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required';
                    }
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
                    onPressed: () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      try {
                        // Auto-create a linked lead from the reference details
                        final String customerName = <String>[
                          fCtrl.text.trim(),
                          mCtrl.text.trim(),
                          lCtrl.text.trim(),
                        ].where((String s) => s.isNotEmpty).join(' ');
                        final Lead linkedLead =
                            await DatabaseService.createLeadMinimal(
                              customerName: customerName.isEmpty
                                  ? 'New Referral'
                                  : customerName,
                              email: eCtrl.text.trim(),
                              phone: cCtrl.text.trim(),
                              source: LeadSource.referral,
                            );

                        // Create the reference with linked_lead_id set
                        await DatabaseService.createLeadReference(
                          leadId: widget.leadId,
                          direction: 'to',
                          firstName: fCtrl.text.trim(),
                          middleName: mCtrl.text.trim().isEmpty
                              ? null
                              : mCtrl.text.trim(),
                          lastName: lCtrl.text.trim(),
                          contact: cCtrl.text.trim(),
                          email: eCtrl.text.trim(),
                          note: noteCtrl.text.trim(),
                          linkedLeadId: linkedLead.id,
                        );
                        if (!mounted) return;
                        setState(() {
                          _refsFutureTo = DatabaseService.getLeadReferences(
                            leadId: widget.leadId,
                            direction: 'to',
                          );
                        });
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.people, color: Colors.white),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '✅ Reference created successfully! A new lead has been linked.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 4),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to create: $e')),
                        );
                      }
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
}

class _SiteVisitTab extends StatefulWidget {
  const _SiteVisitTab({required this.leadId});
  final String leadId;
  @override
  State<_SiteVisitTab> createState() => _SiteVisitTabState();
}

class _SiteVisitTabState extends State<_SiteVisitTab> {
  late Future<List<SiteVisit>> _visitsFuture;

  @override
  void initState() {
    super.initState();
    _visitsFuture = DatabaseService.getSiteVisits(
      leadId: widget.leadId,
      limit: 200,
    );
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
                onPressed: _openAddVisitSheet,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Site Visit'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<SiteVisit>>(
                future: _visitsFuture,
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
                          child: Text('Failed to load site visits'),
                        );
                      }
                      final List<SiteVisit> visits =
                          snapshot.data ?? <SiteVisit>[];
                      if (visits.isEmpty) {
                        return const Center(child: Text('No site visits yet'));
                      }
                      return ListView.separated(
                        itemCount: visits.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (BuildContext context, int index) {
                          final SiteVisit v = visits[index];
                          return _visitCard(context, v);
                        },
                      );
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _visitCard(BuildContext context, SiteVisit v) {
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
                _kvSmall(context, 'Date', _formatVisitDate(v.meetingFrom)),
                const SizedBox(height: 10),
                _kvSmall(context, 'Purpose', v.purpose ?? '-'),
                const SizedBox(height: 10),
                _kvSmall(context, 'Location', v.address ?? '-'),
                const SizedBox(height: 10),
                _kvSmall(
                  context,
                  'Status',
                  v.status.toString().split('.').last,
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _kvSmall(context, 'Appointed To', v.attenderName ?? '-'),
                const SizedBox(height: 10),
                _kvSmall(
                  context,
                  'Mode',
                  v.visitMode.toString().split('.').last,
                ),
                const SizedBox(height: 10),
                _kvSmall(context, 'Address', v.address ?? '-'),
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
                                  siteVisitId: v.id,
                                  siteVisitData: v.toJson(),
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

  String _formatVisitDate(DateTime? from) {
    if (from == null) return '-';
    final int y = from.year;
    final int m = from.month;
    final int day = from.day;
    int h = from.hour;
    final int min = from.minute;
    final bool pm = h >= 12;
    h = h % 12;
    if (h == 0) h = 12;
    final String hh = h.toString().padLeft(2, '0');
    final String mm = min.toString().padLeft(2, '0');
    return '${_monthName(m)} ${day.toString().padLeft(2, '0')}, $y\n$hh:$mm ${pm ? 'PM' : 'AM'}';
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
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Customer Contact',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    onChanged: (String v) async {
                      // Auto-fetch on 10+ digits
                      final String digits = v.replaceAll(
                        RegExp(r'[^0-9+]'),
                        '',
                      );
                      if (digits.length < 10) return;

                      // Show loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Looking up customer details...'),
                          duration: Duration(seconds: 1),
                        ),
                      );

                      final Map<String, String>? info =
                          await DatabaseService.lookupByPhone(digits);
                      if (info == null) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'No customer found with phone: $digits\nCheck console for debug info',
                              ),
                              backgroundColor: Colors.orange,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                        return;
                      }
                      if (!mounted) return;

                      setModal(() {
                        nameCtrl.text = info['name'] ?? nameCtrl.text;
                        // If it's a lead match, set lead ref field with id
                        if ((info['type'] ?? '') == 'lead') {
                          leadRefCtrl.text =
                              info['lead_id'] ?? leadRefCtrl.text;
                        }
                        // Auto-fill additional details
                        if (info['assigned_to_name'] != null &&
                            info['assigned_to_name']!.isNotEmpty) {
                          attenderCtrl.text = info['assigned_to_name']!;
                        }
                        if (info['address'] != null &&
                            info['address']!.isNotEmpty) {
                          addressCtrl.text = info['address']!;
                        }
                        if (info['project_name'] != null &&
                            info['project_name']!.isNotEmpty) {
                          locationCtrl.text = info['project_name']!;
                        }
                      });

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Customer details loaded: ${info['name']}',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    onEditingComplete: () async {
                      final String digits = contactCtrl.text.replaceAll(
                        RegExp(r'[^0-9+]'),
                        '',
                      );
                      if (digits.length < 10) return;
                      final Map<String, String>? info =
                          await DatabaseService.lookupByPhone(digits);
                      if (info == null) return;
                      if (!mounted) return;
                      setModal(() {
                        nameCtrl.text = info['name'] ?? nameCtrl.text;
                        if ((info['type'] ?? '') == 'lead') {
                          leadRefCtrl.text =
                              info['lead_id'] ?? leadRefCtrl.text;
                        }
                        // Auto-fill additional details
                        if (info['assigned_to_name'] != null &&
                            info['assigned_to_name']!.isNotEmpty) {
                          attenderCtrl.text = info['assigned_to_name']!;
                        }
                        if (info['address'] != null &&
                            info['address']!.isNotEmpty) {
                          addressCtrl.text = info['address']!;
                        }
                        if (info['project_name'] != null &&
                            info['project_name']!.isNotEmpty) {
                          locationCtrl.text = info['project_name']!;
                        }
                      });
                    },
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
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: masters.DatabaseServiceMasters.getVisitModes(),
                    builder:
                        (
                          BuildContext _,
                          AsyncSnapshot<List<Map<String, dynamic>>> snap,
                        ) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snap.hasError) {
                            return const Text('Failed to load visit modes');
                          }
                          final List<Map<String, dynamic>> modes =
                              snap.data ?? <Map<String, dynamic>>[];
                          return DropdownButtonFormField<String>(
                            initialValue: mode.isEmpty ? null : mode,
                            items: modes
                                .map(
                                  (Map<String, dynamic> m) =>
                                      DropdownMenuItem<String>(
                                        value: (m['name'] ?? '-') as String,
                                        child: Text(
                                          (m['name'] ?? '-') as String,
                                        ),
                                      ),
                                )
                                .toList(),
                            onChanged: (String? v) =>
                                setModal(() => mode = v ?? mode),
                            decoration: const InputDecoration(
                              labelText: 'Meeting Mode',
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
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
                      onPressed: () async {
                        try {
                          final parentState = context
                              .findAncestorStateOfType<
                                _LeadDetailScreenState
                              >();
                          final String activeLeadId = widget.leadId;
                          // Resolve lead to fetch project linkage
                          final Lead lead = parentState == null
                              ? (await DatabaseService.getLeadById(
                                  activeLeadId,
                                ))!
                              : await parentState._leadFuture;
                          final String? projectId = lead.projectId;
                          final String? projectName = lead.projectName;
                          // Get phone number for site visit creation
                          final String phone = contactCtrl.text.trim();
                          final Map<String, String>? info =
                              await DatabaseService.lookupByPhone(phone);

                          // Check if lead has project information (required for site visit)
                          if (projectId == null || projectId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Project information is required. Please ensure the lead has a project assigned.',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          // Show info about customer lookup
                          if (info != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Found existing ${info['type']}: ${info['name']}',
                                ),
                                backgroundColor: Colors.green,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No existing customer found. A new customer will be created.',
                                ),
                                backgroundColor: Colors.blue,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                          final SiteVisit siteVisit =
                              await DatabaseService.createSiteVisit(
                                leadId: activeLeadId,
                                customerName: nameCtrl.text.trim(),
                                customerPhone: phone,
                                projectId: projectId,
                                projectName: projectName,
                                attenderName: attenderCtrl.text.trim(),
                                purpose: purposeCtrl.text.trim(),
                                address: addressCtrl.text.trim(),
                                visitMode: mode.toLowerCase() == 'office'
                                    ? VisitMode.office
                                    : VisitMode.physical,
                                status: SiteVisitStatus.scheduled,
                                meetingFrom: from,
                                meetingTo: to,
                              );

                          // Log the site visit creation activity
                          await masters
                              .DatabaseServiceMasters.logSiteVisitScheduled(
                            leadId: activeLeadId,
                            siteVisitId: siteVisit.id,
                            performedBy: Helpers.getCurrentUserId() ?? 'system',
                            performedByName: await Helpers.getCurrentUserName(),
                          );
                          if (!mounted) return;
                          setState(() {
                            _visitsFuture = DatabaseService.getSiteVisits(
                              leadId: activeLeadId,
                              limit: 200,
                            );
                          });
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.location_on, color: Colors.white),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '✅ Site visit created successfully! Visit has been scheduled.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 4),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to create visit: $e'),
                            ),
                          );
                        }
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
  const _TaskTab({required this.leadId});
  final String leadId;
  @override
  State<_TaskTab> createState() => _TaskTabState();
}

class _TaskTabState extends State<_TaskTab> {
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = DatabaseService.getTasks(leadId: widget.leadId, limit: 200);
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
                onPressed: _openCreateTaskSheet,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create Task'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Task>>(
                future: _tasksFuture,
                builder:
                    (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Failed to load tasks'),
                        );
                      }
                      final List<Task> tasks = snapshot.data ?? <Task>[];
                      if (tasks.isEmpty) {
                        return const Center(child: Text('No tasks yet'));
                      }
                      return ListView(
                        children: <Widget>[
                          ...tasks.asMap().entries.map(
                            (MapEntry<int, Task> e) => Container(
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
                                    e.value.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(e.value.description),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Assign To: ${e.value.assignedToName ?? '-'} • Priority: ${e.value.priority.displayName} • Status: ${e.value.status.displayName}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future:
                                  DatabaseServiceUsersAndDisposition.getAssignableUsers(),
                              builder:
                                  (
                                    BuildContext _,
                                    AsyncSnapshot<List<Map<String, dynamic>>>
                                    snap,
                                  ) {
                                    if (snap.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    if (snap.hasError) {
                                      return const Text(
                                        'Failed to load assignees',
                                      );
                                    }
                                    final List<Map<String, dynamic>> users =
                                        snap.data ?? <Map<String, dynamic>>[];
                                    return DropdownButtonFormField<String>(
                                      initialValue:
                                          users.any(
                                            (Map<String, dynamic> u) =>
                                                u['name'] == assignTo,
                                          )
                                          ? users.firstWhere(
                                                  (Map<String, dynamic> u) =>
                                                      u['name'] == assignTo,
                                                )['id']
                                                as String
                                          : null,
                                      items: users
                                          .map(
                                            (
                                              Map<String, dynamic> u,
                                            ) => DropdownMenuItem<String>(
                                              value: (u['id'] ?? '') as String,
                                              child: Text(
                                                (u['name'] ?? '-') as String,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (String? v) => setModal(() {
                                        final Map<String, dynamic> user = users
                                            .firstWhere(
                                              (Map<String, dynamic> e) =>
                                                  e['id'] == v,
                                              orElse: () => <String, dynamic>{},
                                            );
                                        assignTo =
                                            (user['name'] ?? '-') as String;
                                      }),
                                      decoration: const InputDecoration(
                                        labelText: 'Assign To *',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (String? v) =>
                                          (v == null || v.isEmpty)
                                          ? 'Required'
                                          : null,
                                    );
                                  },
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
                  onPressed: () async {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    try {
                      // Use the lead id passed into this tab instead of waiting on parent
                      final String activeLeadId = widget.leadId;
                      final Task createdTask = await DatabaseService.createTask(
                        leadId: activeLeadId,
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        priority: priority.toLowerCase() == 'high'
                            ? TaskPriority.high
                            : priority.toLowerCase() == 'low'
                            ? TaskPriority.low
                            : TaskPriority.medium,
                        status: TaskStatus.pending,
                        type: TaskType.other,
                        assignedToName: assignTo,
                        dueDate: DateTime(
                          endDate.year,
                          endDate.month,
                          endDate.day,
                          endTime.hour,
                          endTime.minute,
                        ),
                      );

                      // Log the task creation activity
                      await masters.DatabaseServiceMasters.logTaskCreated(
                        leadId: activeLeadId,
                        taskId: createdTask.id,
                        taskTitle: titleCtrl.text.trim(),
                        performedBy: Helpers.getCurrentUserId() ?? 'system',
                        performedByName: await Helpers.getCurrentUserName(),
                      );
                      if (!mounted) return;
                      setState(() {
                        _tasksFuture = DatabaseService.getTasks(
                          leadId: activeLeadId,
                          limit: 200,
                        );
                      });
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.task_alt, color: Colors.white),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '✅ Task created successfully! Task has been assigned.',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 4),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create task: $e')),
                      );
                    }
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
}

class _QuestionTab extends StatefulWidget {
  const _QuestionTab();
  @override
  State<_QuestionTab> createState() => _QuestionTabState();
}

class _QuestionTabState extends State<_QuestionTab> {
  final List<Map<String, String>> _items = <Map<String, String>>[];

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

  void _openAddQuestionSheet() async {
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
                  onPressed: () async {
                    final parentState = context
                        .findAncestorStateOfType<_LeadDetailScreenState>();
                    final String activeLeadId = parentState == null
                        ? ''
                        : (await parentState._leadFuture).id;
                    try {
                      await DatabaseService.createLeadQuestion(
                        leadId: activeLeadId,
                        title: titleCtrl.text.trim(),
                        notes: notesCtrl.text.trim(),
                      );
                      if (!mounted) return;
                      setState(() {
                        _items.insert(0, <String, String>{
                          'title': titleCtrl.text.trim(),
                          'notes': notesCtrl.text.trim(),
                        });
                      });
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.quiz, color: Colors.white),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '✅ Question created successfully! Question has been added.',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 4),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to create: $e')),
                      );
                    }
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
  List<Project> _projects = <Project>[];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final List<Project> res = await DatabaseService.getProjects(limit: 50);
      if (!mounted) return;
      setState(() {
        _projects = res;
      });
    } catch (_) {}
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
              child: _projects.isEmpty
                  ? const Center(child: Text('No projects found'))
                  : _buildProjectsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList() {
    final List<Project> items = _projects;
    final ScrollController scrollController = ScrollController();
    return Scrollbar(
      controller: scrollController,
      child: ListView.separated(
        controller: scrollController,
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (BuildContext context, int i) {
          final Project p = items[i];
          final String typeText =
              p.type.toString().split('.').last[0].toUpperCase() +
              p.type.toString().split('.').last.substring(1);
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

  Future<void> _openAddPropertyOptionScreen() async {
    final Map<String, String>? result = await Navigator.of(context).push(
      MaterialPageRoute<Map<String, String>>(
        builder: (BuildContext ctx) => const CreatePropertyOptionScreen(),
      ),
    );
    if (result != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.home, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '✅ Property option created successfully! Property has been added.',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

class CreatePropertyOptionScreen extends StatefulWidget {
  const CreatePropertyOptionScreen({super.key});
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
  final Set<String> _selectedProjectIds = <String>{};

  // Data lists for dropdowns
  List<OptionType> _optionTypes = <OptionType>[];
  List<Project> _projectNames = <Project>[];
  List<PropertyCategory> _categories = <PropertyCategory>[];
  List<PropertyTypeMaster> _propertyTypes = <PropertyTypeMaster>[];
  List<StateMaster> _states = <StateMaster>[];
  List<City> _cities = <City>[];
  List<Location> _locations = <Location>[];
  List<Inventory> _inventories = <Inventory>[];

  // Loading states
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load all data in parallel
      final results = await Future.wait([
        MasterDataService.getOptionTypes(),
        DatabaseService.getProjects(limit: 50),
        MasterDataService.getPropertyCategories(),
        MasterDataService.getPropertyTypesMaster(),
        MasterDataService.getStates(),
        DatabaseServiceMasters.getInventoryTypes(),
      ]);

      setState(() {
        _optionTypes = results[0] as List<OptionType>;
        _projectNames = results[1] as List<Project>;
        _categories = results[2] as List<PropertyCategory>;
        _propertyTypes = results[3] as List<PropertyTypeMaster>;
        _states = results[4] as List<StateMaster>;
        _inventories = results[5] as List<Inventory>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error - could show a snackbar or error message
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _loadCities(String stateId) async {
    try {
      final cities = await MasterDataService.getCities(stateId: stateId);
      setState(() {
        _cities = cities;
        cityValue = ''; // Reset city when state changes
        location = ''; // Reset location when state changes
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading cities: $e')));
      }
    }
  }

  Future<void> _loadLocations(String cityId) async {
    try {
      final locations = await MasterDataService.getLocations(cityId: cityId);
      setState(() {
        _locations = locations;
        location = ''; // Reset location when city changes
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading locations: $e')));
      }
    }
  }

  void _clear() {
    setState(() {
      optionType = projectName = category = propertyType = stateValue =
          cityValue = location = '';
      _descCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Property Option')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                      initialValue: optionType.isEmpty ? null : optionType,
                      items: _optionTypes
                          .map(
                            (OptionType e) => DropdownMenuItem<String>(
                              value: e.name,
                              child: Text(e.name),
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
                      isExpanded: true,
                      initialValue: projectName.isEmpty ? null : projectName,
                      items: _projectNames
                          .map(
                            (Project e) => DropdownMenuItem<String>(
                              value: e.name,
                              child: Text(
                                e.name,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                      initialValue: category.isEmpty ? null : category,
                      items: _categories
                          .map(
                            (PropertyCategory e) => DropdownMenuItem<String>(
                              value: e.name,
                              child: Text(e.name),
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
                      initialValue: propertyType.isEmpty ? null : propertyType,
                      items: _propertyTypes
                          .map(
                            (PropertyTypeMaster e) => DropdownMenuItem<String>(
                              value: e.name,
                              child: Text(e.name),
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
                                isExpanded: true,
                                initialValue: stateValue.isEmpty
                                    ? null
                                    : stateValue,
                                items: _states
                                    .map(
                                      (StateMaster e) =>
                                          DropdownMenuItem<String>(
                                            value: e.name,
                                            child: Text(
                                              e.name,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                    )
                                    .toList(),
                                onChanged: (String? v) {
                                  setState(() {
                                    stateValue = v ?? stateValue;
                                    cityValue = ''; // Reset city
                                    location = ''; // Reset location
                                    _cities.clear(); // Clear cities list
                                    _locations.clear(); // Clear locations list
                                  });
                                  if (v != null) {
                                    // Find the selected state and load its cities
                                    final selectedState = _states.firstWhere(
                                      (state) => state.name == v,
                                    );
                                    _loadCities(selectedState.id);
                                  }
                                },
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
                                isExpanded: true,
                                initialValue: cityValue.isEmpty
                                    ? null
                                    : cityValue,
                                items: _cities
                                    .map(
                                      (City e) => DropdownMenuItem<String>(
                                        value: e.name,
                                        child: Text(
                                          e.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (String? v) {
                                  setState(() {
                                    cityValue = v ?? cityValue;
                                    location = ''; // Reset location
                                    _locations.clear(); // Clear locations list
                                  });
                                  if (v != null) {
                                    // Find the selected city and load its locations
                                    final selectedCity = _cities.firstWhere(
                                      (city) => city.name == v,
                                    );
                                    _loadLocations(selectedCity.id);
                                  }
                                },
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
                      isExpanded: true,
                      initialValue: location.isEmpty ? null : location,
                      items: _locations
                          .map(
                            (Location e) => DropdownMenuItem<String>(
                              value: e.name,
                              child: Text(
                                e.name,
                                overflow: TextOverflow.ellipsis,
                              ),
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
    // Use fetched projects from database
    final List<Project> items = _projectNames;
    final ScrollController scrollController = ScrollController();

    return Scrollbar(
      controller: scrollController,
      child: ListView.separated(
        controller: scrollController,
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (BuildContext context, int i) {
          final Project p = items[i];
          final bool checked = _selectedProjectIds.contains(p.id);
          final String typeText =
              p.type.toString().split('.').last[0].toUpperCase() +
              p.type.toString().split('.').last.substring(1);
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
    if (_inventories.isEmpty) {
      return const Center(child: Text('No inventories available'));
    }

    final ScrollController scrollController = ScrollController();
    return Scrollbar(
      controller: scrollController,
      child: ListView.separated(
        controller: scrollController,
        itemCount: _inventories.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (BuildContext context, int i) {
          final Inventory inventory = _inventories[i];
          final String priceText =
              inventory.price != null && inventory.price! > 0
              ? '₹ ${inventory.price!.toStringAsFixed(0)}'.trim()
              : '-';

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(
                value: false, // You can add inventory selection logic here
                onChanged: (bool? v) {
                  // Handle inventory selection
                },
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      inventory.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Unit: ${inventory.name}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: <TextSpan>[
                          const TextSpan(
                            text: 'Price : ',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: priceText,
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
                            text: 'Status : ',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: inventory.availabilityStatus == 'available'
                                ? 'Available'
                                : 'Not Available',
                            style: TextStyle(
                              color: inventory.availabilityStatus == 'available'
                                  ? Colors.green
                                  : Colors.red,
                            ),
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
  const _TicketTab({required this.leadId});
  final String leadId;
  @override
  State<_TicketTab> createState() => _TicketTabState();
}

class _TicketTabState extends State<_TicketTab> {
  late Future<List<Ticket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = DatabaseService.getTickets(
      leadId: widget.leadId,
      limit: 200,
    );
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
              child: FutureBuilder<List<Ticket>>(
                future: _ticketsFuture,
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<List<Ticket>> snapshot,
                    ) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Failed to load tickets'),
                        );
                      }
                      final List<Ticket> items = snapshot.data ?? <Ticket>[];
                      if (items.isEmpty) {
                        return const Center(
                          child: Text('No tickets created yet'),
                        );
                      }
                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (BuildContext context, int index) {
                          final Ticket item = items[index];
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
                                        message: item.ticketNumber,
                                        child: Text(
                                          item.ticketNumber,
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
                                      label: Text(item.priority.displayName),
                                      backgroundColor: _getPriorityColor(
                                        item.priority.displayName,
                                      ),
                                      labelStyle: TextStyle(
                                        color: _getPriorityTextColor(
                                          item.priority.displayName,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Tooltip(
                                  message: item.issueTitle,
                                  child: Text(
                                    item.issueTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                if (item
                                    .issueDescription
                                    .isNotEmpty) ...<Widget>[
                                  const SizedBox(height: 6),
                                  Tooltip(
                                    message: item.issueDescription,
                                    child: Text(
                                      item.issueDescription,
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
                                      'Assigned to ${item.assignedToName ?? '-'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
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
                                      _formatRelative(
                                        item.createdAt.toIso8601String(),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.4),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.visibility_outlined,
                                        size: 18,
                                      ),
                                      label: const Text('View'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
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

  void _viewTicket(Ticket item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TicketDetailScreen(
          ticket: <String, String>{
            'id': item.ticketNumber,
            'title': item.issueTitle,
            'description': item.issueDescription,
            'createdBy': item.assignedToName ?? '-',
            'priority': item.priority.displayName,
          },
        ),
      ),
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

    // Customer data fetching
    bool isLoadingCustomer = false;
    String? customerName;
    String? customerEmail;
    String? customerAddress;

    // Lead data fetching based on mobile number
    bool isLoadingLeads = false;
    List<Lead> availableLeads = [];
    String? selectedLeadId;

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
                                    onPressed: () async {
                                      if (registeredMobileCtrl.text
                                          .trim()
                                          .isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Please enter a mobile number first',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      setModal(() {
                                        isLoadingCustomer = true;
                                        isLoadingLeads = true;
                                      });

                                      try {
                                        // Fetch both customer and leads data
                                        final customer =
                                            await DatabaseService.getCustomerByPhone(
                                              registeredMobileCtrl.text.trim(),
                                            );
                                        final leads =
                                            await DatabaseService.getLeads(
                                              search: registeredMobileCtrl.text
                                                  .trim(),
                                              limit: 50,
                                            );

                                        setModal(() {
                                          isLoadingCustomer = false;
                                          isLoadingLeads = false;

                                          if (customer != null) {
                                            customerName =
                                                customer['name'] as String?;
                                            customerEmail =
                                                customer['email'] as String?;
                                            customerAddress =
                                                customer['address'] as String?;
                                            contactNameCtrl.text =
                                                customerName ?? '';
                                          } else {
                                            customerName = null;
                                            customerEmail = null;
                                            customerAddress = null;
                                            contactNameCtrl.text = '';
                                          }

                                          availableLeads = leads;
                                          leadList =
                                              null; // Reset lead selection
                                          selectedLeadId = null;
                                        });

                                        if (customer != null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Customer found: ${customerName ?? 'Unknown'} | ${leads.length} leads found',
                                              ),
                                              backgroundColor: Colors.green,
                                            ),
                                          );
                                        } else if (leads.isNotEmpty) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'No customer found, but ${leads.length} leads found for this mobile number',
                                              ),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'No customer or leads found with this mobile number',
                                              ),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        setModal(() {
                                          isLoadingCustomer = false;
                                          isLoadingLeads = false;
                                        });
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error fetching data: $e',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: isLoadingCustomer
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text('Fetch Details'),
                                  ),
                                ),
                              ],
                            ),
                          if (!isInternal) const SizedBox(height: 16),

                          // Show fetched customer data
                          if (customerName != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                border: Border.all(
                                  color: Colors.green.shade200,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green.shade600,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Customer Found',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (customerName != null)
                                    Text('Name: $customerName'),
                                  if (customerEmail != null)
                                    Text('Email: $customerEmail'),
                                  if (customerAddress != null)
                                    Text('Address: $customerAddress'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (!isInternal && !isVendor) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdownField(
                                    'Lead List*',
                                    leadList,
                                    availableLeads
                                        .map(
                                          (lead) =>
                                              '${lead.customerName} · ${lead.phone}',
                                        )
                                        .toList(),
                                    (String? v) => setModal(() {
                                      leadList = v;
                                      if (v != null) {
                                        final selectedLead = availableLeads
                                            .firstWhere(
                                              (lead) =>
                                                  '${lead.customerName} · ${lead.phone}' ==
                                                  v,
                                            );
                                        selectedLeadId = selectedLead.id;
                                      }
                                    }),
                                    isRequired: true,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: availableLeads.isEmpty
                                        ? null
                                        : () async {
                                            setModal(() {
                                              isLoadingLeads = true;
                                            });

                                            try {
                                              final leads =
                                                  await DatabaseService.getLeads(
                                                    search: registeredMobileCtrl
                                                        .text
                                                        .trim(),
                                                    limit: 50,
                                                  );
                                              setModal(() {
                                                availableLeads = leads;
                                                leadList =
                                                    null; // Reset selection
                                                selectedLeadId = null;
                                                isLoadingLeads = false;
                                              });
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Refreshed: ${leads.length} leads found',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            } catch (e) {
                                              setModal(() {
                                                isLoadingLeads = false;
                                              });
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Error refreshing leads: $e',
                                                  ),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: isLoadingLeads
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text('Refresh'),
                                  ),
                                ),
                              ],
                            ),
                            if (availableLeads.isEmpty && !isLoadingLeads)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info,
                                      color: Colors.orange.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'No leads found. Click "Fetch Details" to search for leads with this mobile number.',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
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
                      onPressed: () async {
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

                        try {
                          // Use selected lead ID if available, otherwise fall back to current lead
                          String ticketLeadId = '';
                          if (selectedLeadId != null &&
                              selectedLeadId!.isNotEmpty) {
                            ticketLeadId = selectedLeadId!;
                          } else {
                            final parentState = context
                                .findAncestorStateOfType<
                                  _LeadDetailScreenState
                                >();
                            ticketLeadId = parentState == null
                                ? ''
                                : (await parentState._leadFuture).leadId;
                          }

                          await DatabaseService.createTicket(
                            leadId: ticketLeadId,
                            issueTitle: issueTitleCtrl.text.trim(),
                            issueDescription: issueDescriptionCtrl.text.trim(),
                            priority:
                                (priority ?? 'Low').toLowerCase() == 'high'
                                ? TicketPriority.high
                                : (priority ?? 'Low').toLowerCase() == 'medium'
                                ? TicketPriority.medium
                                : TicketPriority.low,
                            status: TicketStatus.open,
                            type:
                                (ticketType ?? 'Issue').toLowerCase() ==
                                    'request'
                                ? TicketType.request
                                : (ticketType ?? 'Issue').toLowerCase() ==
                                      'complaint'
                                ? TicketType.complaint
                                : (ticketType ?? 'Issue').toLowerCase() ==
                                      'inquiry'
                                ? TicketType.inquiry
                                : TicketType.issue,
                            serviceType: ServiceType.other,
                            assignedToName: assignTo,
                            contactName: contactNameCtrl.text.trim(),
                            contactMobile: registeredMobileCtrl.text.trim(),
                            unitNumber: unitNumberCtrl.text.trim(),
                            alternateNumber: alternateMobileCtrl.text.trim(),
                          );
                          if (!mounted) return;
                          setState(() {
                            _ticketsFuture = DatabaseService.getTickets(
                              leadId: ticketLeadId,
                              limit: 200,
                            );
                          });
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    Icons.support_agent,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '✅ Ticket created successfully! Support ticket has been submitted.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 4),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to create ticket: $e'),
                            ),
                          );
                        }
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
          initialValue: value,
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
                initialValue: repliedBy,
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
    String? selectedUserId;
    String selectedUserName = _assignedTo == '-' ? '' : _assignedTo;
    final Future<List<Map<String, dynamic>>> usersFuture =
        DatabaseServiceUsersAndDisposition.getAssignableUsers();
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
              FutureBuilder<List<Map<String, dynamic>>>(
                future: usersFuture,
                builder:
                    (
                      BuildContext _,
                      AsyncSnapshot<List<Map<String, dynamic>>> snap,
                    ) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return const Text('Failed to load users');
                      }
                      final List<Map<String, dynamic>> users =
                          snap.data ?? <Map<String, dynamic>>[];
                      if (users.isEmpty) return const Text('No active users');
                      return DropdownButtonFormField<String>(
                        initialValue: selectedUserId,
                        items: users
                            .map(
                              (Map<String, dynamic> u) =>
                                  DropdownMenuItem<String>(
                                    value: (u['id'] ?? '') as String,
                                    child: Text((u['name'] ?? '-') as String),
                                  ),
                            )
                            .toList(),
                        onChanged: (String? v) {
                          selectedUserId = v;
                          final Map<String, dynamic> user = users.firstWhere(
                            (Map<String, dynamic> e) => e['id'] == v,
                            orElse: () => <String, dynamic>{},
                          );
                          selectedUserName = (user['name'] ?? '-') as String;
                        },
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      );
                    },
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
                      _assignedTo =
                          (selectedUserName.isEmpty && selectedUserId == null)
                          ? _assignedTo
                          : selectedUserName;
                      _allocationLogs.insert(0, <String, String>{
                        'assignedBy': 'Me',
                        'assignedTo': _assignedTo,
                        'assignedAt': _nowString(),
                        'description': descCtrl.text.trim(),
                      });
                    });
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Assigned to $_assignedTo')),
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
    String? mainDispId;
    String? subDispId;
    final Future<List<Map<String, dynamic>>> mainsFuture =
        DatabaseServiceUsersAndDisposition.getTicketDispositionMains();
    Future<List<Map<String, dynamic>>> subsFuture =
        Future<List<Map<String, dynamic>>>.value(<Map<String, dynamic>>[]);
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

                  // Main Disposition from Supabase
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: mainsFuture,
                    builder:
                        (
                          BuildContext _,
                          AsyncSnapshot<List<Map<String, dynamic>>> snap,
                        ) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snap.hasError) {
                            return const Text('Failed to load dispositions');
                          }
                          final List<Map<String, dynamic>> mains =
                              snap.data ?? <Map<String, dynamic>>[];
                          return DropdownButtonFormField<String>(
                            initialValue: mainDispId,
                            items: mains
                                .map(
                                  (Map<String, dynamic> m) =>
                                      DropdownMenuItem<String>(
                                        value: (m['id'] ?? '') as String,
                                        child: Text(
                                          (m['name'] ?? '-') as String,
                                        ),
                                      ),
                                )
                                .toList(),
                            onChanged: (String? v) async {
                              setModal(() {
                                mainDispId = v;
                                subsFuture =
                                    DatabaseServiceUsersAndDisposition.getTicketDispositionSubs(
                                      v ?? '',
                                    );
                                subDispId = null;
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Main Disposition *',
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                  ),
                  const SizedBox(height: 12),

                  // Sub Disposition from Supabase (depends on main)
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: subsFuture,
                    builder:
                        (
                          BuildContext _,
                          AsyncSnapshot<List<Map<String, dynamic>>> snap,
                        ) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const SizedBox.shrink();
                          }
                          if (snap.hasError) {
                            return const Text(
                              'Failed to load sub dispositions',
                            );
                          }
                          final List<Map<String, dynamic>> subs =
                              snap.data ?? <Map<String, dynamic>>[];
                          return DropdownButtonFormField<String>(
                            initialValue: subDispId,
                            items: subs
                                .map(
                                  (Map<String, dynamic> s) =>
                                      DropdownMenuItem<String>(
                                        value: (s['id'] ?? '') as String,
                                        child: Text(
                                          (s['name'] ?? '-') as String,
                                        ),
                                      ),
                                )
                                .toList(),
                            onChanged: (String? v) {
                              setModal(() {
                                subDispId = v;
                                // Selected sub disposition stored by id
                              });
                            },
                            decoration: const InputDecoration(
                              labelText: 'Sub Disposition *',
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
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
                        if ((mainDispId == null || mainDispId!.isEmpty) ||
                            (subDispId == null || subDispId!.isEmpty)) {
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

class _TabbedTimelineCard extends StatefulWidget {
  const _TabbedTimelineCard({required this.leadId});
  final String leadId;

  @override
  State<_TabbedTimelineCard> createState() => _TabbedTimelineCardState();
}

class _TabbedTimelineCardState extends State<_TabbedTimelineCard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<Map<String, dynamic>>> _activitiesByType = {};
  bool _isLoading = true;
  supabase.RealtimeChannel? _timelineChannel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
    _loadActivities();
    _subscribeToTimelineUpdates();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _timelineChannel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    try {
      print('Loading activities for lead: ${widget.leadId}');
      final response = await LeadRepository().getLeadTimeline(widget.leadId);
      final activities = response.data ?? [];
      print('Found ${activities.length} activities');

      // If no activities exist, populate sample data
      if (activities.isEmpty) {
        print('No activities found, populating sample data...');
        try {
          // Get lead details for sample data
          final leadResponse = await LeadRepository().getLead(widget.leadId);
          if (leadResponse.success && leadResponse.data != null) {
            final lead = leadResponse.data!;
            print(
              'Lead details: ${lead.customerName}, ${lead.phone}, ${lead.email}',
            );

            await masters.DatabaseServiceMasters.ensureLeadHasActivities(
              leadId: widget.leadId,
              customerName: lead.customerName,
              phoneNumber: lead.phone,
              emailAddress: lead.email,
            );
            print('Sample data populated successfully');

            // Reload activities after populating
            final newResponse = await LeadRepository().getLeadTimeline(
              widget.leadId,
            );
            print('Reloaded activities: ${newResponse.data?.length ?? 0}');

            if (mounted) {
              setState(() {
                _activitiesByType = _categorizeActivities(
                  newResponse.data ?? [],
                );
                _isLoading = false;
              });
            }
            return;
          } else {
            print('Failed to get lead details: ${leadResponse.error}');
          }
        } catch (e) {
          print('Error populating sample data: $e');
        }
      }

      if (mounted) {
        final categorized = _categorizeActivities(activities);
        print('Categorized activities:');
        categorized.forEach((key, value) {
          print('  $key: ${value.length} activities');
        });
        setState(() {
          _activitiesByType = categorized;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading activities: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, List<Map<String, dynamic>>> _categorizeActivities(
    List<Map<String, dynamic>> activities,
  ) {
    final Map<String, List<Map<String, dynamic>>> categorized = {
      'disposition': [],
      'call': [],
      'allocation': [],
      'sms': [],
      'email': [],
      'whatsapp': [],
      'visitor': [],
      'offline': [],
    };

    for (final activity in activities) {
      // Use type field which contains the actual activity type
      final type = activity['type'] as String?;

      switch (type?.toLowerCase()) {
        case 'disposition_change':
          categorized['disposition']!.add(activity);
          break;
        case 'call_initiated':
        case 'call':
          categorized['call']!.add(activity);
          break;
        case 'assigned':
        case 'assignment':
          categorized['allocation']!.add(activity);
          break;
        case 'message_initiated':
        case 'sms':
        case 'message':
          categorized['sms']!.add(activity);
          break;
        case 'email_initiated':
        case 'email':
        case 'email_sent':
          categorized['email']!.add(activity);
          break;
        case 'whatsapp_initiated':
        case 'whatsapp':
          categorized['whatsapp']!.add(activity);
          break;
        case 'offline_whatsapp_initiated':
          categorized['offline']!.add(activity);
          break;
        case 'site_visit':
        case 'visitor':
          categorized['visitor']!.add(activity);
          break;
        default:
          // Add to a general category or skip
          break;
      }
    }

    return categorized;
  }

  void _subscribeToTimelineUpdates() {
    final client = supabase.Supabase.instance.client;
    _timelineChannel = client
        .channel('tabbed_timeline_${widget.leadId}')
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.all,
          schema: 'public',
          table: 'lead_activities',
          filter: supabase.PostgresChangeFilter(
            type: supabase.PostgresChangeFilterType.eq,
            column: 'lead_id',
            value: widget.leadId,
          ),
          callback: (supabase.PostgresChangePayload payload) {
            _loadActivities();
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Disposition Log'),
            Tab(text: 'Call Log'),
            Tab(text: 'Allocation Log'),
            Tab(text: 'SMS Log'),
            Tab(text: 'Email Log'),
            Tab(text: 'WhatsApp Log'),
            Tab(text: 'Visitor Log'),
            Tab(text: 'Offline Log'),
          ],
        ),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _DispositionLogTab(activities: _activitiesByType['disposition']!),
              _CallLogTab(activities: _activitiesByType['call']!),
              _AllocationLogTab(activities: _activitiesByType['allocation']!),
              _SmsLogTab(activities: _activitiesByType['sms']!),
              _EmailLogTab(activities: _activitiesByType['email']!),
              _WhatsAppLogTab(activities: _activitiesByType['whatsapp']!),
              _VisitorLogTab(activities: _activitiesByType['visitor']!),
              _OfflineLogTab(activities: _activitiesByType['offline']!),
            ],
          ),
        ),
        // Debug button to manually populate data
        if (_activitiesByType.values.every((list) => list.isEmpty))
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () async {
                print('Manual data population triggered');
                await _loadActivities();
              },
              child: const Text('Populate Sample Data'),
            ),
          ),
      ],
    );
  }
}

// Individual tab widgets for each log type
class _DispositionLogTab extends StatelessWidget {
  const _DispositionLogTab({required this.activities});
  final List<Map<String, dynamic>> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No disposition logs found'),
        ),
      );
    }

    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final metadata = activity['metadata'] as Map<String, dynamic>? ?? {};

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField(
                  'Disposed At',
                  _formatTimestamp(activity['created_at']),
                ),
                _buildField(
                  'Disposed By',
                  activity['performed_by_name'] ?? 'Unknown',
                ),
                _buildField(
                  'Disposed From',
                  metadata['old_values']?['sub_status'] ?? '-',
                ),
                _buildField(
                  'Disposed To',
                  metadata['new_values']?['sub_status'] ?? '-',
                ),
                _buildField('Remark', metadata['remarks'] ?? '-'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '-';
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}

class _CallLogTab extends StatelessWidget {
  const _CallLogTab({required this.activities});
  final List<Map<String, dynamic>> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No call logs found'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final metadata = activity['metadata'] as Map<String, dynamic>? ?? {};

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField('Phone', metadata['phone_number'] ?? '-'),
                _buildField('Status', 'Initiated'),
                _buildField(
                  'Call Time',
                  _formatTimestamp(activity['created_at']),
                ),
                _buildField('Duration', metadata['duration'] ?? '-'),
                _buildField(
                  'Called By',
                  activity['performed_by_name'] ?? 'Unknown',
                ),
                _buildField('Recording URL', metadata['recording_url'] ?? '-'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '-';
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}

class _AllocationLogTab extends StatelessWidget {
  const _AllocationLogTab({required this.activities});
  final List<Map<String, dynamic>> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No allocation logs found'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final metadata = activity['metadata'] as Map<String, dynamic>? ?? {};

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField(
                  'Assigned By',
                  activity['performed_by_name'] ?? 'Unknown',
                ),
                _buildField('Assigned To', metadata['assigned_to_name'] ?? '-'),
                _buildField(
                  'Assigned At',
                  _formatTimestamp(activity['created_at']),
                ),
                _buildField('Description', activity['description'] ?? '-'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '-';
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}

class _SmsLogTab extends StatelessWidget {
  const _SmsLogTab({required this.activities});
  final List<Map<String, dynamic>> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No SMS logs found'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField('Message', activity['description'] ?? '-'),
                _buildField(
                  'Send By',
                  activity['performed_by_name'] ?? 'Unknown',
                ),
                _buildField(
                  'Date/Time',
                  _formatTimestamp(activity['created_at']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '-';
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}

class _EmailLogTab extends StatelessWidget {
  const _EmailLogTab({required this.activities});
  final List<Map<String, dynamic>> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No email logs found'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final metadata = activity['metadata'] as Map<String, dynamic>? ?? {};

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField('Subject', metadata['subject'] ?? '-'),
                _buildField('Message', activity['description'] ?? '-'),
                _buildField(
                  'Sent By',
                  activity['performed_by_name'] ?? 'Unknown',
                ),
                _buildField('Date', _formatTimestamp(activity['created_at'])),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '-';
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}

class _WhatsAppLogTab extends StatelessWidget {
  const _WhatsAppLogTab({required this.activities});
  final List<Map<String, dynamic>> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No WhatsApp logs found'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField('Message', activity['description'] ?? '-'),
                _buildField(
                  'Send By',
                  activity['performed_by_name'] ?? 'Unknown',
                ),
                _buildField(
                  'Date/Time',
                  _formatTimestamp(activity['created_at']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '-';
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}

class _VisitorLogTab extends StatelessWidget {
  const _VisitorLogTab({required this.activities});
  final List<Map<String, dynamic>> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No visitor logs found'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final metadata = activity['metadata'] as Map<String, dynamic>? ?? {};

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField(
                  'Visit Time',
                  _formatTimestamp(activity['created_at']),
                ),
                _buildField('Name', metadata['visitor_name'] ?? '-'),
                _buildField('Email', metadata['visitor_email'] ?? '-'),
                _buildField('Project', metadata['project'] ?? '-'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '-';
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}

class _OfflineLogTab extends StatelessWidget {
  const _OfflineLogTab({required this.activities});
  final List<Map<String, dynamic>> activities;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No offline logs found'),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField('Message', activity['description'] ?? '-'),
                _buildField(
                  'Send By',
                  activity['performed_by_name'] ?? 'Unknown',
                ),
                _buildField(
                  'Date/Time',
                  _formatTimestamp(activity['created_at']),
                ),
                _buildField('Status', 'Offline'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '-';
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.items});
  final List<Map<String, dynamic>> items;
  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Timeline',
      children: <Widget>[
        for (final Map<String, dynamic> it in items) ...<Widget>[
          _TimelineItem(
            type: it['type'] as String?,
            activityType: it['activity_type'] as String?,
            title: it['title'] as String?,
            description: it['notes'] as String? ?? it['description'] as String?,
            timestamp:
                it['timestamp'] as String? ?? it['created_at'] as String?,
            performedBy:
                it['performed_by'] as String? ??
                it['performed_by_name'] as String?,
            metadata: it['metadata'] as Map<String, dynamic>?,
          ),
          const Divider(height: 16),
        ],
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String? type;
  final String? activityType;
  final String? title;
  final String? description;
  final String? timestamp;
  final String? performedBy;
  final Map<String, dynamic>? metadata;

  const _TimelineItem({
    this.type,
    this.activityType,
    this.title,
    this.description,
    this.timestamp,
    this.performedBy,
    this.metadata,
  });

  @override
  Widget build(BuildContext context) {
    // Use activityType if available, otherwise fall back to type
    final String? displayType = activityType ?? type;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _getIconColor(displayType).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            _getIconForType(displayType),
            size: 18,
            color: _getIconColor(displayType),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      _getDisplayTitle(displayType, title),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    _formatTimestamp(timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              if (description != null && description!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
              if (performedBy != null && performedBy!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'by $performedBy',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
              if (metadata != null && metadata!.isNotEmpty) ...<Widget>[
                const SizedBox(height: 4),
                _buildMetadata(context, metadata!),
              ],
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconForType(String? type) {
    switch (type?.toLowerCase()) {
      case 'call':
      case 'phone_call':
      case 'call_initiated':
        return Icons.phone;
      case 'email':
      case 'email_sent':
      case 'email_initiated':
        return Icons.email;
      case 'message':
      case 'sms':
      case 'message_initiated':
        return Icons.message;
      case 'whatsapp':
      case 'whatsapp_initiated':
      case 'offline_whatsapp_initiated':
        return Icons.chat;
      case 'site_visit':
      case 'site_visit_scheduled':
        return Icons.location_on;
      case 'task':
      case 'task_created':
        return Icons.task;
      case 'status_change':
      case 'status_changed':
        return Icons.swap_horiz;
      case 'assignment':
      case 'assigned':
        return Icons.person_add;
      case 'disposition_change':
        return Icons.track_changes;
      case 'note':
      case 'note_added':
        return Icons.note_add;
      case 'follow_up':
      case 'follow_up_scheduled':
        return Icons.schedule;
      case 'converted':
        return Icons.trending_up;
      case 'closed':
        return Icons.close;
      case 'created':
        return Icons.add_circle;
      case 'updated':
        return Icons.edit;
      default:
        return Icons.info;
    }
  }

  Color _getIconColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'call':
      case 'phone_call':
      case 'call_initiated':
        return Colors.green;
      case 'email':
      case 'email_sent':
      case 'email_initiated':
        return Colors.blue;
      case 'message':
      case 'sms':
      case 'message_initiated':
        return Colors.orange;
      case 'whatsapp':
      case 'whatsapp_initiated':
      case 'offline_whatsapp_initiated':
        return Colors.green;
      case 'site_visit':
      case 'site_visit_scheduled':
        return Colors.teal;
      case 'task':
      case 'task_created':
        return Colors.indigo;
      case 'status_change':
      case 'status_changed':
        return Colors.purple;
      case 'assignment':
      case 'assigned':
        return Colors.amber;
      case 'disposition_change':
        return Colors.red;
      case 'note':
      case 'note_added':
        return Colors.brown;
      case 'follow_up':
      case 'follow_up_scheduled':
        return Colors.cyan;
      case 'converted':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'created':
        return Colors.green;
      case 'updated':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getDisplayTitle(String? type, String? title) {
    if (title != null && title.isNotEmpty) {
      return title;
    }

    switch (type?.toLowerCase()) {
      case 'call':
      case 'phone_call':
      case 'call_initiated':
        return 'Call Initiated';
      case 'email':
      case 'email_sent':
      case 'email_initiated':
        return 'Email Initiated';
      case 'message':
      case 'sms':
      case 'message_initiated':
        return 'SMS Initiated';
      case 'whatsapp':
      case 'whatsapp_initiated':
        return 'WhatsApp Initiated';
      case 'offline_whatsapp_initiated':
        return 'Offline WhatsApp Initiated';
      case 'site_visit':
      case 'site_visit_scheduled':
        return 'Site Visit Scheduled';
      case 'task':
      case 'task_created':
        return 'Task Created';
      case 'status_change':
      case 'status_changed':
        return 'Status Changed';
      case 'assignment':
      case 'assigned':
        return 'Assignment Changed';
      case 'disposition_change':
        return 'Disposition Changed';
      case 'note':
      case 'note_added':
        return 'Note Added';
      case 'follow_up':
      case 'follow_up_scheduled':
        return 'Follow-up Scheduled';
      case 'converted':
        return 'Lead Converted';
      case 'closed':
        return 'Lead Closed';
      case 'created':
        return 'Lead Created';
      case 'updated':
        return 'Lead Updated';
      default:
        return type?.replaceAll('_', ' ').toUpperCase() ?? 'Activity';
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '';

    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(dateTime);

      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          if (difference.inMinutes == 0) {
            return 'Just now';
          }
          return '${difference.inMinutes}m ago';
        }
        return '${difference.inHours}h ago';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return timestamp;
    }
  }

  Widget _buildMetadata(BuildContext context, Map<String, dynamic> metadata) {
    final List<Widget> metadataWidgets = [];

    metadata.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        metadataWidgets.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 8, bottom: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${key.replaceAll('_', ' ').toUpperCase()}: $value',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }
    });

    if (metadataWidgets.isEmpty) return const SizedBox.shrink();

    return Wrap(children: metadataWidgets);
  }
}

class _ActivityLogCard extends StatelessWidget {
  const _ActivityLogCard({required this.activitiesFuture});
  final Future<List<LeadActivity>> activitiesFuture;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Activity & Assignment History',
      children: <Widget>[
        FutureBuilder<List<LeadActivity>>(
          future: activitiesFuture,
          builder:
              (
                BuildContext context,
                AsyncSnapshot<List<LeadActivity>> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Failed to load activities: ${snapshot.error}'),
                  );
                }
                final List<LeadActivity> activities =
                    snapshot.data ?? <LeadActivity>[];
                if (activities.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No activities yet'),
                  );
                }
                return Column(
                  children: activities
                      .map(
                        (LeadActivity activity) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: _getActivityIcon(activity.type),
                          title: Text(activity.action),
                          subtitle: Text(
                            '${activity.performedByName} • ${_formatActivityDate(activity.createdAt)}',
                          ),
                          trailing: _getActivityStatusIcon(activity.type),
                        ),
                      )
                      .toList(),
                );
              },
        ),
      ],
    );
  }

  Widget _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.created:
        return const Icon(Icons.add_circle, color: Colors.green);
      case ActivityType.updated:
        return const Icon(Icons.edit, color: Colors.blue);
      case ActivityType.assigned:
        return const Icon(Icons.person_add, color: Colors.orange);
      case ActivityType.statusChanged:
        return const Icon(Icons.swap_horiz, color: Colors.purple);
      case ActivityType.dispositionChange:
        return const Icon(Icons.category, color: Colors.deepPurple);
      case ActivityType.siteVisit:
        return const Icon(Icons.location_on, color: Colors.teal);
      case ActivityType.siteVisitScheduled:
        return const Icon(Icons.calendar_today, color: Colors.teal);
      case ActivityType.siteVisitCompleted:
        return const Icon(Icons.check_circle, color: Colors.green);
      case ActivityType.taskCreated:
        return const Icon(Icons.task, color: Colors.indigo);
      case ActivityType.taskCompleted:
        return const Icon(Icons.task_alt, color: Colors.green);
      case ActivityType.noteAdded:
        return const Icon(Icons.note_add, color: Colors.amber);
      case ActivityType.followUpScheduled:
        return const Icon(Icons.schedule, color: Colors.cyan);
      case ActivityType.converted:
        return const Icon(Icons.trending_up, color: Colors.green);
      case ActivityType.closed:
        return const Icon(Icons.close, color: Colors.red);
      case ActivityType.callInitiated:
        return const Icon(Icons.call, color: Colors.green);
      case ActivityType.emailInitiated:
        return const Icon(Icons.email, color: Colors.blue);
      case ActivityType.messageInitiated:
        return const Icon(Icons.message, color: Colors.orange);
      case ActivityType.whatsappInitiated:
        return const Icon(Icons.chat, color: Colors.green);
      case ActivityType.offlineWhatsappInitiated:
        return const Icon(Icons.chat_bubble_outline, color: Colors.green);
    }
  }

  Widget _getActivityStatusIcon(ActivityType type) {
    switch (type) {
      case ActivityType.created:
      case ActivityType.converted:
        return const Icon(Icons.check_circle, color: Colors.green, size: 16);
      case ActivityType.closed:
        return const Icon(Icons.cancel, color: Colors.red, size: 16);
      default:
        return const Icon(Icons.info, color: Colors.grey, size: 16);
    }
  }

  String _formatActivityDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
