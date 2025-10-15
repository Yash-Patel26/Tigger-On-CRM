import 'package:flutter/material.dart';
// import '../utils/page_transitions.dart';
import 'vendor_profile_screen.dart';
// import 'vendor_edit_screen.dart';
// import 'vendor_basic_details_screen.dart';

class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _statusFilter = 0; // 0=All,1=Active,2=Inactive

  late List<Developer> _developers;

  @override
  void initState() {
    super.initState();
    _developers = _initialDevelopers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Developer> developers = _developers;
    final int total = developers.length;
    final int active = developers.where((Developer d) => d.isActive).length;
    final int inactive = total - active;

    final String query = _searchController.text.trim().toLowerCase();
    final List<Developer> filtered = developers.where((Developer d) {
      final bool matchesQuery =
          query.isEmpty ||
          d.name.toLowerCase().contains(query) ||
          (d.website?.toLowerCase().contains(query) ?? false) ||
          d.city.toLowerCase().contains(query);
      final bool matchesStatus =
          _statusFilter == 0 ||
          (_statusFilter == 1 && d.isActive) ||
          (_statusFilter == 2 && !d.isActive);
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
              Expanded(child: _DeveloperList(developers: filtered)),
            ],
          ),
        ),
      ),
    );
  }

  List<Developer> _initialDevelopers() {
    return <Developer>[
      const Developer(
        name: 'Skyline Builders',
        website: 'https://skyline.example',
        logoUrl: null,
        address: 'Sector 21',
        state: 'Maharashtra',
        district: 'Mumbai Suburban',
        city: 'Mumbai',
        pincode: '400053',
        contacts: <DevContact>[
          DevContact(
            name: 'Amit Shah',
            mobile: '+91 98765 11111',
            designation: 'Director',
            email: 'amit@skyline.com',
          ),
        ],
        companyType: 'Pvt Ltd',
        isReraRegistered: true,
        gstin: '27ABCDE1234F1Z5',
        gstinFilePath: null,
        pan: 'ABCDE1234F',
        panFilePath: null,
        isActive: true,
      ),
      const Developer(
        name: 'GreenHomes',
        website: 'https://greenhomes.example',
        logoUrl: null,
        address: 'MG Road',
        state: 'Karnataka',
        district: 'Bengaluru Urban',
        city: 'Bengaluru',
        pincode: '560001',
        contacts: <DevContact>[
          DevContact(
            name: 'Priya Iyer',
            mobile: '+91 98765 22222',
            designation: 'Sales Head',
            email: 'priya@greenhomes.com',
          ),
        ],
        companyType: 'LLP',
        isReraRegistered: false,
        gstin: '',
        gstinFilePath: null,
        pan: 'PQRSX6789Z',
        panFilePath: null,
        isActive: false,
      ),
    ];
  }

  Future<void> _startDeveloperWizard() async {
    final Developer? newDev = await _showCreateDeveloperWizard(context);
    if (newDev == null) return;
    setState(() => _developers = <Developer>[newDev, ..._developers]);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${newDev.name} created')));
  }

  // String _todayString() { // unused helper retained for potential reuse
  //   final DateTime now = DateTime.now();
  //   const List<String> months = <String>[
  //     'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  //     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  //   ];
  //   return '${now.day.toString().padLeft(2, '0')} ${months[now.month - 1]} ${now.year}';
  // }
}

class _DeveloperList extends StatelessWidget {
  const _DeveloperList({required this.developers});

  final List<Developer> developers;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: developers.length,
      separatorBuilder: (BuildContext context, int index) =>
          Divider(color: _panelBorderColor(context)),
      itemBuilder: (BuildContext context, int index) {
        final Developer d = developers[index];
        return _VendorCard(vendor: d);
      },
    );
  }
}

class _VendorCard extends StatelessWidget {
  const _VendorCard({required this.vendor});

