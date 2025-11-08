import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../shared/utils/helpers.dart';
import '../../../shared/managers/auth_state_manager.dart';
import '../../../data/services/database_service.dart';
import '../../../data/services/database_service_masters.dart' as masters;
import '../../../data/models/models.dart';

/// Widget for assigning a lead (only visible to admin/head users)
class LeadAssignIcon extends StatelessWidget {
  const LeadAssignIcon({super.key, required this.leadId});

  final String leadId;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateManager>(
      builder: (context, authManager, _) {
        if (authManager.isAdminOrHead) {
          return IconButton(
            onPressed: () => _showAssignDialog(context, leadId),
            icon: const Icon(
              FontAwesomeIcons.userPlus,
              size: 12,
              color: Colors.purple,
            ),
            tooltip: 'Assign',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showAssignDialog(BuildContext context, String leadId) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return _AssignLeadDialog(leadId: leadId);
      },
    );
  }
}

/// Dialog for assigning a lead to a user
class _AssignLeadDialog extends StatefulWidget {
  const _AssignLeadDialog({required this.leadId});
  final String leadId;

  @override
  State<_AssignLeadDialog> createState() => _AssignLeadDialogState();
}

class _AssignLeadDialogState extends State<_AssignLeadDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _descCtrl = TextEditingController();
  String? _selectedUserId;
  String _selectedUserName = '';

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateManager>(
      builder: (context, authManager, _) {
        if (!authManager.isAdminOrHead) {
          return AlertDialog(
            title: const Text('Access Denied'),
            content: const Text('Only admin and head users can assign leads.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        }

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
                  const Text('Assign To'),
                  const SizedBox(height: 6),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getAssignableUsers(),
                    builder:
                        (
                          BuildContext context,
                          AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
                        ) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          final String? currentUserId =
                              Helpers.getCurrentUserId();
                          // Raw list
                          List<Map<String, dynamic>> users =
                              snapshot.data ?? <Map<String, dynamic>>[];
                          // Exclude admin/head from assignees if role field present
                          users = users.where((u) {
                            final role = (u['role'] as String?)?.toLowerCase();
                            if (role == 'admin' || role == 'head') return false;
                            return true;
                          }).toList();
                          // Prevent assigning to self (especially for admin/head)
                          users = users
                              .where(
                                (u) => (u['id'] as String?) != currentUserId,
                              )
                              .toList();

                          return DropdownButtonFormField<String>(
                            initialValue: _selectedUserId,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Select user',
                            ),
                            items: users.map((Map<String, dynamic> user) {
                              final role = user['role'] as String?;
                              return DropdownMenuItem<String>(
                                value: user['id'] as String,
                                child: Text(
                                  role != null && role.isNotEmpty
                                      ? '${user['name']} (${role.toString()})'
                                      : (user['name'] as String),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                _selectedUserId = value;
                                _selectedUserName =
                                    users.firstWhere(
                                          (Map<String, dynamic> user) =>
                                              user['id'] == value,
                                        )['name']
                                        as String;
                              });
                            },
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a user';
                              }
                              // Block self-assign as an extra guard
                              if (value == Helpers.getCurrentUserId()) {
                                return 'You cannot assign a lead to yourself';
                              }
                              return null;
                            },
                          );
                        },
                  ),
                  const SizedBox(height: 12),
                  const Text('Description'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Assignment description',
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
      },
    );
  }

  void _onAssign() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop();

    if (_selectedUserId != null) {
      _assignLead();
    }
  }

  Future<void> _assignLead() async {
    try {
      // First, resolve the human-readable lead ID to UUID
      final Lead? lead = await DatabaseService.getLeadById(widget.leadId);
      if (lead == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Lead not found')));
        }
        return;
      }

      // Store old assignee for logging
      final String oldAssignee = lead.assignedToName;

      await DatabaseService.updateLeadAssignment(
        leadId: lead.id, // Use the UUID instead of human-readable ID
        assignedToId: _selectedUserId!,
        assignedToName: _selectedUserName,
      );

      // Log the assignment change for timeline/activity tracking
      await masters.DatabaseServiceMasters.logLeadAssignment(
        leadId: lead.id,
        oldAssignee: oldAssignee,
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
  }

  // Helper method for getting assignable users
  Future<List<Map<String, dynamic>>> _getAssignableUsers() async {
    try {
      final client = supabase.Supabase.instance.client;
      final response = await client
          .from('users')
          .select('id,name,email,role,is_active')
          .eq('is_active', true)
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching assignable users: $e');
      return [];
    }
  }
}
