import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vendor_model.dart';
import 'supabase_service.dart';

class VendorService {
  static SupabaseClient get _client => SupabaseService.client;

  // Get all vendors
  static Future<List<VendorModel>> getAllVendors() async {
    try {
      final response = await _client
          .from('developers')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => VendorModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vendors: $e');
    }
  }

  // Get vendor by ID
  static Future<VendorModel?> getVendorById(String id) async {
    try {
      final response = await _client
          .from('developers')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return VendorModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch vendor: $e');
    }
  }

  // Create new vendor
  static Future<VendorModel> createVendor({
    required String name,
    String? website,
    String? logoUrl,
    required String address,
    required String state,
    required String district,
    required String city,
    required String pincode,
    String country = 'India',
    required String companyType,
    required bool isReraRegistered,
    String? reraNumber,
    required String gstin,
    String? gstinFilePath,
    required String pan,
    String? panFilePath,
    String? aadhar,
    String? aadharFilePath,
    bool isActive = true,
    required String createdBy,
    required String createdByName,
    Map<String, dynamic>? customFields,
  }) async {
    try {
      final response = await _client
          .from('developers')
          .insert({
            'name': name,
            'website': website,
            'logo_url': logoUrl,
            'address': address,
            'state': state,
            'district': district,
            'city': city,
            'pincode': pincode,
            'country': country,
            'company_type': companyType,
            'is_rera_registered': isReraRegistered,
            'rera_number': reraNumber,
            'gstin': gstin,
            'gstin_file_path': gstinFilePath,
            'pan': pan,
            'pan_file_path': panFilePath,
            'aadhar': aadhar,
            'aadhar_file_path': aadharFilePath,
            'is_active': isActive,
            'created_by': createdBy,
            'created_by_name': createdByName,
            'custom_fields': customFields,
          })
          .select()
          .single();

      return VendorModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create vendor: $e');
    }
  }

  // Update vendor
  static Future<VendorModel> updateVendor({
    required String id,
    String? name,
    String? website,
    String? logoUrl,
    String? address,
    String? state,
    String? district,
    String? city,
    String? pincode,
    String? country,
    String? companyType,
    bool? isReraRegistered,
    String? reraNumber,
    String? gstin,
    String? gstinFilePath,
    String? pan,
    String? panFilePath,
    String? aadhar,
    String? aadharFilePath,
    bool? isActive,
    Map<String, dynamic>? customFields,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (website != null) updateData['website'] = website;
      if (logoUrl != null) updateData['logo_url'] = logoUrl;
      if (address != null) updateData['address'] = address;
      if (state != null) updateData['state'] = state;
      if (district != null) updateData['district'] = district;
      if (city != null) updateData['city'] = city;
      if (pincode != null) updateData['pincode'] = pincode;
      if (country != null) updateData['country'] = country;
      if (companyType != null) updateData['company_type'] = companyType;
      if (isReraRegistered != null)
        updateData['is_rera_registered'] = isReraRegistered;
      if (reraNumber != null) updateData['rera_number'] = reraNumber;
      if (gstin != null) updateData['gstin'] = gstin;
      if (gstinFilePath != null) updateData['gstin_file_path'] = gstinFilePath;
      if (pan != null) updateData['pan'] = pan;
      if (panFilePath != null) updateData['pan_file_path'] = panFilePath;
      if (aadhar != null) updateData['aadhar'] = aadhar;
      if (aadharFilePath != null)
        updateData['aadhar_file_path'] = aadharFilePath;
      if (isActive != null) updateData['is_active'] = isActive;
      if (customFields != null) updateData['custom_fields'] = customFields;

      final response = await _client
          .from('developers')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return VendorModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update vendor: $e');
    }
  }

  // Delete vendor
  static Future<void> deleteVendor(String id) async {
    try {
      await _client.from('developers').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete vendor: $e');
    }
  }

