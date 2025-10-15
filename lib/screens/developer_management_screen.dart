import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DeveloperManagementScreen extends StatefulWidget {
  const DeveloperManagementScreen({super.key});

  @override
  State<DeveloperManagementScreen> createState() =>
      _DeveloperManagementScreenState();
}

class _DeveloperManagementScreenState extends State<DeveloperManagementScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Step 1 - Basic Details
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  String? _logoPath;

  // Step 2 - Contacts
  final List<DevContact> _contacts = [];
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactMobileController =
      TextEditingController();
  final TextEditingController _contactDesignationController =
      TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();

  // Step 3 - Compliance
  String _companyType = 'Pvt Ltd';
  bool _isReraRegistered = false;
  final TextEditingController _reraNumberController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  String? _gstinFilePath;
  final TextEditingController _panController = TextEditingController();
  String? _panFilePath;

  // Step 4 - Bank Details
  String _bankCategory = 'Savings';
  final TextEditingController _bankNameController = TextEditingController();
  String _accountType = 'Current';
  final TextEditingController _ifscCodeController = TextEditingController();
  final TextEditingController _branchNameController = TextEditingController();
  final TextEditingController _accountHolderNameController =
      TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _contactNameController.dispose();
    _contactMobileController.dispose();
    _contactDesignationController.dispose();
    _contactEmailController.dispose();
    _reraNumberController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _bankNameController.dispose();
    _ifscCodeController.dispose();
    _branchNameController.dispose();
    _accountHolderNameController.dispose();
    _accountNumberController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Developer'), elevation: 0),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Basic Details'),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep > 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                  ),
                ),
                _buildStepIndicator(1, 'Contacts'),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep > 1
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                  ),
                ),
                _buildStepIndicator(2, 'Compliance'),
                Expanded(
                  child: Container(
                    height: 2,
                    color: _currentStep > 2
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                  ),
                ),
                _buildStepIndicator(3, 'Bank Details'),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() {
                  _currentStep = page;
                });
              },
              children: [
                _buildBasicDetailsStep(),
                _buildContactsStep(),
                _buildComplianceStep(),
                _buildBankDetailsStep(),
              ],
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousStep,
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _currentStep < 3 ? _nextStep : _createDeveloper,
                    child: Text(_currentStep < 3 ? 'Next' : 'Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title) {
    final bool isActive = _currentStep >= step;
    final bool isCompleted = _currentStep > step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive || isCompleted
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: _nameController,
            label: 'Developer Name',
            hint: 'Enter developer name',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _websiteController,
            label: 'Website',
            hint: 'https://example.com',
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          _buildFileUploadField(
            label: 'Developer Logo',
            filePath: _logoPath,
            onTap: _pickLogoFile,
            icon: Icons.image,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _addressController,
            label: 'Address',
            hint: 'Enter complete address',
            isRequired: true,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  label: 'State',
                  hint: 'Enter state',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _districtController,
                  label: 'District',
                  hint: 'Enter district',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  hint: 'Enter city',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _pincodeController,
                  label: 'Pincode',
                  hint: 'Enter pincode',
                  keyboardType: TextInputType.number,
                  isRequired: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Text(
            'Add Contact Person',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _contactNameController,
                  label: 'Name',
                  hint: 'Enter contact name',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _contactMobileController,
                  label: 'Mobile Number',
                  hint: 'Enter mobile number',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _contactDesignationController,
                  label: 'Designation',
                  hint: 'Enter designation',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _contactEmailController,
                  label: 'Email ID',
                  hint: 'Enter email address',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _addContact,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Contact'),
            ),
          ),
          const SizedBox(height: 24),
          if (_contacts.isNotEmpty) ...[
            Text(
              'Added Contacts',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: _panelColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _panelBorderColor(context)),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _contacts.length,
                separatorBuilder: (context, index) =>
                    Divider(color: _panelBorderColor(context), height: 1),
                itemBuilder: (context, index) {
                  final contact = _contacts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(contact.name),
                    subtitle: Text(
                      '${contact.designation} • ${contact.mobile}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _removeContact(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComplianceStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Compliance Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          _buildDropdownField(
            label: 'Company Type',
            value: _companyType,
            items: const ['Pvt Ltd', 'LLP', 'Partnership', 'Proprietorship'],
            onChanged: (value) => setState(() => _companyType = value!),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('RERA Registered'),
            subtitle: const Text('Is the developer RERA registered?'),
            value: _isReraRegistered,
            onChanged: (value) => setState(() => _isReraRegistered = value),
          ),
          if (_isReraRegistered) ...[
            const SizedBox(height: 16),
            _buildTextField(
              controller: _reraNumberController,
              label: 'RERA Number',
              hint: 'Enter RERA registration number',
              isRequired: true,
            ),
          ],
          const SizedBox(height: 16),
          _buildTextField(
            controller: _gstinController,
            label: 'GSTIN Number',
            hint: 'Enter GSTIN number',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildFileUploadField(
            label: 'GSTIN File',
            filePath: _gstinFilePath,
            onTap: _pickGstinFile,
            icon: Icons.description,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _panController,
            label: 'PAN Card Number',
            hint: 'Enter PAN card number',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildFileUploadField(
            label: 'PAN Card File',
            filePath: _panFilePath,
            onTap: _pickPanFile,
            icon: Icons.description,
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank Details',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          _buildDropdownField(
            label: 'Bank Category',
            value: _bankCategory,
            items: const [
              'Savings',
              'Current',
              'Fixed Deposit',
              'Recurring Deposit',
            ],
            onChanged: (value) => setState(() => _bankCategory = value!),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _bankNameController,
            label: 'Bank Name',
            hint: 'Enter bank name',
          ),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Account Type',
            value: _accountType,
            items: const [
              'Current',
              'Savings',
              'Fixed Deposit',
              'Recurring Deposit',
            ],
            onChanged: (value) => setState(() => _accountType = value!),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _ifscCodeController,
            label: 'IFSC Code',
            hint: 'Enter IFSC code',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _branchNameController,
            label: 'Branch Name',
            hint: 'Enter branch name',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _accountHolderNameController,
            label: 'Account Holder Name',
            hint: 'Enter account holder name',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _accountNumberController,
            label: 'Account Number',
            hint: 'Enter account number',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            children: isRequired
                ? [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: _panelColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: _panelColor(context),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(value: item, child: Text(item));
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildFileUploadField({
    required String label,
    String? filePath,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _panelColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _panelBorderColor(context),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    filePath != null
                        ? filePath.split('/').last
                        : 'Tap to select file',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: filePath != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                Icon(
                  Icons.upload_file,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _validateCurrentStep() {
    // Validation removed - allow proceeding without validation
    return true;
  }

  void _addContact() {
    // Validation removed - allow adding contact without validation
    setState(() {
      _contacts.add(
        DevContact(
          name: _contactNameController.text.trim(),
          mobile: _contactMobileController.text.trim(),
          designation: _contactDesignationController.text.trim(),
          email: _contactEmailController.text.trim(),
        ),
      );
      _contactNameController.clear();
      _contactMobileController.clear();
      _contactDesignationController.clear();
      _contactEmailController.clear();
    });
  }

  void _removeContact(int index) {
    setState(() {
      _contacts.removeAt(index);
    });
  }

  Future<void> _pickLogoFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _logoPath = result.files.first.path;
      });
    }
  }

  Future<void> _pickGstinFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _gstinFilePath = result.files.first.path;
      });
    }
  }

  Future<void> _pickPanFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _panFilePath = result.files.first.path;
      });
    }
  }

  void _createDeveloper() {
    if (!_validateCurrentStep()) return;

    // Create developer object
    final developer = Developer(
      name: _nameController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      logoUrl: _logoPath,
      address: _addressController.text.trim(),
      state: _stateController.text.trim(),
      district: _districtController.text.trim(),
      city: _cityController.text.trim(),
      pincode: _pincodeController.text.trim(),
      contacts: _contacts,
      companyType: _companyType,
      isReraRegistered: _isReraRegistered,
      reraNumber: _reraNumberController.text.trim(),
      gstin: _gstinController.text.trim(),
      gstinFilePath: _gstinFilePath,
      pan: _panController.text.trim(),
      panFilePath: _panFilePath,
      bankCategory: _bankCategory,
      bankName: _bankNameController.text.trim(),
      accountType: _accountType,
      ifscCode: _ifscCodeController.text.trim(),
      branchName: _branchNameController.text.trim(),
      accountHolderName: _accountHolderNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      isActive: true,
    );

    // TODO: Save developer to database/API
    Navigator.of(context).pop(developer);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${developer.name} created successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  Color _panelColor(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);
  }

  Color _panelBorderColor(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0x22000000);
  }
}

// Developer model classes (same as in developer_quick_stats_screen.dart)
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
    required this.reraNumber,
    required this.gstin,
    this.gstinFilePath,
    required this.pan,
    this.panFilePath,
    required this.bankCategory,
    required this.bankName,
    required this.accountType,
    required this.ifscCode,
    required this.branchName,
    required this.accountHolderName,
    required this.accountNumber,
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
  final String reraNumber;
  final String gstin;
  final String? gstinFilePath;
  final String pan;
  final String? panFilePath;
  final String bankCategory;
  final String bankName;
  final String accountType;
  final String ifscCode;
  final String branchName;
  final String accountHolderName;
  final String accountNumber;
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
