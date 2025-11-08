import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../data/models/models.dart';

/// Dialog for disposing tickets with ticket-specific dispositions.
///
/// NOTE: This uses TICKET disposition tables, NOT lead disposition tables:
/// - ticket_disposition_main (for main dispositions)
/// - ticket_disposition_sub (for sub dispositions)
/// - ticket_dispositions (for storing disposition records)
///
/// Lead dispositions use different tables: lead_status_master, lead_sub_status_master, lead_dispositions

class DisposeTicketDialog extends StatelessWidget {
  const DisposeTicketDialog({
    super.key,
    required this.ticket,
    required this.onDisposed,
  });

  final Ticket ticket;
  final VoidCallback onDisposed;

  static Future<void> show({
    required BuildContext context,
    required Ticket ticket,
    required VoidCallback onDisposed,
  }) async {
    await showDialog(
      context: context,
      builder: (context) =>
          DisposeTicketDialog(ticket: ticket, onDisposed: onDisposed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _DisposeTicketDialogContent(ticket: ticket, onDisposed: onDisposed);
  }
}

class _DisposeTicketDialogContent extends StatefulWidget {
  const _DisposeTicketDialogContent({
    required this.ticket,
    required this.onDisposed,
  });

  final Ticket ticket;
  final VoidCallback onDisposed;

  @override
  State<_DisposeTicketDialogContent> createState() =>
      _DisposeTicketDialogContentState();
}

class _DisposeTicketDialogContentState
    extends State<_DisposeTicketDialogContent> {
  String? selectedMainDispositionId;
  String? selectedSubDispositionId;
  final TextEditingController remarksController = TextEditingController();
  List<Map<String, dynamic>> mainDispositions = [];
  List<Map<String, dynamic>> subDispositions = [];
  bool isLoadingMains = true;
  bool isLoadingSubs = false;

  // Follow up date and time
  DateTime followUpDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay followUpTime = TimeOfDay.now();

  // Initiated by selection
  String selectedInitiatedBy = 'Agent';

  @override
  void initState() {
    super.initState();
    _loadMainDispositions();
  }

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  /// Load ticket main dispositions from ticket_disposition_main table
  /// (NOT lead_status_master - this is for tickets only)
  Future<void> _loadMainDispositions() async {
    try {
      final client = supabase.Supabase.instance.client;
      final response = await client
          .from('ticket_disposition_main') // Ticket-specific table
          .select('*')
          .eq('is_active', true)
          .order('name');
      if (mounted) {
        setState(() {
          mainDispositions = List<Map<String, dynamic>>.from(response);
          isLoadingMains = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingMains = false;
        });
      }
    }
  }

  /// Load ticket sub dispositions from ticket_disposition_sub table
  /// (NOT lead_sub_status_master - this is for tickets only)
  Future<void> _loadSubDispositions(String mainId) async {
    setState(() {
      selectedSubDispositionId = null;
      isLoadingSubs = true;
    });

    try {
      final client = supabase.Supabase.instance.client;
      final response = await client
          .from('ticket_disposition_sub') // Ticket-specific table
          .select('*')
          .eq('is_active', true)
          .eq('main_id', mainId)
          .order('name');
      if (mounted) {
        setState(() {
          subDispositions = List<Map<String, dynamic>>.from(response);
          isLoadingSubs = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingSubs = false;
        });
      }
    }
  }

  Future<void> _handleDispose() async {
    if (selectedMainDispositionId == null || selectedSubDispositionId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select main and sub disposition')),
      );
      return;
    }

    try {
      final client = supabase.Supabase.instance.client;
      final currentUser = client.auth.currentUser;
      final userId = currentUser?.id ?? 'system';
      final userName =
          (currentUser?.userMetadata?['name'] as String?) ?? 'System User';

      // Get disposition names
      final mainDisposition =
          mainDispositions.firstWhere(
                (d) => d['id'] == selectedMainDispositionId,
              )['name']
              as String;
      final subDisposition =
          subDispositions.firstWhere(
                (d) => d['id'] == selectedSubDispositionId,
              )['name']
              as String;

      // Combine follow up date and time
      final DateTime followUpDateTime = DateTime(
        followUpDate.year,
        followUpDate.month,
        followUpDate.day,
        followUpTime.hour,
        followUpTime.minute,
      );

      // Create ticket disposition record in ticket_dispositions table
      // (NOT lead_dispositions - this is for tickets only)
      await client.from('ticket_dispositions').insert({
        'ticket_id': widget.ticket.id,
        'main_disposition_id': selectedMainDispositionId,
        'sub_disposition_id': selectedSubDispositionId,
        'main_disposition': mainDisposition,
        'sub_disposition': subDisposition,
        'disposed_at': DateTime.now().toIso8601String(),
        'disposed_by': 'agent',
        'follow_up_date': followUpDateTime.toIso8601String(),
        'initiated_by': userId,
        'initiated_by_name': selectedInitiatedBy,
        'remarks': remarksController.text.trim().isEmpty
            ? null
            : remarksController.text.trim(),
        'created_by': userId,
        'created_by_name': userName,
      });

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onDisposed();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket disposed successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dispose Ticket'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoadingMains)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<String>(
                value: selectedMainDispositionId,
                decoration: const InputDecoration(
                  labelText: 'Main Disposition *',
                  border: OutlineInputBorder(),
                ),
                items: mainDispositions
                    .map(
                      (d) => DropdownMenuItem<String>(
                        value: d['id'] as String,
                        child: Text(d['name'] as String),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedMainDispositionId = value;
                    });
                    _loadSubDispositions(value);
                  }
                },
              ),
            const SizedBox(height: 16),
            if (isLoadingSubs)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<String>(
                value: selectedSubDispositionId,
                decoration: const InputDecoration(
                  labelText: 'Sub Disposition *',
                  border: OutlineInputBorder(),
                ),
                items: subDispositions
                    .map(
                      (d) => DropdownMenuItem<String>(
                        value: d['id'] as String,
                        child: Text(d['name'] as String),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSubDispositionId = value;
                  });
                },
              ),
            const SizedBox(height: 16),
            // Follow Up Date and Time
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final DateTime now = DateTime.now();
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        firstDate: now,
                        lastDate: DateTime(now.year + 2),
                        initialDate: followUpDate.isBefore(now)
                            ? now
                            : followUpDate,
                      );
                      if (pickedDate != null) {
                        setState(() => followUpDate = pickedDate);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Follow Up Date *',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(FontAwesomeIcons.calendar),
                      ),
                      child: Text(
                        '${followUpDate.day}/${followUpDate.month}/${followUpDate.year}',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: followUpTime,
                      );
                      if (pickedTime != null) {
                        setState(() => followUpTime = pickedTime);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Follow Up Time *',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(FontAwesomeIcons.clock),
                      ),
                      child: Text(
                        '${followUpTime.hour.toString().padLeft(2, '0')}:${followUpTime.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Initiated By
            DropdownButtonFormField<String>(
              value: selectedInitiatedBy,
              decoration: const InputDecoration(
                labelText: 'Initiated By *',
                border: OutlineInputBorder(),
              ),
              items: const <String>['Agent', 'Customer']
                  .map(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedInitiatedBy = value ?? 'Agent';
                });
              },
            ),
            const SizedBox(height: 16),
            // Remarks
            TextField(
              controller: remarksController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Remarks',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _handleDispose, child: const Text('Dispose')),
      ],
    );
  }
}
