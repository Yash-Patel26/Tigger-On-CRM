import 'package:flutter/material.dart';
import '../utils/page_transitions.dart';
import 'vendor_kyc_details_screen.dart';

class VendorBasicDetailsScreen extends StatefulWidget {
  const VendorBasicDetailsScreen({super.key, this.entityType});

  final String? entityType; // retained for backward compatibility

  @override
  State<VendorBasicDetailsScreen> createState() =>
      _VendorBasicDetailsScreenState();
}

class _VendorBasicDetailsScreenState extends State<VendorBasicDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _entityType = 'company'; // company | individual
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _contactCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _typeCtrl = TextEditingController(
    text: 'Supplier',
  );
  final TextEditingController _companyCtrl = TextEditingController();
  final TextEditingController _contactNameCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _stateCtrl = TextEditingController();
  final TextEditingController _countryCtrl = TextEditingController(
    text: 'India',
  );
  final TextEditingController _pinCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _emailCtrl.dispose();
    _typeCtrl.dispose();
    _companyCtrl.dispose();
    _contactNameCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _countryCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _entityType = (widget.entityType ?? _entityType).toLowerCase();
    final String type = _entityType;
    return Scaffold(
      appBar: AppBar(title: const Text('Create Vendor - Basic')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                _stepHeader(context, currentStep: 0),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'individual',
                        groupValue: type,
                        onChanged: (String? v) {
                          if (v == null) return;
                          setState(() => _entityType = v);
                        },
                        title: const Text('Individual'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RadioListTile<String>(
                        value: 'company',
                        groupValue: type,
                        onChanged: (String? v) {
                          if (v == null) return;
                          setState(() => _entityType = v);
                        },
                        title: const Text('Company'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _title('Basic Details'),
                const SizedBox(height: 12),
                _formField(
                  context,
                  label: 'Vendor Name',
                  controller: _nameCtrl,
                ),
                const SizedBox(height: 12),
                _formField(
                  context,
                  label: 'Contact Number',
                  controller: _contactCtrl,
                  keyboardType: TextInputType.phone,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _formField(
                        context,
                        label: 'Email',
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _formField(context, label: 'Type', controller: _typeCtrl),
                if (type == 'company') ...<Widget>[
                  const SizedBox(height: 12),
                  _formField(
                    context,
                    label: 'Company Name',
                    controller: _companyCtrl,
                  ),
                  const SizedBox(height: 12),
                  _formField(
                    context,
                    label: 'Contact Person',
                    controller: _contactNameCtrl,
                  ),
                ] else ...<Widget>[
                  const SizedBox(height: 12),
                  _formField(
                    context,
                    label: 'Full Name',
                    controller: _companyCtrl,
                  ),
                ],
                _formField(
                  context,
                  label: 'Address',
                  controller: _addressCtrl,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _formField(context, label: 'City', controller: _cityCtrl),
                const SizedBox(height: 12),
                _formField(context, label: 'State', controller: _stateCtrl),
                const SizedBox(height: 12),
                _formField(context, label: 'Country', controller: _countryCtrl),
                const SizedBox(height: 12),
                _formField(
                  context,
                  label: 'Pincode',
                  controller: _pinCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _goNext,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goNext() async {
    final Map<String, dynamic> basic = <String, dynamic>{
      'entityType': _entityType,
      'name': _nameCtrl.text,
      'contactNumber': _contactCtrl.text,
      'email': _emailCtrl.text,
      'type': _typeCtrl.text,
      'companyName': _companyCtrl.text,
      'contactName': _contactNameCtrl.text,
      'address': _addressCtrl.text,
      'city': _cityCtrl.text,
      'state': _stateCtrl.text,
      'country': _countryCtrl.text.isEmpty ? 'India' : _countryCtrl.text,
      'pincode': _pinCtrl.text,
    };

    final Map<String, dynamic>? result = await Navigator.of(context).push(
      SmoothPageTransitions.slideFromRight<Map<String, dynamic>>(
        child: VendorKycDetailsScreen(initial: basic),
      ),
    );

    if (result != null) {
      Navigator.pop(context, result);
    }
  }

  // Validation disabled per request

  Widget _title(String text) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _formField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            isDense: true,
            hintText: 'Enter $label',
            filled: true,
            fillColor: _panelColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _panelBorderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _panelBorderColor(context)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepHeader(BuildContext context, {required int currentStep}) {
    final List<String> labels = <String>['Basic', 'KYC', 'Bank', 'Service'];
    final Color primary = Theme.of(context).colorScheme.primary;
    final Color onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: List<Widget>.generate(labels.length, (int index) {
            final bool selected = index == currentStep;
            return Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                margin: EdgeInsets.only(
                  right: index < labels.length - 1 ? 8 : 0,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? primary.withOpacity(0.10)
                      : _panelColor(context),
                  border: Border.all(color: _panelBorderColor(context)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    labels[index],
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: selected ? primary : onSurface,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (currentStep + 1) / labels.length,
          minHeight: 6,
          backgroundColor: _panelColor(context),
        ),
      ],
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
