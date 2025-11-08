import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../data/models/models.dart';

/// Dialog for assigning tickets to users.
/// This is ticket-specific and uses ticket_allocations table for logging.

class AssignTicketDialog extends StatelessWidget {
  const AssignTicketDialog({
    super.key,
    required this.ticket,
    required this.onAssigned,
  });

  final Ticket ticket;
  final VoidCallback onAssigned;

  static Future<void> show({
    required BuildContext context,
    required Ticket ticket,
    required VoidCallback onAssigned,
  }) async {
    await showDialog(
      context: context,
      builder: (context) =>
          AssignTicketDialog(ticket: ticket, onAssigned: onAssigned),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _AssignTicketDialogContent(ticket: ticket, onAssigned: onAssigned);
  }
}

class _AssignTicketDialogContent extends StatefulWidget {
  const _AssignTicketDialogContent({
    required this.ticket,
    required this.onAssigned,
  });

  final Ticket ticket;
  final VoidCallback onAssigned;

  @override
  State<_AssignTicketDialogContent> createState() =>
      _AssignTicketDialogContentState();
}

class _AssignTicketDialogContentState
    extends State<_AssignTicketDialogContent> {
  String? selectedUserId;
  String? selectedUserName;
  final TextEditingController notesController = TextEditingController();
  List<Map<String, dynamic>> users = [];
  bool isLoadingUsers = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final client = supabase.Supabase.instance.client;
      final response = await client
          .from('users')
          .select('id,name,email,role,is_active')
          .eq('is_active', true)
          .order('name', ascending: true);
      if (mounted) {
        setState(() {
          users = List<Map<String, dynamic>>.from(response);
          isLoadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingUsers = false;
        });
      }
    }
  }

  Future<void> _handleAssign() async {
    if (selectedUserId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a user to assign')),
      );
      return;
    }

    try {
      final client = supabase.Supabase.instance.client;
      final currentUser = client.auth.currentUser;
      final userId = currentUser?.id ?? 'system';
      final userName =
          (currentUser?.userMetadata?['name'] as String?) ?? 'System User';

      // Update ticket assignment
      await client
          .from('tickets')
          .update({
            'assigned_to': selectedUserId,
            'assigned_to_name': selectedUserName,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', widget.ticket.id);

      // Create allocation log
      await client.from('ticket_allocations').insert({
        'ticket_id': widget.ticket.id,
        'assigned_to': selectedUserId,
        'assigned_to_name': selectedUserName,
        'assigned_by': userId,
        'assigned_by_name': userName,
        'notes': notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      });

      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onAssigned();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket assigned successfully')),
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
      title: const Text('Assign Ticket'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoadingUsers)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<String>(
                value: selectedUserId,
                decoration: const InputDecoration(
                  labelText: 'Assign To *',
                  border: OutlineInputBorder(),
                ),
                items: users
                    .map(
                      (u) => DropdownMenuItem<String>(
                        value: u['id'] as String,
                        child: Text(u['name'] as String),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedUserId = value;
                    if (value != null) {
                      final user = users.firstWhere((u) => u['id'] == value);
                      selectedUserName = user['name'] as String;
                    }
                  });
                },
              ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes',
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
        FilledButton(onPressed: _handleAssign, child: const Text('Assign')),
      ],
    );
  }
}
