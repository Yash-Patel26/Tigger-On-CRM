import '../../core/config/supabase_config.dart';
import '../models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MasterDataService {
  static SupabaseClient get _client => SupabaseConfig.client;

  // Property Categories
  static Future<List<PropertyCategory>> getPropertyCategories() async {
    try {
      final response = await _client
          .from('property_categories')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => PropertyCategory.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch property categories: $e');
    }
  }

  // Property Types Master
  static Future<List<PropertyTypeMaster>> getPropertyTypesMaster() async {
    try {
      final response = await _client
          .from('property_types_master')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => PropertyTypeMaster.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch property types master: $e');
    }
  }

  // Visit Modes Master
  static Future<List<VisitModeMaster>> getVisitModesMaster() async {
    try {
      final response = await _client
          .from('visit_modes_master')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => VisitModeMaster.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch visit modes master: $e');
    }
  }

  // Lead Status Master
  static Future<List<LeadStatusMaster>> getLeadStatusMaster() async {
    try {
      final response = await _client
          .from('lead_status_master')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => LeadStatusMaster.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch lead status master: $e');
    }
  }

  // Lead Sub Status Master
  static Future<List<LeadSubStatusMaster>> getLeadSubStatusMaster(
    String statusId,
  ) async {
    try {
      final response = await _client
          .from('lead_sub_status_master')
          .select('*')
          .eq('is_active', true)
          .eq('status_id', statusId)
          .order('name');

      return (response as List)
          .map((json) => LeadSubStatusMaster.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch lead sub status master: $e');
    }
  }

  // Inventory Types
  static Future<List<InventoryType>> getInventoryTypes() async {
    try {
      final response = await _client
          .from('inventory_types')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => InventoryType.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch inventory types: $e');
    }
  }

  // Assignment Users
  static Future<List<AssignmentUser>> getAssignmentUsers() async {
    try {
      final response = await _client
          .from('assignment_users')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => AssignmentUser.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch assignment users: $e');
    }
  }

  // Ticket Disposition Main
  static Future<List<TicketDispositionMain>> getTicketDispositionMains() async {
    try {
      final response = await _client
          .from('ticket_disposition_main')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => TicketDispositionMain.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch ticket disposition mains: $e');
    }
  }

  // Ticket Disposition Sub
  static Future<List<TicketDispositionSub>> getTicketDispositionSubs(
    String mainId,
  ) async {
    try {
      final response = await _client
          .from('ticket_disposition_sub')
          .select('*')
          .eq('is_active', true)
          .eq('main_id', mainId)
          .order('name');

      return (response as List)
          .map((json) => TicketDispositionSub.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch ticket disposition subs: $e');
    }
  }
}
