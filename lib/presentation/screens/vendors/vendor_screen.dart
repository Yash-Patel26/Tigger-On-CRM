import 'package:flutter/material.dart';
import 'vendor_profile_screen.dart';
import '../../../../data/models/vendor_model.dart';
import '../../../../data/services/vendor_service.dart';
import '../../../../data/services/supabase_service.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _statusFilter = 0; // 0=All,1=Active,2=Inactive

  List<VendorModel> _vendors = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final vendors = await VendorService.getAllVendors();
      setState(() {
        _vendors = vendors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshVendors() async {
    await _loadVendors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading vendors',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshVendors,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final int total = _vendors.length;
    final int active = _vendors.where((v) => v.isActive).length;
    final int inactive = total - active;

    final String query = _searchController.text.trim().toLowerCase();
    final List<VendorModel> filtered = _vendors.where((VendorModel v) {
      final bool matchesQuery =
          query.isEmpty ||
          v.name.toLowerCase().contains(query) ||
          (v.website?.toLowerCase().contains(query) ?? false) ||
          v.city.toLowerCase().contains(query);
      final bool matchesStatus =
          _statusFilter == 0 ||
          (_statusFilter == 1 && v.isActive) ||
          (_statusFilter == 2 && !v.isActive);
      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _MetricCard(
                      label: 'Active',
                      value: active.toString(),
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      label: 'Inactive',
                      value: inactive.toString(),
                      icon: Icons.pause_circle_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SearchAndFilters(
                controller: _searchController,
                statusFilter: _statusFilter,
                onChanged: () => setState(() {}),
                onFilterChanged: (int v) => setState(() => _statusFilter = v),
                onAddVendor: _startDeveloperWizard,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshVendors,
                  child: _VendorList(vendors: filtered),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startDeveloperWizard() async {
    final VendorModel? newVendor = await _showCreateVendorWizard(context);
    if (newVendor == null) return;
    setState(() => _vendors = [newVendor, ..._vendors]);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${newVendor.name} created')));
  }
}

class _VendorList extends StatelessWidget {
  const _VendorList({required this.vendors});

  final List<VendorModel> vendors;

  @override
  Widget build(BuildContext context) {
    if (vendors.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No vendors found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first vendor to get started',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: vendors.length,
      separatorBuilder: (BuildContext context, int index) =>
          Divider(color: _panelBorderColor(context)),
      itemBuilder: (BuildContext context, int index) {
        final VendorModel vendor = vendors[index];
        return _VendorCard(vendor: vendor);
      },
    );
  }
}

class _VendorCard extends StatelessWidget {
  const _VendorCard({required this.vendor});

  final VendorModel vendor;

  String _monthName(int month) {
    const List<String> names = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month < 1 || month > 12) return '';
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final String vendorId = vendor.id;
    final String contactNumber = 'N/A'; // Will be loaded from contacts
    final String createdBy = vendor.createdByName;
    final DateTime createdDate = vendor.createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // Header with vendor name and status
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vendor.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${vendorId.substring(0, 8)}...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(isActive: vendor.isActive),
            ],
          ),
          const SizedBox(height: 12),

          // Contact and Type row
          Row(
            children: [
              Expanded(
                child: _VendorDetailRow(
                  icon: Icons.phone,
                  label: 'Contact',
                  value: contactNumber,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _VendorDetailRow(
                  icon: Icons.business,
                  label: 'Type',
                  value: vendor.companyType,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Created by and date row
          Row(
            children: [
              Expanded(
                child: _VendorDetailRow(
                  icon: Icons.person,
                  label: 'Created By',
                  value: createdBy,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _VendorDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Date & Time',
                  value:
                      '${createdDate.day}/${createdDate.month}/${createdDate.year} ${createdDate.hour}:${createdDate.minute.toString().padLeft(2, '0')}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext ctx) => VendorProfileScreen(
                          vendorId: vendorId,
                          name: vendor.name,
                          contactNumber: contactNumber,
                          email: 'N/A', // Will be loaded from contacts
                          type: vendor.companyType,
                          commenceDate:
                              '${createdDate.day}-${_monthName(createdDate.month)}-${createdDate.year}',
                          country: vendor.country,
                          state: vendor.state,
                          city: vendor.city,
                          aadhar: vendor.aadhar ?? '-',
                          address: vendor.address,
                          pincode: vendor.pincode,
                          companyName: vendor.name,
                          contactName: 'N/A', // Will be loaded from contacts
                          panCard: vendor.pan,
                          orgContactNumber: contactNumber,
                          gstin: vendor.gstin,
                          contactEmail: 'N/A', // Will be loaded from contacts
                          designation: 'N/A', // Will be loaded from contacts
                          services: const <String>['Consulting', 'Support'],
                          bankCategory: 'Business',
                          bankName: 'N/A', // Will be loaded from bank details
                          accountType: 'Current',
                          ifscCode: 'N/A', // Will be loaded from bank details
                          branchName: 'N/A', // Will be loaded from bank details
                          accountHolderName: vendor.name,
                          accountNumber:
                              'N/A', // Will be loaded from bank details
                          isActive: vendor.isActive,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    // TODO: Implement edit vendor
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VendorDetailRow extends StatelessWidget {
  const _VendorDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<VendorModel?> _showCreateVendorWizard(BuildContext context) async {
  return showModalBottomSheet<VendorModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext ctx) {
      return _VendorWizard();
    },
  );
}

class _VendorWizard extends StatefulWidget {
  @override
  State<_VendorWizard> createState() => _VendorWizardState();
}

class _VendorWizardState extends State<_VendorWizard> {
  int _step = 0;

  // Step 1
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController websiteCtrl = TextEditingController();
  final TextEditingController logoCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController stateCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController cityCtrl = TextEditingController();
  final TextEditingController pincodeCtrl = TextEditingController();

  // Step 2 - contacts
  final List<Map<String, String>> contacts = <Map<String, String>>[];
  final TextEditingController cName = TextEditingController();
  final TextEditingController cMobile = TextEditingController();
  final TextEditingController cDesignation = TextEditingController();
  final TextEditingController cEmail = TextEditingController();

  // Step 3
  String companyType = 'Pvt Ltd';
  bool reraYes = true;
  final TextEditingController gstinCtrl = TextEditingController();
  final TextEditingController gstinFileCtrl = TextEditingController();
  final TextEditingController panCtrl = TextEditingController();
  final TextEditingController panFileCtrl = TextEditingController();
  bool isActive = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'Create Vendor',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Stepper(
              currentStep: _step,
              controlsBuilder: (BuildContext context, ControlsDetails d) {
                return Row(
                  children: <Widget>[
                    FilledButton(
                      onPressed: () async {
                        if (_step < 2) {
                          setState(() => _step += 1);
                        } else {
                          try {
                            // Get current user info
                            final currentUser = SupabaseService.currentUser;
                            if (currentUser == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('User not authenticated'),
                                ),
                              );
                              return;
                            }

                            final vendor = await VendorService.createVendor(
                              name: nameCtrl.text.trim(),
                              website: websiteCtrl.text.trim().isEmpty
                                  ? null
                                  : websiteCtrl.text.trim(),
                              logoUrl: logoCtrl.text.trim().isEmpty
                                  ? null
                                  : logoCtrl.text.trim(),
                              address: addressCtrl.text.trim(),
                              state: stateCtrl.text.trim(),
                              district: districtCtrl.text.trim(),
                              city: cityCtrl.text.trim(),
                              pincode: pincodeCtrl.text.trim(),
                              companyType: companyType,
                              isReraRegistered: reraYes,
                              gstin: gstinCtrl.text.trim(),
                              gstinFilePath: gstinFileCtrl.text.trim().isEmpty
                                  ? null
                                  : gstinFileCtrl.text.trim(),
                              pan: panCtrl.text.trim(),
                              panFilePath: panFileCtrl.text.trim().isEmpty
                                  ? null
                                  : panFileCtrl.text.trim(),
                              isActive: isActive,
                              createdBy: currentUser.id,
                              createdByName: currentUser.email ?? 'Unknown',
                            );

                            // Create contacts if any
                            for (final contact in contacts) {
                              await VendorService.createVendorContact(
                                vendorId: vendor.id,
                                name: contact['name']!,
                                mobile: contact['mobile']!,
                                designation: contact['designation']!,
                                email: contact['email']!,
                              );
                            }

                            Navigator.of(context).pop(vendor);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error creating vendor: $e'),
                              ),
                            );
                          }
                        }
                      },
                      child: Text(_step < 2 ? 'Next' : 'Create'),
                    ),
                    const SizedBox(width: 8),
                    if (_step > 0)
                      OutlinedButton(
                        onPressed: () => setState(() => _step -= 1),
                        child: const Text('Back'),
                      ),
                  ],
                );
              },
              steps: <Step>[
                Step(
                  title: const Text('Basic Details'),
                  isActive: _step >= 0,
                  content: Column(
                    children: <Widget>[
                      _tf(nameCtrl, 'Name'),
                      _tf(websiteCtrl, 'Website', keyboard: TextInputType.url),
                      _tf(logoCtrl, 'Vendor Logo URL'),
                      _tf(addressCtrl, 'Address'),
                      _tf(stateCtrl, 'State'),
                      _tf(districtCtrl, 'District'),
                      _tf(cityCtrl, 'City'),
                      _tf(
                        pincodeCtrl,
                        'Pincode',
                        keyboard: TextInputType.number,
                      ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Contacts'),
                  isActive: _step >= 1,
                  content: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(child: _tf(cName, 'Name')),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _tf(
                              cMobile,
                              'Mobile No',
                              keyboard: TextInputType.phone,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          Expanded(child: _tf(cDesignation, 'Designation')),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _tf(
                              cEmail,
                              'Email',
                              keyboard: TextInputType.emailAddress,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            if (cName.text.trim().isEmpty) return;
                            setState(() {
                              contacts.add({
                                'name': cName.text.trim(),
                                'mobile': cMobile.text.trim(),
                                'designation': cDesignation.text.trim(),
                                'email': cEmail.text.trim(),
                              });
                              cName.clear();
                              cMobile.clear();
                              cDesignation.clear();
                              cEmail.clear();
                            });
                          },
                          icon: const Icon(Icons.person_add_alt_1),
                          label: const Text('Add Contact'),
                        ),
                      ),
                      if (contacts.isNotEmpty)
                        Container(
                          decoration: BoxDecoration(
                            color: _panelColor(context),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _panelBorderColor(context),
                            ),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (BuildContext context, int index) {
                              final contact = contacts[index];
                              return ListTile(
                                dense: true,
                                title: Text(contact['name']!),
                                subtitle: Text(
                                  '${contact['designation']} • ${contact['mobile']} • ${contact['email']}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () =>
                                      setState(() => contacts.removeAt(index)),
                                ),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                Divider(color: _panelBorderColor(context)),
                            itemCount: contacts.length,
                          ),
                        ),
                    ],
                  ),
                ),
                Step(
                  title: const Text('Compliance'),
                  isActive: _step >= 2,
                  content: Column(
                    children: <Widget>[
                      DropdownButtonFormField<String>(
                        initialValue: companyType,
                        decoration: const InputDecoration(
                          labelText: 'Company Type',
                        ),
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem(
                            value: 'Pvt Ltd',
                            child: Text('Pvt Ltd'),
                          ),
                          DropdownMenuItem(value: 'LLP', child: Text('LLP')),
                          DropdownMenuItem(
                            value: 'Partnership',
                            child: Text('Partnership'),
                          ),
                          DropdownMenuItem(
                            value: 'Proprietorship',
                            child: Text('Proprietorship'),
                          ),
                        ],
                        onChanged: (String? v) =>
                            setState(() => companyType = v ?? companyType),
                      ),
                      SwitchListTile(
                        value: reraYes,
                        onChanged: (bool v) => setState(() => reraYes = v),
                        title: const Text('RERA Registered'),
                      ),
                      _tf(gstinCtrl, 'GSTIN No'),
                      _tf(gstinFileCtrl, 'GSTIN File URL'),
                      _tf(panCtrl, 'PAN Card No'),
                      _tf(panFileCtrl, 'PAN File URL'),
                      SwitchListTile(
                        value: isActive,
                        onChanged: (bool v) => setState(() => isActive = v),
                        title: const Text('Active'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tf(TextEditingController c, String label, {TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.controller,
    required this.statusFilter,
    required this.onChanged,
    required this.onFilterChanged,
    required this.onAddVendor,
  });

  final TextEditingController controller;
  final int statusFilter;
  final VoidCallback onChanged;
  final ValueChanged<int> onFilterChanged;
  final VoidCallback onAddVendor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            hintText: 'Search by name, ID, phone or type',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: _panelColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _panelBorderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _panelBorderColor(context)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: Wrap(
                spacing: 8,
                children: <Widget>[
                  ChoiceChip(
                    label: const Text('All'),
                    selected: statusFilter == 0,
                    onSelected: (_) => onFilterChanged(0),
                  ),
                  ChoiceChip(
                    label: const Text('Active'),
                    selected: statusFilter == 1,
                    onSelected: (_) => onFilterChanged(1),
                  ),
                  ChoiceChip(
                    label: const Text('Inactive'),
                    selected: statusFilter == 2,
                    onSelected: (_) => onFilterChanged(2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: onAddVendor,
              icon: const Icon(Icons.add_business),
              tooltip: 'Add',
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? Colors.green : Colors.redAccent;
    final String label = isActive ? 'Active' : 'Inactive';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

Color _panelColor(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? Colors.white.withOpacity(0.06)
      : Colors.black.withOpacity(0.04);
}

Color _panelBorderColor(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? Colors.white.withOpacity(0.12) : const Color(0x22000000);
}