  // Search vendors
  static Future<List<VendorModel>> searchVendors(String query) async {
    try {
      final response = await _client
          .from('developers')
          .select()
          .or(
            'name.ilike.%$query%,website.ilike.%$query%,city.ilike.%$query%,state.ilike.%$query%',
          )
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => VendorModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to search vendors: $e');
    }
  }

  // Get vendors by status
  static Future<List<VendorModel>> getVendorsByStatus(bool isActive) async {
    try {
      final response = await _client
          .from('developers')
          .select()
          .eq('is_active', isActive)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => VendorModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vendors by status: $e');
    }
  }

  // Vendor Contacts Management
  static Future<List<VendorContactModel>> getVendorContacts(
    String vendorId,
  ) async {
    try {
      final response = await _client
          .from('developer_contacts')
          .select()
          .eq('developer_id', vendorId)
          .order('is_primary', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => VendorContactModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vendor contacts: $e');
    }
  }

  static Future<VendorContactModel> createVendorContact({
    required String vendorId,
    required String name,
    required String mobile,
    required String designation,
    required String email,
    bool isPrimary = false,
  }) async {
    try {
      final response = await _client
          .from('developer_contacts')
          .insert({
            'developer_id': vendorId,
            'name': name,
            'mobile': mobile,
            'designation': designation,
            'email': email,
            'is_primary': isPrimary,
          })
          .select()
          .single();

      return VendorContactModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create vendor contact: $e');
    }
  }

  static Future<VendorContactModel> updateVendorContact({
    required String id,
    String? name,
    String? mobile,
    String? designation,
    String? email,
    bool? isPrimary,
  }) async {
    try {
      final Map<String, dynamic> updateData = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (mobile != null) updateData['mobile'] = mobile;
      if (designation != null) updateData['designation'] = designation;
      if (email != null) updateData['email'] = email;
      if (isPrimary != null) updateData['is_primary'] = isPrimary;

      final response = await _client
          .from('developer_contacts')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      return VendorContactModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update vendor contact: $e');
    }
  }

  static Future<void> deleteVendorContact(String id) async {
    try {
      await _client.from('developer_contacts').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete vendor contact: $e');
    }
  }

  // Bank Details Management
  static Future<List<VendorBankDetailsModel>> getVendorBankDetails(
    String vendorId,
  ) async {
    try {
      final response = await _client
          .from('bank_details')
          .select()
          .eq('id', vendorId) // Assuming we'll link bank details to vendor
          .order('is_primary', ascending: false)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => VendorBankDetailsModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vendor bank details: $e');
    }
  }

  static Future<VendorBankDetailsModel> createVendorBankDetails({
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
    required String ifscCode,
    required String branchName,
    required String accountType,
    required String bankCategory,
    String? micrCode,
    String? swiftCode,
    String? address,
    String? city,
    String? state,
    String? pincode,
    bool isPrimary = false,
    bool isActive = true,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _client
          .from('bank_details')
          .insert({
            'bank_name': bankName,
            'account_number': accountNumber,
            'account_holder_name': accountHolderName,
            'ifsc_code': ifscCode,
            'branch_name': branchName,
            'account_type': accountType,
            'bank_category': bankCategory,
            'micr_code': micrCode,
            'swift_code': swiftCode,
            'address': address,
            'city': city,
            'state': state,
            'pincode': pincode,
            'is_primary': isPrimary,
            'is_active': isActive,
            'metadata': metadata,
          })
          .select()
          .single();

      return VendorBankDetailsModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create vendor bank details: $e');
    }
  }

  // Get vendor statistics
  static Future<Map<String, int>> getVendorStats() async {
    try {
      final totalResponse = await _client.from('developers').select('id');

      final activeResponse = await _client
          .from('developers')
          .select('id')
          .eq('is_active', true);

      return {
        'total': totalResponse.length,
        'active': activeResponse.length,
        'inactive': totalResponse.length - activeResponse.length,
      };
    } catch (e) {
      throw Exception('Failed to fetch vendor statistics: $e');
    }
  }
}
