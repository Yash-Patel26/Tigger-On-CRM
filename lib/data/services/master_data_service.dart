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
      throw Exception('Failed to fetch states: $e');
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
      throw Exception('Failed to fetch cities: $e');
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
      throw Exception('Failed to fetch locations: $e');
    }
  }

  // Lead Sources Master
  static Future<List<LeadSourceMaster>> getLeadSourcesMaster() async {
    try {
      final response = await _client
          .from('lead_sources_master')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => LeadSourceMaster.fromJson(json))
          .toList();
    } catch (e) {
      // If table doesn't exist, return default lead sources
      return const [
        LeadSourceMaster(id: '1', name: '99 ACRES', isActive: true),
        LeadSourceMaster(id: '2', name: 'AFFORDABLE WEBSITE', isActive: true),
        LeadSourceMaster(id: '3', name: 'BULK DATA', isActive: true),
        LeadSourceMaster(id: '4', name: 'CHANNEL PARTNER', isActive: true),
        LeadSourceMaster(id: '5', name: 'CLIENT VISIT', isActive: true),
        LeadSourceMaster(id: '6', name: 'CROSS SELL', isActive: true),
        LeadSourceMaster(id: '7', name: 'FACEBOOK', isActive: true),
        LeadSourceMaster(id: '8', name: 'GOOGLE', isActive: true),
        LeadSourceMaster(id: '9', name: 'HOUSING', isActive: true),
        LeadSourceMaster(id: '10', name: 'IVR', isActive: true),
        LeadSourceMaster(id: '11', name: 'LINKEDIN', isActive: true),
        LeadSourceMaster(id: '12', name: 'MAGIC BRICKS', isActive: true),
        LeadSourceMaster(id: '13', name: 'MARCOM IDEAZ', isActive: true),
        LeadSourceMaster(id: '14', name: 'MARKETPLACE', isActive: true),
        LeadSourceMaster(id: '15', name: 'MONARCH INDIA', isActive: true),
        LeadSourceMaster(id: '16', name: 'NETINSURE WEB', isActive: true),
        LeadSourceMaster(id: '17', name: 'NL WEBSITE', isActive: true),
        LeadSourceMaster(id: '18', name: 'OTHERS', isActive: true),
      ];
    }
  }

  // Projects Master
  static Future<List<ProjectMaster>> getProjectsMaster() async {
    try {
      final response = await _client
          .from('projects')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => ProjectMaster.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  // Budget Master
  static Future<List<BudgetMaster>> getBudgetMaster() async {
    try {
      final response = await _client
          .from('budget_master')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => BudgetMaster.fromJson(json))
          .toList();
    } catch (e) {
      // If table doesn't exist, return default budget ranges
      return const [
        BudgetMaster(id: '1', name: 'Under 25 Lacs', isActive: true),
        BudgetMaster(id: '2', name: '25-50 Lacs', isActive: true),
        BudgetMaster(id: '3', name: '50-75 Lacs', isActive: true),
        BudgetMaster(id: '4', name: '75-100 Lacs', isActive: true),
        BudgetMaster(id: '5', name: '100-150 Lacs', isActive: true),
        BudgetMaster(id: '6', name: '150-200 Lacs', isActive: true),
        BudgetMaster(id: '7', name: 'Above 200 Lacs', isActive: true),
      ];
    }
  }

  // Purchase Plan Years
  static Future<List<PurchasePlanYear>> getPurchasePlanYears() async {
    try {
      final response = await _client
          .from('purchase_plan_years')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => PurchasePlanYear.fromJson(json))
          .toList();
    } catch (e) {
      // If table doesn't exist, return default years
      final currentYear = DateTime.now().year;
      return List.generate(10, (index) {
        final year = currentYear + index;
        return PurchasePlanYear(
          id: year.toString(),
          name: year.toString(),
          isActive: true,
        );
      });
    }
  }

  // Purchase Plan Months
  static Future<List<PurchasePlanMonth>> getPurchasePlanMonths() async {
    try {
      final response = await _client
          .from('purchase_plan_months')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => PurchasePlanMonth.fromJson(json))
          .toList();
    } catch (e) {
      // If table doesn't exist, return default months
      return const [
        PurchasePlanMonth(id: '1', name: 'January', isActive: true),
        PurchasePlanMonth(id: '2', name: 'February', isActive: true),
        PurchasePlanMonth(id: '3', name: 'March', isActive: true),
        PurchasePlanMonth(id: '4', name: 'April', isActive: true),
        PurchasePlanMonth(id: '5', name: 'May', isActive: true),
        PurchasePlanMonth(id: '6', name: 'June', isActive: true),
        PurchasePlanMonth(id: '7', name: 'July', isActive: true),
        PurchasePlanMonth(id: '8', name: 'August', isActive: true),
        PurchasePlanMonth(id: '9', name: 'September', isActive: true),
        PurchasePlanMonth(id: '10', name: 'October', isActive: true),
        PurchasePlanMonth(id: '11', name: 'November', isActive: true),
        PurchasePlanMonth(id: '12', name: 'December', isActive: true),
      ];
    }
  }

  // Users Master
  static Future<List<UserMaster>> getUsersMaster() async {
    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => UserMaster.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  // Gender Master
  static Future<List<GenderMaster>> getGenderMaster() async {
    try {
      final response = await _client
          .from('gender_master')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => GenderMaster.fromJson(json))
          .toList();
    } catch (e) {
      // If table doesn't exist, return default gender options
      return const [
        GenderMaster(id: '1', name: 'Male', isActive: true),
        GenderMaster(id: '2', name: 'Female', isActive: true),
        GenderMaster(id: '3', name: 'Other', isActive: true),
      ];
    }
  }

  // Marital Status Master
  static Future<List<MaritalStatusMaster>> getMaritalStatusMaster() async {
    try {
      final response = await _client
          .from('marital_status_master')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => MaritalStatusMaster.fromJson(json))
          .toList();
    } catch (e) {
      // If table doesn't exist, return default marital status options
      return const [
        MaritalStatusMaster(id: '1', name: 'Single', isActive: true),
        MaritalStatusMaster(id: '2', name: 'Married', isActive: true),
        MaritalStatusMaster(id: '3', name: 'Divorced', isActive: true),
        MaritalStatusMaster(id: '4', name: 'Widowed', isActive: true),
      ];
    }
  }

  // Employment Type Master
  static Future<List<EmploymentTypeMaster>> getEmploymentTypeMaster() async {
    try {
      final response = await _client
          .from('employment_type_master')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => EmploymentTypeMaster.fromJson(json))
          .toList();
    } catch (e) {
      // If table doesn't exist, return default employment type options
      return const [
        EmploymentTypeMaster(id: '1', name: 'Salaried', isActive: true),
        EmploymentTypeMaster(id: '2', name: 'Self-employed', isActive: true),
        EmploymentTypeMaster(id: '3', name: 'Business', isActive: true),
        EmploymentTypeMaster(id: '4', name: 'Retired', isActive: true),
        EmploymentTypeMaster(id: '5', name: 'Student', isActive: true),
        EmploymentTypeMaster(id: '6', name: 'Unemployed', isActive: true),
      ];
    }
  }

  // ITR Filing Status Master
  static Future<List<ItrFilingStatusMaster>> getItrFilingStatusMaster() async {
    try {
      final response = await _client
          .from('itr_filing_status_master')
          .select('*')
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => ItrFilingStatusMaster.fromJson(json))
          .toList();
    } catch (e) {
      // If table doesn't exist, return default ITR filing status options
      return const [
        ItrFilingStatusMaster(id: '1', name: 'Yes', isActive: true),
        ItrFilingStatusMaster(id: '2', name: 'No', isActive: true),
        ItrFilingStatusMaster(id: '3', name: 'Not Applicable', isActive: true),
      ];
    }
  }
}
