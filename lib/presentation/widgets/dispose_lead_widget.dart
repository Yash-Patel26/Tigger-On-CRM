import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../data/services/database_service.dart';
import '../../../data/services/database_service_masters.dart' as masters;

/// Dispose Lead Button Widget
///
/// This widget provides a button that opens a dialog to dispose a lead.
/// It should be placed in the AppBar actions of the lead detail screen.
class DisposeLeadButton extends StatelessWidget {
  const DisposeLeadButton({
    super.key,
    required this.leadId,
    required this.onDisposeComplete,
    required this.onShowCreateBooking,
  });

  final String leadId;
  final VoidCallback onDisposeComplete;
  final VoidCallback onShowCreateBooking;

  void _showDisposeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return DisposeLeadDialog(
          leadId: leadId,
          onDisposeComplete: onDisposeComplete,
          onShowCreateBooking: onShowCreateBooking,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Dispose Lead',
      icon: Icon(
        FontAwesomeIcons.trashCan,
        color: Theme.of(context).colorScheme.primary,
        size: 20,
      ),
      onPressed: () => _showDisposeDialog(context),
    );
  }
}

/// Dispose Lead Dialog Widget
///
/// This dialog allows users to dispose a lead by selecting:
/// - Main disposition
/// - Sub disposition
/// - Initiated by (Agent/Customer)
/// - Date and time (for Follow Up and Hot dispositions)
/// - Remarks
///
/// It also provides functionality to create a booking when the disposition is "Customer".
class DisposeLeadDialog extends StatefulWidget {
  const DisposeLeadDialog({
    super.key,
    required this.leadId,
    required this.onDisposeComplete,
    required this.onShowCreateBooking,
  });

  final String leadId;
  final VoidCallback onDisposeComplete;
  final VoidCallback onShowCreateBooking;

  @override
  State<DisposeLeadDialog> createState() => _DisposeLeadDialogState();
}

class _DisposeLeadDialogState extends State<DisposeLeadDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _statusId;
  String? _subStatusId;
  String _initiatedBy = 'Agent';
  DateTime _date = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);
  final TextEditingController _remarkCtrl = TextEditingController();
  bool _isMainDispositionCustomer = false;

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

  bool _shouldShowCreateBookingButton() {
    // Show button when main disposition is customer and sub disposition is selected
    if (_statusId == null || _subStatusId == null) return false;

    return _isMainDispositionCustomer &&
        _subStatusId != null &&
        _subStatusId!.isNotEmpty;
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
  void dispose() {
    _remarkCtrl.dispose();
    super.dispose();
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
                        onChanged: (String? v) async {
                          setState(() {
                            _statusId = v;
                            _subStatusId = null;
                            _isMainDispositionCustomer = false;
                          });

                          // Check if the selected main disposition is "customer"
                          if (v != null && v.isNotEmpty) {
                            try {
                              final mainDispositionName =
                                  await _getDispositionName(v, true);
                              setState(() {
                                _isMainDispositionCustomer = mainDispositionName
                                    .toLowerCase()
                                    .contains('customer');
                              });
                            } catch (e) {
                              print('Error getting main disposition name: $e');
                            }
                          }
                        },
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
                            FontAwesomeIcons.clock,
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
              // Show Create Booking button when main disposition is customer and sub disposition is selected
              if (_shouldShowCreateBookingButton()) ...<Widget>[
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
                            FontAwesomeIcons.bookOpen,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ready to Create Booking',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This lead has been marked as a customer. You can now create a booking.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _onCreateBooking,
                          icon: const Icon(FontAwesomeIcons.plus),
                          label: const Text('Create Booking'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        if (!mounted) return;
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

      if (!mounted) return;

      Navigator.of(context).pop();

      // Refresh lead data to show updated follow-up date
      widget.onDisposeComplete();

      // Check if disposition is customer and show create booking button
      final lowerMain = mainDispositionName.toLowerCase();

      if (lowerMain.contains('customer')) {
        // Show create booking button with a slight delay to ensure dialog is closed
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.book_online, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Lead marked as Customer')),
                  ElevatedButton(
                    onPressed: () {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      // Use a callback to show the booking dialog
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        widget.onShowCreateBooking();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green,
                    ),
                    child: const Text('Create Booking'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 10),
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disposition saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save disposition: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onCreateBooking() {
    if (!mounted) return;
    // Close the disposition dialog first
    Navigator.of(context).pop();

    // Use a slight delay to ensure the disposition dialog is closed
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      widget.onShowCreateBooking();
    });
  }

  // Helper method to get disposition name by ID
  Future<String> _getDispositionName(String dispositionId, bool isMain) async {
    try {
      if (isMain) {
        final mains = await _getTicketDispositionMains();
        final main = mains.firstWhere((m) => m['id'] == dispositionId);
        return main['name'] as String;
      } else {
        final subs = await _getTicketDispositionSubs(dispositionId);
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
      // Get current lead data to capture old sub_status
      final currentLead = await DatabaseService.getLeadById(leadId);
      final String oldSubStatus = currentLead?.subStatus.name ?? 'Not Set';

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

      // Log status change activity with old and new values
      await masters.DatabaseServiceMasters.logLeadStatusChange(
        leadId: leadId,
        oldStatus: oldSubStatus,
        newStatus: newSubStatus,
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

  // Helper methods for disposition functionality
  Future<List<Map<String, dynamic>>> _getTicketDispositionMains() async {
    try {
      final client = supabase.Supabase.instance.client;
      final response = await client
          .from('ticket_disposition_main')
          .select('id,name,description')
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching ticket disposition mains: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getTicketDispositionSubs(
    String mainId,
  ) async {
    try {
      final client = supabase.Supabase.instance.client;
      final response = await client
          .from('ticket_disposition_sub')
          .select('id,name,description,main_id')
          .eq('main_id', mainId)
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching ticket disposition subs: $e');
      return [];
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
