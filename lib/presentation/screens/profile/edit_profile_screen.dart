import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/services/location_data_service.dart';
import '../../../data/models/profile_model.dart';
import '../../../shared/utils/validation_utils.dart';

class EditProfileScreen extends StatefulWidget {
  final Profile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _designationController = TextEditingController();
  final _departmentController = TextEditingController();
  final _roleController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  // Basic Details Controllers
  final _dobController = TextEditingController();
  final _panController = TextEditingController();
  final _aadharController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController();

  // Mapping Details Controllers
  final _ivrNameController = TextEditingController();
  final _ivrNumberController = TextEditingController();
  final _teamController = TextEditingController();
  final _groupController = TextEditingController();
  final _projectNameController = TextEditingController();
  final _userTypeController = TextEditingController();

  bool _isLoading = false;
  DateTime? _selectedDob;

  // Location data
  List<Map<String, dynamic>> _countries = [];
  List<Map<String, dynamic>> _states = [];
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _pincodes = [];
  List<Map<String, dynamic>> _projects = [];

  String? _selectedCountryId;
  String? _selectedStateId;
  String? _selectedCityId;
  String? _selectedPincodeId;
  String? _selectedProjectId;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadLocationData();
  }

  void _initializeControllers() {
    _fullNameController.text = widget.profile.fullName;
    _phoneController.text = widget.profile.phone ?? '';
    _designationController.text = widget.profile.designation ?? '';
    _departmentController.text = widget.profile.department ?? '';
    _roleController.text = widget.profile.role ?? '';
    _avatarUrlController.text = widget.profile.avatarUrl ?? '';

    // Initialize metadata fields
    final metadata = widget.profile.metadata ?? {};
    _dobController.text = metadata['dob'] as String? ?? '';
    _panController.text = metadata['pan'] as String? ?? '';
    _aadharController.text = metadata['aadhar'] as String? ?? '';
    _countryController.text = metadata['country'] as String? ?? '';
    _stateController.text = metadata['state'] as String? ?? '';
    _cityController.text = metadata['city'] as String? ?? '';
    _addressController.text = metadata['address'] as String? ?? '';
    _pincodeController.text = metadata['pincode'] as String? ?? '';

    _ivrNameController.text = metadata['ivr_name'] as String? ?? '';
    _ivrNumberController.text = metadata['ivr_number'] as String? ?? '';
    _teamController.text = metadata['team'] as String? ?? '';
    _groupController.text = metadata['group'] as String? ?? '';
    _projectNameController.text = metadata['project_name'] as String? ?? '';
    _userTypeController.text = metadata['user_type'] as String? ?? '';

    // Set selected location IDs from metadata
    _selectedCountryId = metadata['country_id'] as String?;
    _selectedStateId = metadata['state_id'] as String?;
    _selectedCityId = metadata['city_id'] as String?;
    _selectedPincodeId = metadata['pincode_id'] as String?;
    _selectedProjectId = metadata['project_id'] as String?;
  }

  Future<void> _loadLocationData() async {
    try {
      // Load countries
      _countries = await LocationDataService.getCountries();

      // Load projects
      _projects = await LocationDataService.getProjects();

      // Load states if country is selected
      if (_selectedCountryId != null) {
        _states = await LocationDataService.getStatesByCountry(
          _selectedCountryId!,
        );

        // Load cities if state is selected
        if (_selectedStateId != null) {
          _cities = await LocationDataService.getCitiesByState(
            _selectedStateId!,
          );

          // Load pincodes if city is selected
          if (_selectedCityId != null) {
            _pincodes = await LocationDataService.getPincodesByCity(
              _selectedCityId!,
            );
          }
        }
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading location data: $e');
    }
  }

  Future<void> _onCountryChanged(String? countryId) async {
    if (countryId == null) return;

    setState(() {
      _selectedCountryId = countryId;
      _selectedStateId = null;
      _selectedCityId = null;
      _selectedPincodeId = null;
      _states = [];
      _cities = [];
      _pincodes = [];
    });

    try {
      _states = await LocationDataService.getStatesByCountry(countryId);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading states: $e');
    }
  }

  Future<void> _onStateChanged(String? stateId) async {
    if (stateId == null) return;

    setState(() {
      _selectedStateId = stateId;
      _selectedCityId = null;
      _selectedPincodeId = null;
      _cities = [];
      _pincodes = [];
    });

    try {
      _cities = await LocationDataService.getCitiesByState(stateId);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading cities: $e');
    }
  }

  Future<void> _onCityChanged(String? cityId) async {
    if (cityId == null) return;

    setState(() {
      _selectedCityId = cityId;
      _selectedPincodeId = null;
      _pincodes = [];
    });

    try {
      _pincodes = await LocationDataService.getPincodesByCity(cityId);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading pincodes: $e');
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    _roleController.dispose();
    _avatarUrlController.dispose();
    _dobController.dispose();
    _panController.dispose();
    _aadharController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _ivrNameController.dispose();
    _ivrNumberController.dispose();
    _teamController.dispose();
    _groupController.dispose();
    _projectNameController.dispose();
    _userTypeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDob ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Prepare metadata
      final Map<String, dynamic> metadata = {
        'dob': _dobController.text.isNotEmpty ? _dobController.text : null,
        'pan': _panController.text.isNotEmpty ? _panController.text : null,
        'aadhar': _aadharController.text.isNotEmpty
            ? _aadharController.text
            : null,
        'country_id': _selectedCountryId,
        'state_id': _selectedStateId,
        'city_id': _selectedCityId,
        'pincode_id': _selectedPincodeId,
        'project_id': _selectedProjectId,
        'address': _addressController.text.isNotEmpty
            ? _addressController.text
            : null,
        'ivr_name': _ivrNameController.text.isNotEmpty
            ? _ivrNameController.text
            : null,
        'ivr_number': _ivrNumberController.text.isNotEmpty
            ? _ivrNumberController.text
            : null,
        'team': _teamController.text.isNotEmpty ? _teamController.text : null,
        'group': _groupController.text.isNotEmpty
            ? _groupController.text
            : null,
        'user_type': _userTypeController.text.isNotEmpty
            ? _userTypeController.text
            : null,
      };

      // Remove null values
      metadata.removeWhere((key, value) => value == null);

      await SupabaseService.updateProfile(
        userId: userId,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        designation: _designationController.text.trim().isNotEmpty
            ? _designationController.text.trim()
            : null,
        department: _departmentController.text.trim().isNotEmpty
            ? _departmentController.text.trim()
            : null,
        role: _roleController.text.trim().isNotEmpty
            ? _roleController.text.trim()
            : null,
        avatarUrl: _avatarUrlController.text.trim().isNotEmpty
            ? _avatarUrlController.text.trim()
            : null,
        metadata: metadata.isNotEmpty ? metadata : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                title: 'Basic Information',
                children: [
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'Full Name',
                    icon: Icons.person,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: ValidationUtils.validatePhone,
                  ),
                  _buildTextField(
                    controller: _designationController,
                    label: 'Designation',
                    icon: Icons.work,
                  ),
                  _buildTextField(
                    controller: _departmentController,
                    label: 'Department',
                    icon: Icons.business,
                  ),
                  _buildTextField(
                    controller: _roleController,
                    label: 'Role',
                    icon: Icons.admin_panel_settings,
                  ),
                  _buildTextField(
                    controller: _avatarUrlController,
                    label: 'Avatar URL',
                    icon: Icons.image,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Personal Details',
                children: [
                  _buildDateField(
                    controller: _dobController,
                    label: 'Date of Birth',
                    icon: Icons.cake,
                    onTap: _selectDate,
                    validator: ValidationUtils.validateDOB,
                  ),
                  _buildTextField(
                    controller: _panController,
                    label: 'PAN Card',
                    icon: Icons.badge,
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: ValidationUtils.validatePAN,
                  ),
                  _buildTextField(
                    controller: _aadharController,
                    label: 'Aadhar Card',
                    icon: Icons.credit_card,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(12),
                    ],
                    validator: ValidationUtils.validateAadhar,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Address Information',
                children: [
                  _buildDropdownField(
                    label: 'Country',
                    icon: Icons.flag,
                    value: _selectedCountryId,
                    items: _countries
                        .map(
                          (country) => DropdownMenuItem(
                            value: country['id'].toString(),
                            child: Text(country['name']),
                          ),
                        )
                        .toList(),
                    onChanged: _onCountryChanged,
                    validator: (value) =>
                        ValidationUtils.validateRequired(value, 'Country'),
                  ),
                  _buildDropdownField(
                    label: 'State',
                    icon: Icons.map,
                    value: _selectedStateId,
                    items: _states
                        .map(
                          (state) => DropdownMenuItem(
                            value: state['id'].toString(),
                            child: Text(state['name']),
                          ),
                        )
                        .toList(),
                    onChanged: _onStateChanged,
                    validator: (value) =>
                        ValidationUtils.validateRequired(value, 'State'),
                  ),
                  _buildDropdownField(
                    label: 'City',
                    icon: Icons.location_city,
                    value: _selectedCityId,
                    items: _cities
                        .map(
                          (city) => DropdownMenuItem(
                            value: city['id'].toString(),
                            child: Text(city['name']),
                          ),
                        )
                        .toList(),
                    onChanged: _onCityChanged,
                    validator: (value) =>
                        ValidationUtils.validateRequired(value, 'City'),
                  ),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    icon: Icons.home,
                    maxLines: 3,
                    validator: (value) =>
                        ValidationUtils.validateRequired(value, 'Address'),
                  ),
                  _buildDropdownField(
                    label: 'Pincode',
                    icon: Icons.local_post_office,
                    value: _selectedPincodeId,
                    items: _pincodes
                        .map(
                          (pincode) => DropdownMenuItem(
                            value: pincode['id'].toString(),
                            child: Text(pincode['pincode']),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPincodeId = value;
                      });
                    },
                    validator: (value) =>
                        ValidationUtils.validateRequired(value, 'Pincode'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Work Details',
                children: [
                  _buildDropdownField(
                    label: 'Project',
                    icon: Icons.folder,
                    value: _selectedProjectId,
                    items: _projects
                        .map(
                          (project) => DropdownMenuItem(
                            value: project['id'].toString(),
                            child: Text(
                              '${project['name']} - ${project['city']}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProjectId = value;
                      });
                    },
                  ),
                  _buildTextField(
                    controller: _ivrNameController,
                    label: 'IVR Name',
                    icon: Icons.phone_callback,
                  ),
                  _buildTextField(
                    controller: _ivrNumberController,
                    label: 'IVR Number',
                    icon: Icons.numbers,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    controller: _teamController,
                    label: 'Team',
                    icon: Icons.group,
                  ),
                  _buildTextField(
                    controller: _groupController,
                    label: 'Group',
                    icon: Icons.group_work,
                  ),
                  _buildTextField(
                    controller: _userTypeController,
                    label: 'User Type',
                    icon: Icons.person_pin,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        readOnly: true,
        onTap: onTap,
        validator: validator,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: items,
        onChanged: onChanged,
        validator: validator,
        isExpanded: true,
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
