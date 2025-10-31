import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../widgets/assigned_only_scope.dart';
import '../../data/services/database_service.dart';
import '../../data/models/models.dart';

class RoleAwareData {
  static bool _assignedOnly(BuildContext context) {
    final scope = AssignedOnlyScope.maybeOf(context);
    return scope?.assignedOnly ?? false;
  }

  static String? _currentUserId() {
    return supabase.Supabase.instance.client.auth.currentUser?.id;
  }

  static Future<List<Lead>> getLeads(BuildContext context) {
    if (_assignedOnly(context)) {
      final uid = _currentUserId();
      if (uid != null) {
        return DatabaseService.getLeads(assignedTo: uid);
      }
    }
    return DatabaseService.getLeads();
  }

  static Future<List<SiteVisit>> getSiteVisits(BuildContext context) {
    if (_assignedOnly(context)) {
      final uid = _currentUserId();
      if (uid != null) {
        return DatabaseService.getSiteVisits(assignedTo: uid);
      }
    }
    return DatabaseService.getSiteVisits();
  }

  static Future<List<Task>> getTasks(BuildContext context) {
    if (_assignedOnly(context)) {
      final uid = _currentUserId();
      if (uid != null) {
        return DatabaseService.getTasks(assignedTo: uid);
      }
    }
    return DatabaseService.getTasks();
  }

  static Future<List<Customer>> getCustomers(BuildContext context) {
    if (_assignedOnly(context)) {
      final uid = _currentUserId();
      if (uid != null) {
        return DatabaseService.getCustomers(assignedTo: uid);
      }
    }
    return DatabaseService.getCustomers();
  }
}
