import 'package:flutter/material.dart';
import '../../../../data/services/database_service.dart';
import '../../../../data/services/master_data_service.dart';
import '../../../../data/models/models.dart';


class CreatePropertyOptionScreen extends StatefulWidget {
  const CreatePropertyOptionScreen({super.key});
  @override
  State<CreatePropertyOptionScreen> createState() =>
      _CreatePropertyOptionScreenState();
}

class _CreatePropertyOptionScreenState
    extends State<CreatePropertyOptionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String optionType = '';
  String projectName = '';
  String category = '';
  String propertyType = '';
  String stateValue = '';
  String cityValue = '';
  String location = '';
  final TextEditingController _descCtrl = TextEditingController();
  final Set<String> _selectedProjectIds = <String>{};

  // Data lists for dropdowns
  List<OptionType> _optionTypes = <OptionType>[];
  List<Project> _projectNames = <Project>[];
  List<PropertyCategory> _categories = <PropertyCategory>[];
  List<PropertyTypeMaster> _propertyTypes = <PropertyTypeMaster>[];
  List<StateMaster> _states = <StateMaster>[];
  List<City> _cities = <City>[];
  List<Location> _locations = <Location>[];
  List<InventoryType> _inventories = <InventoryType>[];

  // Loading states
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Load all data in parallel
      final results = await Future.wait([
        MasterDataService.getOptionTypes(),
        DatabaseService.getProjects(limit: 50),
        MasterDataService.getPropertyCategories(),
        MasterDataService.getPropertyTypesMaster(),
        MasterDataService.getStates(),
        MasterDataService.getInventoryTypes(),
      ]);

      setState(() {
        _optionTypes = results[0] as List<OptionType>;
        _projectNames = results[1] as List<Project>;
        _categories = results[2] as List<PropertyCategory>;
        _propertyTypes = results[3] as List<PropertyTypeMaster>;
        _states = results[4] as List<StateMaster>;
        _inventories = results[5] as List<InventoryType>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error - could show a snackbar or error message
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  Future<void> _loadCities(String stateId) async {
    try {
      final cities = await MasterDataService.getCities(stateId: stateId);
      setState(() {
        _cities = cities;
        cityValue = ''; // Reset city when state changesanalyze 
        location = ''; // Reset location when state changes
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading cities: $e')));
      }
    }
  }

  Future<void> _loadLocations(String cityId) async {
    try {
      final locations = await MasterDataService.getLocations(cityId: cityId);
      setState(() {
        _locations = locations;
        location = ''; // Reset location when city changes
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading locations: $e')));
      }
    }
  }

  void _clear() {
    setState(() {
      optionType = projectName = category = propertyType = stateValue =
          cityValue = location = '';
      _descCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Create Property Option')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create Property Option')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: <BoxShadow>[
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
                  children: <Widget>[
                    _label('Option Type *'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: optionType.isEmpty ? null : optionType,
                      items: _optionTypes
                          .map(
                            (OptionType e) => DropdownMenuItem<String>(
                              value: e.name,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                      onChanged: (String? v) =>
                          setState(() => optionType = v ?? optionType),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select',
                      ),
                      validator: (String? v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _label('Project Name *'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: projectName.isEmpty ? null : projectName,
                      items: _projectNames
                          .map(
                            (Project e) => DropdownMenuItem<String>(
                              value: e.name,
                              child: Text(
                                e.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (String? v) =>
                          setState(() => projectName = v ?? projectName),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select',
                      ),
                      validator: (String? v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    _label('Category'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: category.isEmpty ? null : category,
                      items: _categories
                          .map(
                            (PropertyCategory e) => DropdownMenuItem<String>(
                              value: e.name,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                      onChanged: (String? v) =>
                          setState(() => category = v ?? category),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _label('Property Type'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: propertyType.isEmpty ? null : propertyType,
                      items: _propertyTypes
                          .map(
                            (PropertyTypeMaster e) => DropdownMenuItem<String>(
                              value: e.name,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                      onChanged: (String? v) =>
                          setState(() => propertyType = v ?? propertyType),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _label('State'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: stateValue.isEmpty
                                    ? null
                                    : stateValue,
                                items: _states
                                    .map(
                                      (StateMaster e) =>
                                          DropdownMenuItem<String>(
                                            value: e.name,
                                            child: Text(
                                              e.name,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                    )
                                    .toList(),
                                onChanged: (String? v) {
                                  setState(() {
                                    stateValue = v ?? stateValue;
                                    cityValue = ''; // Reset city
                                    location = ''; // Reset location
                                    _cities.clear(); // Clear cities list
                                    _locations.clear(); // Clear locations list
                                  });
                                  if (v != null) {
                                    // Find the selected state and load its cities
                                    final selectedState = _states.firstWhere(
                                      (state) => state.name == v,
                                    );
                                    _loadCities(selectedState.id);
                                  }
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Select',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _label('City'),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: cityValue.isEmpty
                                    ? null
                                    : cityValue,
                                items: _cities
                                    .map(
                                      (City e) => DropdownMenuItem<String>(
                                        value: e.name,
                                        child: Text(
                                          e.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (String? v) {
                                  setState(() {
                                    cityValue = v ?? cityValue;
                                    location = ''; // Reset location
                                    _locations.clear(); // Clear locations list
                                  });
                                  if (v != null) {
                                    // Find the selected city and load its locations
                                    final selectedCity = _cities.firstWhere(
                                      (city) => city.name == v,
                                    );
                                    _loadLocations(selectedCity.id);
                                  }
                                },
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Select',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _label('Location'),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: location.isEmpty ? null : location,
                      items: _locations
                          .map(
                            (Location e) => DropdownMenuItem<String>(
                              value: e.name,
                              child: Text(
                                e.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (String? v) =>
                          setState(() => location = v ?? location),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Select',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 16),
                    Row(
                      children: <Widget>[
                        OutlinedButton(
                          onPressed: _clear,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Projects list card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: <BoxShadow>[
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
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.list_alt,
                          size: 18,
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Projects',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(height: 220, child: _buildProjectsList()),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Inventories list card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: <BoxShadow>[
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
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.list_alt,
                          size: 18,
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Inventories',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(height: 220, child: _buildInventoriesList()),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Save button
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () {
                    if (!(_formKey.currentState?.validate() ?? false)) return;
                    final Map<String, String> payload = <String, String>{
                      'optionType': optionType,
                      'projectName': projectName,
                      'category': category,
                      'propertyType': propertyType,
                      'state': stateValue,
                      'city': cityValue,
                      'location': location,
                    };
                    Navigator.of(context).pop(payload);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String t) => Text(
    t,
    style: Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
  );

  Widget _buildProjectsList() {
    // Use fetched projects from database
    final List<Project> items = _projectNames;
    final ScrollController scrollController = ScrollController();

    return Scrollbar(
      controller: scrollController,
      child: ListView.separated(
        controller: scrollController,
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (BuildContext context, int i) {
          final Project p = items[i];
          final bool checked = _selectedProjectIds.contains(p.id);
          final String typeText =
              p.type.toString().split('.').last[0].toUpperCase() +
              p.type.toString().split('.').last.substring(1);
          final String startText =
              p.startingPrice != null && p.startingPrice! > 0
              ? '₹ ${p.startingPrice!.toStringAsFixed(0)} / ${p.priceUnit ?? ''}'
                    .trim()
              : '-';
          final String locationText = <String?>[
            p.address,
            p.city,
            p.state,
          ].where((String? s) => (s ?? '').isNotEmpty).join(', ');

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(
                value: checked,
                onChanged: (bool? v) {
                  setState(() {
                    if (v == true) {
                      _selectedProjectIds.add(p.id);
                    } else {
                      _selectedProjectIds.remove(p.id);
                    }
                  });
                },
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: <Widget>[
                        Text(
                          p.name,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text('/', style: Theme.of(context).textTheme.bodySmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Text(
                            typeText,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: <TextSpan>[
                          const TextSpan(
                            text: 'Starting From : ',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: startText,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: <TextSpan>[
                          const TextSpan(
                            text: 'Location : ',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: locationText.isEmpty ? '-' : locationText,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInventoriesList() {
    if (_inventories.isEmpty) {
      return const Center(child: Text('No inventories available'));
    }

    final ScrollController scrollController = ScrollController();
    return Scrollbar(
      controller: scrollController,
      child: ListView.separated(
        controller: scrollController,
        itemCount: _inventories.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (BuildContext context, int i) {
          final InventoryType inventory = _inventories[i];

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Checkbox(
                value: false, // You can add inventory selection logic here
                onChanged: (bool? v) {
                  // Handle inventory selection
                },
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      inventory.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Type: ${inventory.name}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: <TextSpan>[
                          const TextSpan(
                            text: 'Status : ',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: inventory.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: inventory.isActive
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
