import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/managers/auth_state_manager.dart';
import '../../shared/widgets/assigned_only_scope.dart';

class RoleGate extends StatelessWidget {
  const RoleGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStateManager>();
    final bool assignedOnly = !(auth.isAdminOrHead);
    return AssignedOnlyScope(assignedOnly: assignedOnly, child: child);
  }
}
