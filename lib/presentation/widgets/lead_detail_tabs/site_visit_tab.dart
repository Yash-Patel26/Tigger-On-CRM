import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../data/services/database_service.dart';
import '../../../../data/services/database_service_masters.dart' as masters;
import '../../../../data/models/models.dart';
import '../../../../shared/utils/helpers.dart';
import '../../../presentation/screens/projects/site_visit_detail_screen.dart';

class SiteVisitTab extends StatefulWidget {
  const SiteVisitTab({super.key, required this.leadId});

  final String leadId;

  @override
  State<SiteVisitTab> createState() => _SiteVisitTabState();
}

class _SiteVisitTabState extends State<SiteVisitTab> {
  late Future<List<SiteVisit>> _visitsFuture;

  @override
  void initState() {
    super.initState();
    _loadSiteVisits();
  }

  void _loadSiteVisits() {
    setState(() {
      _visitsFuture = DatabaseService.getSiteVisits(
        leadId: widget.leadId,
        limit: 200,
      );
    });
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
                icon: const Icon(FontAwesomeIcons.plus),
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
                          FontAwesomeIcons.eye,
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
                        icon: const Icon(FontAwesomeIcons.xmark),
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
                      prefixIcon: Icon(FontAwesomeIcons.phone),
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
                          // Get lead data to fetch project linkage
                          final Lead? lead = await DatabaseService.getLeadById(
                            widget.leadId,
                          );
                          if (lead == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Lead not found'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

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
                                leadId: widget.leadId,
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
                            leadId: widget.leadId,
                            siteVisitId: siteVisit.id,
                            performedBy: Helpers.getCurrentUserId() ?? 'system',
                            performedByName: await Helpers.getCurrentUserName(),
                          );
                          if (!mounted) return;
                          _loadSiteVisits();
                          Navigator.of(ctx).pop();
                          await Helpers.showSuccessDialog(
                            context,
                            title: 'Site visit created successfully',
                            message: 'Visit has been scheduled.',
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
                      icon: const Icon(FontAwesomeIcons.check),
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

  Widget _dateTimePicker(
    BuildContext context,
    String label,
    DateTime initial,
    Function(DateTime) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: () async {
                  final DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: initial,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    onChanged(
                      DateTime(
                        date.year,
                        date.month,
                        date.day,
                        initial.hour,
                        initial.minute,
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${initial.day}/${initial.month}/${initial.year}',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(initial),
                  );
                  if (time != null) {
                    onChanged(
                      DateTime(
                        initial.year,
                        initial.month,
                        initial.day,
                        time.hour,
                        time.minute,
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${initial.hour.toString().padLeft(2, '0')}:${initial.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
