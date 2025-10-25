import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../data/services/master_data_service.dart';
import '../../../../data/services/lead_duplicate_service.dart';
import '../../../../data/services/lead_service.dart';
import '../../../../data/models/models.dart';

class CreateLeadScreen extends StatefulWidget {
  const CreateLeadScreen({super.key});

  @override
  State<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen> {
  final _basicFormKey = GlobalKey<FormState>();
  final _preferenceFormKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 2;

  // Basic Details Controllers
  final _countryCodeController = TextEditingController(text: '+91');
  final _contactNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _occupationController = TextEditingController();
  final _addressController = TextEditingController();

  // Preference Details Controllers
  final _remarkController = TextEditingController();
  final _budgetController = TextEditingController();

  // Dropdown values
  String? _selectedLeadSource;
  String? _selectedAssignTo;
  String? _selectedProject;
  String? _selectedProjectCategory;
  String? _selectedPropertyType;
  String? _selectedState;
  String? _selectedCity;
  String? _selectedLocation;
  String? _selectedPurchaseYear;
  String? _selectedPurchaseMonth;
  String? _selectedBudget;

  // Master data lists
  List<LeadSourceMaster> _leadSources = [];
  List<UserMaster> _users = [];
  List<ProjectMaster> _projects = [];
  List<PropertyCategory> _propertyCategories = [];
  List<PropertyTypeMaster> _propertyTypes = [];
  List<StateMaster> _states = [];
  List<City> _cities = [];
  List<Location> _locations = [];
  List<PurchasePlanYear> _purchaseYears = [];
  List<PurchasePlanMonth> _purchaseMonths = [];
  List<BudgetMaster> _budgets = [];

  // Loading states
  bool _isLoadingMasterData = true;
  bool _isCheckingDuplicate = false;
  bool _isSaving = false;

  // Duplicate lead info
  Map<String, dynamic>? _duplicateLeadInfo;

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  @override
  void dispose() {
    _countryCodeController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _occupationController.dispose();
    _addressController.dispose();
    _remarkController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _loadMasterData() async {
    try {
      setState(() {
        _isLoadingMasterData = true;
      });

      // Load all master data in parallel
      final results = await Future.wait([
        MasterDataService.getLeadSourcesMaster(),
        MasterDataService.getUsersMaster(),
        MasterDataService.getProjectsMaster(),
        MasterDataService.getPropertyCategories(),
        MasterDataService.getPropertyTypesMaster(),
        MasterDataService.getStates(),
        MasterDataService.getPurchasePlanYears(),
        MasterDataService.getPurchasePlanMonths(),
        MasterDataService.getBudgetMaster(),
      ]);

      setState(() {
        _leadSources = results[0] as List<LeadSourceMaster>;
        _users = results[1] as List<UserMaster>;
        _projects = results[2] as List<ProjectMaster>;
        _propertyCategories = results[3] as List<PropertyCategory>;
        _propertyTypes = results[4] as List<PropertyTypeMaster>;
        _states = results[5] as List<StateMaster>;
        _purchaseYears = results[6] as List<PurchasePlanYear>;
        _purchaseMonths = results[7] as List<PurchasePlanMonth>;
        _budgets = results[8] as List<BudgetMaster>;
        _isLoadingMasterData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMasterData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _checkDuplicateLead() async {
    final contactNumber = _contactNumberController.text.trim();
    if (contactNumber.isEmpty) return;

    setState(() {
      _isCheckingDuplicate = true;
    });

    try {
      final duplicateInfo = await LeadDuplicateService.checkDuplicateLead(
        contactNumber,
      );

      setState(() {
        _duplicateLeadInfo = duplicateInfo;
        _isCheckingDuplicate = false;
      });

      if (duplicateInfo != null && duplicateInfo['exists'] == true) {
        if (mounted) {
          _showDuplicateLeadDialog(duplicateInfo);
        }
      }
    } catch (e) {
      setState(() {
        _isCheckingDuplicate = false;
      });
      print('Error checking duplicate: $e');
    }
  }

  void _showDuplicateLeadDialog(Map<String, dynamic> duplicateInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Duplicate Lead Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lead ID: ${duplicateInfo['lead_id']}'),
            Text('Customer Name: ${duplicateInfo['customer_name']}'),
            Text('Assigned To: ${duplicateInfo['assigned_to_name']}'),
            Text('Created At: ${_formatDate(duplicateInfo['created_at'])}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to lead screen
            },
            child: const Text('View Lead'),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final DateTime dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatISTDateTime(DateTime dateTime) {
    // Convert to IST (UTC+5:30)
    final istDateTime = dateTime.toUtc().add(
      const Duration(hours: 5, minutes: 30),
    );

    // Format date
    final day = istDateTime.day.toString().padLeft(2, '0');
    final month = istDateTime.month.toString().padLeft(2, '0');
    final year = istDateTime.year;

    // Format time
    final hour = istDateTime.hour.toString().padLeft(2, '0');
    final minute = istDateTime.minute.toString().padLeft(2, '0');
    final second = istDateTime.second.toString().padLeft(2, '0');

    return '$day/$month/$year at $hour:$minute:$second IST';
  }

  void _showSuccessDialog(BuildContext context) {
    final now = DateTime.now();
    final istDateTime = _formatISTDateTime(now);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Lead Created Successfully!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your lead has been created and saved to the database.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Created on: $istDateTime',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to lead screen
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onProjectChanged(String? projectId) {
    if (projectId == null) return;

    final project = _projects.firstWhere((p) => p.id == projectId);

    setState(() {
      _selectedProject = projectId;
      _selectedProjectCategory = project.category;
      _selectedState = project.state;
      _selectedCity = project.city;
      _selectedLocation = project.location;
    });

    // Load cities and locations based on selected state and city
    if (project.state != null) {
      // Find the state ID from the states list
      try {
        final state = _states.firstWhere((s) => s.name == project.state);
        _loadCities(state.id);
      } catch (e) {
        print('State not found: ${project.state}');
      }
    }
    if (project.city != null) {
      // Find the city ID from the cities list
      try {
        final city = _cities.firstWhere((c) => c.name == project.city);
        _loadLocations(city.id);
      } catch (e) {
        print('City not found: ${project.city}');
      }
    }
  }

  Future<void> _loadCities(String stateId) async {
    try {
      final cities = await MasterDataService.getCities(stateId: stateId);
      setState(() {
        _cities = cities;
      });
    } catch (e) {
      print('Error loading cities: $e');
    }
  }

  Future<void> _loadLocations(String cityId) async {
    try {
      final locations = await MasterDataService.getLocations(cityId: cityId);
      setState(() {
        _locations = locations;
      });
    } catch (e) {
      print('Error loading locations: $e');
    }
  }

  Future<void> _saveAndContinue() async {
    if (!_basicFormKey.currentState!.validate()) {
      return;
    }

    if (_currentPage == 0) {
      // Move to next page
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Save the lead
      await _saveLead();
    }
  }

  Future<void> _saveLead() async {
    if (!_preferenceFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Create lead object
      final lead = Lead(
        id: '', // Will be generated by database
        leadId: '', // Will be generated by database
        customerName:
            '${_firstNameController.text.trim()} ${_middleNameController.text.trim()} ${_lastNameController.text.trim()}'
                .trim(),
        email: _emailController.text.trim(),
        phone: '${_countryCodeController.text}${_contactNumberController.text}',
        address: _addressController.text.trim(),
        occupation: _occupationController.text.trim(),
        status: LeadStatus.cold, // Default status
        subStatus: LeadSubStatus.newLead, // Default sub status
        source: _getLeadSourceEnum(_selectedLeadSource),
        propertyType: _getPropertyTypeEnum(_selectedPropertyType),
        categoryType: CategoryType.a, // Default category
        projectId: _selectedProject,
        projectName: _projects.firstWhere((p) => p.id == _selectedProject).name,
        budgetRange: _selectedBudget,
        requirements: _remarkController.text.trim(),
        notes: _remarkController.text.trim(),
        assignedTo: _selectedAssignTo ?? '',
        assignedToName: _users
            .firstWhere((u) => u.id == _selectedAssignTo)
            .name,
        createdBy: '', // Will be set by service
        createdByName: '', // Will be set by service
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        hasSiteVisit: false,
        followUpCount: 0,
        siteVisitCount: 0,
        isDuplicate: false,
      );

      final leadService = LeadService();
      final response = await leadService.createLead(lead);

      if (response.success) {
        if (mounted) {
          _showSuccessDialog(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating lead: ${response.error}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating lead: $e')));
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  LeadSource _getLeadSourceEnum(String? sourceName) {
    if (sourceName == null) return LeadSource.other;

    switch (sourceName.toUpperCase()) {
      case 'PORTAL':
        return LeadSource.portal;
      case 'WALK IN':
        return LeadSource.walkIn;
      case 'REFERRAL':
        return LeadSource.referral;
      case 'WEBSITE':
        return LeadSource.website;
      case 'SOCIAL MEDIA':
        return LeadSource.socialMedia;
      default:
        return LeadSource.other;
    }
  }

  PropertyType _getPropertyTypeEnum(String? typeName) {
    if (typeName == null) return PropertyType.residential;

    switch (typeName.toUpperCase()) {
      case 'RESIDENTIAL':
        return PropertyType.residential;
      case 'COMMERCIAL':
        return PropertyType.commercial;
      case 'INDUSTRIAL':
        return PropertyType.industrial;
      case 'LAND':
        return PropertyType.land;
      default:
        return PropertyType.residential;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Lead'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingMasterData
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Progress indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (_currentPage + 1) / _totalPages,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${_currentPage + 1}/$_totalPages',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                // Page content
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: [
                      _buildBasicDetailsPage(),
                      _buildPreferenceDetailsPage(),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              if (_currentPage > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Previous'),
                  ),
                ),
              if (_currentPage > 0) const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: _isSaving ? null : _saveAndContinue,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _currentPage == _totalPages - 1
                              ? 'Save Lead'
                              : 'Continue',
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _basicFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Basic Details'),
            const SizedBox(height: 12),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Contact Number with Country Code
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          controller: _countryCodeController,
                          decoration: InputDecoration(
                            labelText: 'Code',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[+\d]')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _contactNumberController,
                          decoration: InputDecoration(
                            labelText: 'Contact Number *',
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              size: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Contact number is required';
                            }
                            if (value.length < 10) {
                              return 'Please enter a valid 10-digit number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            if (value.length == 10) {
                              _checkDuplicateLead();
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  // Show duplicate check status
                  if (_isCheckingDuplicate)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Checking for duplicates...'),
                        ],
                      ),
                    ),

                  if (_duplicateLeadInfo != null &&
                      _duplicateLeadInfo!['exists'] == true)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        border: Border.all(color: Colors.orange),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.orange[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Lead already exists with ID: ${_duplicateLeadInfo!['lead_id']}',
                              style: TextStyle(color: Colors.orange[700]),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Email ID
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email ID *',
                      prefixIcon: const Icon(Icons.email_outlined, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Lead Source
                  DropdownButtonFormField<String>(
                    value: _selectedLeadSource,
                    decoration: InputDecoration(
                      labelText: 'Lead Source *',
                      prefixIcon: const Icon(Icons.source_outlined, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _leadSources.map((source) {
                      return DropdownMenuItem<String>(
                        value: source.name,
                        child: Text(source.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLeadSource = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lead source is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // First Name
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name *',
                      prefixIcon: const Icon(Icons.person_outline, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Middle Name
                  TextFormField(
                    controller: _middleNameController,
                    decoration: InputDecoration(
                      labelText: 'Middle Name',
                      prefixIcon: const Icon(Icons.person_outline, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Last Name
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name *',
                      prefixIcon: const Icon(Icons.person_outline, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Occupation
                  TextFormField(
                    controller: _occupationController,
                    decoration: InputDecoration(
                      labelText: 'Occupation *',
                      prefixIcon: const Icon(Icons.work_outline, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Occupation is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Assign To
                  DropdownButtonFormField<String>(
                    value: _selectedAssignTo,
                    decoration: InputDecoration(
                      labelText: 'Assign To *',
                      prefixIcon: const Icon(
                        Icons.person_add_outlined,
                        size: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _users.map((user) {
                      return DropdownMenuItem<String>(
                        value: user.id,
                        child: Text(user.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAssignTo = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please assign to a user';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Address
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'Address *',
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Address is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _preferenceFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'Preference Details'),
            const SizedBox(height: 12),

            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project & Location Preferences',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Project
                  DropdownButtonFormField<String>(
                    value: _selectedProject,
                    decoration: InputDecoration(
                      labelText: 'Project *',
                      prefixIcon: const Icon(Icons.business_outlined, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _projects.map((project) {
                      return DropdownMenuItem<String>(
                        value: project.id,
                        child: Text(project.name),
                      );
                    }).toList(),
                    onChanged: _onProjectChanged,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Project is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category (prefilled from project)
                  DropdownButtonFormField<String>(
                    value: _selectedProjectCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon: const Icon(Icons.category_outlined, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _propertyCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category.name,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProjectCategory = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Property Type
                  DropdownButtonFormField<String>(
                    value: _selectedPropertyType,
                    decoration: InputDecoration(
                      labelText: 'Property Type *',
                      prefixIcon: const Icon(Icons.home_outlined, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _propertyTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type.name,
                        child: Text(type.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPropertyType = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Property type is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // State (prefilled from project)
                  DropdownButtonFormField<String>(
                    value: _selectedState,
                    decoration: InputDecoration(
                      labelText: 'State',
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _states.map((state) {
                      return DropdownMenuItem<String>(
                        value: state.name,
                        child: Text(state.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedState = value;
                        _selectedCity = null;
                        _selectedLocation = null;
                        _cities.clear();
                        _locations.clear();
                      });
                      if (value != null) {
                        final state = _states.firstWhere(
                          (s) => s.name == value,
                        );
                        _loadCities(state.id);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // City (prefilled from project)
                  DropdownButtonFormField<String>(
                    value: _selectedCity,
                    decoration: InputDecoration(
                      labelText: 'City',
                      prefixIcon: const Icon(
                        Icons.location_city_outlined,
                        size: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _cities.map((city) {
                      return DropdownMenuItem<String>(
                        value: city.name,
                        child: Text(city.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value;
                        _selectedLocation = null;
                        _locations.clear();
                      });
                      if (value != null) {
                        final city = _cities.firstWhere((c) => c.name == value);
                        _loadLocations(city.id);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Location (prefilled from project)
                  DropdownButtonFormField<String>(
                    value: _selectedLocation,
                    decoration: InputDecoration(
                      labelText: 'Location',
                      prefixIcon: const Icon(Icons.place_outlined, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _locations.map((location) {
                      return DropdownMenuItem<String>(
                        value: location.name,
                        child: Text(location.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLocation = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timeline & Budget',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Purchase Plan Year
                  DropdownButtonFormField<String>(
                    value: _selectedPurchaseYear,
                    decoration: InputDecoration(
                      labelText: 'Purchase Plan Year *',
                      prefixIcon: const Icon(Icons.event_outlined, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _purchaseYears.map((year) {
                      return DropdownMenuItem<String>(
                        value: year.name,
                        child: Text(year.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPurchaseYear = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Purchase plan year is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Purchase Plan Month
                  DropdownButtonFormField<String>(
                    value: _selectedPurchaseMonth,
                    decoration: InputDecoration(
                      labelText: 'Purchase Plan Month *',
                      prefixIcon: const Icon(
                        Icons.calendar_month_outlined,
                        size: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _purchaseMonths.map((month) {
                      return DropdownMenuItem<String>(
                        value: month.name,
                        child: Text(month.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPurchaseMonth = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Purchase plan month is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Budget
                  DropdownButtonFormField<String>(
                    value: _selectedBudget,
                    decoration: InputDecoration(
                      labelText: 'Budget *',
                      prefixIcon: const Icon(
                        Icons.currency_rupee_outlined,
                        size: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: _budgets.map((budget) {
                      return DropdownMenuItem<String>(
                        value: budget.name,
                        child: Text(budget.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBudget = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Budget is required';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Additional Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Remarks
                  TextFormField(
                    controller: _remarkController,
                    decoration: InputDecoration(
                      labelText: 'Remarks',
                      prefixIcon: const Icon(Icons.note_outlined, size: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
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
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
