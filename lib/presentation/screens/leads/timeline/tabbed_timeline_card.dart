import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../data/repositories/lead_repository.dart';
import 'tabs/timeline_tab_all.dart';
import 'tabs/timeline_tab_allocation.dart';
import 'tabs/timeline_tab_call.dart';
import 'tabs/timeline_tab_disposition.dart';
import 'tabs/timeline_tab_email.dart';
import 'tabs/timeline_tab_other.dart';
import 'tabs/timeline_tab_sms.dart';
import 'tabs/timeline_tab_whatsapp.dart';

class TabbedTimelineCard extends StatefulWidget {
  const TabbedTimelineCard({super.key, required this.leadId});
  final String leadId;

  @override
  State<TabbedTimelineCard> createState() => TabbedTimelineCardState();
}

class TabbedTimelineCardState extends State<TabbedTimelineCard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<Map<String, dynamic>>> _activitiesByType = {};
  bool _isLoading = true;
  supabase.RealtimeChannel? _timelineChannel;

  // Expose a method to programmatically select the Disposition tab
  void selectDispositionTab() {
    if (!mounted) return;
    if (_tabController.length > 1) {
      setState(() {
        _tabController.index = 1; // 0: All, 1: Disposition
      });
    }
  }

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
      final response = await LeadRepository().getLeadTimeline(widget.leadId);
      final activities = response.data ?? <Map<String, dynamic>>[];
      if (!mounted) return;
      setState(() {
        _activitiesByType = _categorizeActivities(activities);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
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
      final type = activity['type'] as String?;
      if (type == null || type.isEmpty) continue;
      switch (type.toLowerCase()) {
        case 'disposition_change':
          categorized['disposition']!.add(activity);
          break;
        case 'call_initiated':
        case 'call':
          categorized['call']!.add(activity);
          break;
        case 'allocation':
          categorized['allocation']!.add(activity);
          break;
        case 'sms':
          categorized['sms']!.add(activity);
          break;
        case 'email':
          categorized['email']!.add(activity);
          break;
        case 'whatsapp':
          categorized['whatsapp']!.add(activity);
          break;
        case 'visitor':
          categorized['visitor']!.add(activity);
          break;
        case 'offline':
          categorized['offline']!.add(activity);
          break;
        default:
          categorized['offline']!.add(activity);
          break;
      }
    }
    return categorized;
  }

  void _subscribeToTimelineUpdates() {
    final client = supabase.Supabase.instance.client;
    _timelineChannel = client.channel(
      'public:lead_activities:${widget.leadId}',
    );
    _timelineChannel!
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.insert,
          schema: 'public',
          table: 'lead_activities',
          filter: supabase.PostgresChangeFilter(
            type: supabase.PostgresChangeFilterType.eq,
            column: 'lead_id',
            value: widget.leadId,
          ),
          callback: (supabase.PostgresChangePayload _) {
            if (!mounted) return;
            _loadActivities();
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 12),
          indicatorPadding: EdgeInsets.zero,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Disposition'),
            Tab(text: 'Call'),
            Tab(text: 'Allocation'),
            Tab(text: 'SMS'),
            Tab(text: 'Email'),
            Tab(text: 'WhatsApp'),
            Tab(text: 'Other'),
          ],
        ),
        SizedBox(
          height: 300,
          child: TabBarView(
            controller: _tabController,
            children: [
              TimelineTabAll(activities: _getAllActivities()),
              TimelineTabDisposition(
                activities: _activitiesByType['disposition'] ?? const [],
              ),
              TimelineTabCall(
                activities: _activitiesByType['call'] ?? const [],
              ),
              TimelineTabAllocation(
                activities: _activitiesByType['allocation'] ?? const [],
              ),
              TimelineTabSMS(activities: _activitiesByType['sms'] ?? const []),
              TimelineTabEmail(
                activities: _activitiesByType['email'] ?? const [],
              ),
              TimelineTabWhatsApp(
                activities: _activitiesByType['whatsapp'] ?? const [],
              ),
              TimelineTabOther(
                activities: _activitiesByType['offline'] ?? const [],
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getAllActivities() {
    final allActivities = <Map<String, dynamic>>[];
    for (final entry in _activitiesByType.entries) {
      if (entry.key != 'disposition') {
        allActivities.addAll(entry.value);
      }
    }
    allActivities.sort((a, b) {
      final aTime = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(1970);
      final bTime = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(1970);
      return bTime.compareTo(aTime);
    });
    return allActivities;
  }
}
