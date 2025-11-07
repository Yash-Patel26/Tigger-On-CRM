import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../data/services/database_service.dart';
import '../../../data/services/database_service_masters.dart' as masters;
import '../../../data/models/models.dart';
import '../../../shared/utils/helpers.dart';
import '../../../shared/managers/auth_state_manager.dart';

/// Assign Lead Button Widget
///
/// This widget provides a button that opens a dialog to assign a lead to a user.
/// It should be placed in the AppBar actions of the lead detail screen.
class AssignLeadButton extends StatelessWidget {
  const AssignLeadButton({
    super.key,
    required this.onAssignComplete,
    required this.getLeadFuture,
  });

  final VoidCallback onAssignComplete;
  final Future<Lead> Function() getLeadFuture;

  void _showAssignDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AssignLeadDialog(
          onAssignComplete: onAssignComplete,
          getLeadFuture: getLeadFuture,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateManager>(
      builder: (context, authManager, _) {
        if (authManager.isAdminOrHead) {
          return IconButton(
            tooltip: 'Assign',
            icon: Icon(
              FontAwesomeIcons.userPlus,
              color: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => _showAssignDialog(context),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

/// Assign Lead Dialog Widget
class AssignLeadDialog extends StatefulWidget {
  const AssignLeadDialog({
    super.key,
    required this.onAssignComplete,
    required this.getLeadFuture,
  });

  final VoidCallback onAssignComplete;
  final Future<Lead> Function() getLeadFuture;

  @override
  State<AssignLeadDialog> createState() => _AssignLeadDialogState();
}

class _AssignLeadDialogState extends State<AssignLeadDialog> {
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
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getAssignableUsers(),
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
                            return const Text('Failed to load');
                          }
                          final String? currentUserId =
                              Helpers.getCurrentUserId();
                          List<Map<String, dynamic>> users =
                              snap.data ?? <Map<String, dynamic>>[];
                          // Exclude admin/head assignees if role present
                          users = users.where((u) {
                            final role = (u['role'] as String?)?.toLowerCase();
                            if (role == 'admin' || role == 'head') return false;
                            return true;
                          }).toList();
                          // Prevent assigning to self
                          users = users
                              .where(
                                (u) => (u['id'] as String?) != currentUserId,
                              )
                              .toList();

                          return DropdownButtonFormField<String>(
                            initialValue: _selectedUserId,
                            isExpanded: true,
                            items: users
                                .map(
                                  (Map<String, dynamic> u) =>
                                      DropdownMenuItem<String>(
                                        value: (u['id'] ?? '') as String,
                                        child: Text(() {
                                          final role = u['role'] as String?;
                                          final name =
                                              (u['name'] ?? '-') as String;
                                          return role != null && role.isNotEmpty
                                              ? '$name (${role.toString()})'
                                              : name;
                                        }()),
                                      ),
                                )
                                .toList(),
                            onChanged: (String? v) => setState(() {
                              _selectedUserId = v;
                              final Map<String, dynamic> sel = users.firstWhere(
                                (Map<String, dynamic> e) => e['id'] == v,
                                orElse: () => <String, dynamic>{},
                              );
                              _selectedUserName =
                                  (sel['name'] ?? '-') as String;
                            }),
                            decoration: const InputDecoration(
                              labelText: 'Assign to',
                              border: OutlineInputBorder(),
                            ),
                            validator: (String? v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (v == Helpers.getCurrentUserId()) {
                                return 'You cannot assign a lead to yourself';
                              }
                              return null;
                            },
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
      },
    );
  }

  void _onAssign() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;
    Navigator.of(context).pop();

    if (_selectedUserId == null) return;

    try {
      // Get current lead data using the callback
      final Lead currentLead = await widget.getLeadFuture();

      await DatabaseService.updateLeadAssignment(
        leadId: currentLead.id,
        assignedToId: _selectedUserId!,
        assignedToName: _selectedUserName,
      );

      // Log the assignment change
      await masters.DatabaseServiceMasters.logLeadAssignment(
        leadId: currentLead.id,
        oldAssignee: currentLead.assignedToName,
        newAssignee: _selectedUserName,
        performedBy: Helpers.getCurrentUserId() ?? 'system',
        performedByName: await Helpers.getCurrentUserName(),
      );

      // Refresh lead data
      widget.onAssignComplete();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Assigned to $_selectedUserName')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to assign: $e')));
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