  final Developer vendor;

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
    // Generate a vendor ID based on name or use a pattern
    final String vendorId =
        'VEN-${vendor.name.substring(0, 3).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    final String contactNumber = vendor.contacts.isNotEmpty
        ? vendor.contacts.first.mobile
        : 'N/A';
    final String createdBy = 'Admin'; // Mock data
    final DateTime createdDate = DateTime.now().subtract(
      Duration(days: vendor.name.length % 30),
    );

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
                      'ID: $vendorId',
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
                    final String vendorId =
                        'VEN-${vendor.name.substring(0, 3).toUpperCase()}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
                    final String contactNumber = vendor.contacts.isNotEmpty
                        ? vendor.contacts.first.mobile
                        : 'N/A';
                    final String email = vendor.contacts.isNotEmpty
                        ? vendor.contacts.first.email
                        : 'N/A';
                    final String commenceDate =
                        '${DateTime.now().day}-${_monthName(DateTime.now().month)}-${DateTime.now().year} ${TimeOfDay.now().format(context)}';
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (BuildContext ctx) => VendorProfileScreen(
                          vendorId: vendorId,
                          name: vendor.name,
                          contactNumber: contactNumber,
                          email: email,
                          type: vendor.companyType,
                          commenceDate: commenceDate,
                          country: 'India',
                          state: vendor.state,
                          city: vendor.city,
                          aadhar: '-',
                          address: vendor.address,
                          pincode: vendor.pincode,
                          companyName: vendor.name,
                          contactName: vendor.contacts.isNotEmpty
                              ? vendor.contacts.first.name
                              : 'N/A',
                          panCard: vendor.pan,
                          orgContactNumber: contactNumber,
                          gstin: vendor.gstin,
                          contactEmail: email,
                          designation: vendor.contacts.isNotEmpty
                              ? vendor.contacts.first.designation
                              : 'N/A',
                          services: const <String>['Consulting', 'Support'],
                          bankCategory: 'Business',
                          bankName: 'HDFC Bank',
                          accountType: 'Current',
                          ifscCode: 'HDFC0000123',
                          branchName: 'Andheri West',
                          accountHolderName: vendor.name,
                          accountNumber: '123456789012',
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

class Developer {
  const Developer({
    required this.name,
    this.website,
    this.logoUrl,
    required this.address,
    required this.state,
    required this.district,
    required this.city,
    required this.pincode,
    required this.contacts,
    required this.companyType,
    required this.isReraRegistered,
    required this.gstin,
    this.gstinFilePath,
    required this.pan,
    this.panFilePath,
    required this.isActive,
  });

  final String name;
  final String? website;
  final String? logoUrl;
  final String address;
  final String state;
  final String district;
  final String city;
  final String pincode;
  final List<DevContact> contacts;
  final String companyType;
  final bool isReraRegistered;
  final String gstin;
  final String? gstinFilePath;
  final String pan;
  final String? panFilePath;
  final bool isActive;
}

class DevContact {
  const DevContact({
    required this.name,
    required this.mobile,
    required this.designation,
    required this.email,
  });

  final String name;
  final String mobile;
  final String designation;
  final String email;
}

Future<Developer?> _showCreateDeveloperWizard(BuildContext context) async {
  return showModalBottomSheet<Developer>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext ctx) {
      return _DeveloperWizard();
    },
  );
}

class _DeveloperWizard extends StatefulWidget {
  @override
  State<_DeveloperWizard> createState() => _DeveloperWizardState();
}

class _DeveloperWizardState extends State<_DeveloperWizard> {
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
  final List<DevContact> contacts = <DevContact>[];
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
                      onPressed: () {
                        if (_step < 2) {
                          setState(() => _step += 1);
                        } else {
                          final Developer dev = Developer(
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
                            contacts: contacts,
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
                          );
                          Navigator.of(context).pop(dev);
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
                              contacts.add(
                                DevContact(
                                  name: cName.text.trim(),
                                  mobile: cMobile.text.trim(),
                                  designation: cDesignation.text.trim(),
                                  email: cEmail.text.trim(),
                                ),
                              );
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
                              final DevContact c = contacts[index];
                              return ListTile(
                                dense: true,
                                title: Text(c.name),
                                subtitle: Text(
                                  '${c.designation} • ${c.mobile} • ${c.email}',
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

class Vendor {
  const Vendor({
    required this.vendorId,
    required this.name,
    required this.contactNumber,
    required this.email,
    required this.type,
    required this.createdBy,
    required this.commenceDate,
    required this.country,
    required this.state,
    required this.city,
    required this.aadhar,
    required this.address,
    required this.pincode,
    required this.companyName,
    required this.contactName,
    required this.panCard,
    required this.orgContactNumber,
    required this.gstin,
    required this.contactEmail,
    required this.designation,
    required this.services,
    required this.bankCategory,
    required this.bankName,
    required this.accountType,
    required this.ifscCode,
    required this.branchName,
    required this.accountHolderName,
    required this.accountNumber,
    required this.isActive,
  });

  final String vendorId;
  final String name;
  final String contactNumber;
  final String email;
  final String type;
  final String createdBy;
  final String commenceDate;
  final String country;
  final String state;
  final String city;
  final String aadhar;
  final String address;
  final String pincode;
  final String companyName;
  final String contactName;
  final String panCard;
  final String orgContactNumber;
  final String gstin;
  final String contactEmail;
  final String designation;
  final List<String> services;
  final String bankCategory;
  final String bankName;
  final String accountType;
  final String ifscCode;
  final String branchName;
  final String accountHolderName;
  final String accountNumber;
  final bool isActive;
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
