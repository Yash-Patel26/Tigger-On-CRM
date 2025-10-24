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

  // Option Types
  static Future<List<OptionType>> getOptionTypes() async {
    try {
      final response = await _client
          .from('option_types')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => OptionType.fromJson(json))
          .toList();
    } catch (e) {
      // If table doesn't exist, return default option types
      return const [
        OptionType(id: '1', name: 'Fresh', isActive: true),
        OptionType(id: '2', name: 'Resale', isActive: true),
      ];
    }
  }

  // States
  static Future<List<StateMaster>> getStates({String? countryId}) async {
    try {
      var query = _client.from('states').select('*').eq('is_active', true);

      if (countryId != null) {
        query = query.eq('country_id', countryId);
      }

      final response = await query.order('name');
      return (response as List)
          .map((json) => StateMaster.fromJson(json))
          .toList();
    } catch (e) {
      // If table doesn't exist, return default states
      return const [
        StateMaster(id: '1', name: 'Gujarat', countryId: '1', isActive: true),
        StateMaster(
          id: '2',
          name: 'Maharashtra',
          countryId: '1',
          isActive: true,
        ),
        StateMaster(id: '3', name: 'Haryana', countryId: '1', isActive: true),
        StateMaster(id: '4', name: 'Delhi', countryId: '1', isActive: true),
        StateMaster(id: '5', name: 'Karnataka', countryId: '1', isActive: true),
      ];
    }
  }

  // Cities
  static Future<List<City>> getCities({String? stateId}) async {
    try {
      var query = _client.from('cities').select('*').eq('is_active', true);

      if (stateId != null) {
        query = query.eq('state_id', stateId);
      }

      final response = await query.order('name');
      return (response as List).map((json) => City.fromJson(json)).toList();
    } catch (e) {
      // If table doesn't exist, return default cities
      return const [
        City(id: '1', name: 'Ahmedabad', stateId: '1', isActive: true),
        City(id: '2', name: 'Mumbai', stateId: '2', isActive: true),
        City(id: '3', name: 'Gurugram', stateId: '3', isActive: true),
        City(id: '4', name: 'New Delhi', stateId: '4', isActive: true),
        City(id: '5', name: 'Bangalore', stateId: '5', isActive: true),
      ];
    }
  }

  // Locations
  static Future<List<Location>> getLocations({String? cityId}) async {
    try {
      var query = _client.from('locations').select('*').eq('is_active', true);

      if (cityId != null) {
        query = query.eq('city_id', cityId);
      }

      final response = await query.order('name');
      return (response as List).map((json) => Location.fromJson(json)).toList();
    } catch (e) {
      // If table doesn't exist, return default locations
      return const [
        Location(id: '1', name: 'Gift City', cityId: '1', isActive: true),
        Location(id: '2', name: 'NH 48, Part 2', cityId: '1', isActive: true),
        Location(
          id: '3',
          name: 'Bandra Kurla Complex',
          cityId: '2',
          isActive: true,
        ),
        Location(id: '4', name: 'Cyber City', cityId: '3', isActive: true),
        Location(id: '5', name: 'Connaught Place', cityId: '4', isActive: true),
      ];
    }
  }

  // Projects
  static Future<List<Project>> getProjects() async {
    try {
      final response = await _client
          .from('projects')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List).map((json) => Project.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  // Inventories
  static Future<List<Inventory>> getInventories({String? projectId}) async {
    try {
      var query = _client.from('inventories').select('*').eq('is_active', true);

      if (projectId != null) {
        query = query.eq('project_id', projectId);
      }

      final response = await query.order('name');
      return (response as List)
          .map((json) => Inventory.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch inventories: $e');
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
