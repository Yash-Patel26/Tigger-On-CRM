import 'package:flutter/material.dart';
import '../utils/page_transitions.dart';
import 'vendor_service_info_screen.dart';

class VendorBankDetailsScreen extends StatefulWidget {
  const VendorBankDetailsScreen({super.key, required this.initial});

  final Map<String, dynamic> initial;

  @override
  State<VendorBankDetailsScreen> createState() =>
      _VendorBankDetailsScreenState();
}

class _VendorBankDetailsScreenState extends State<VendorBankDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _bankNameCtrl = TextEditingController();
  final TextEditingController _ifscCtrl = TextEditingController();
  final TextEditingController _branchCtrl = TextEditingController();
  final TextEditingController _accountHolderCtrl = TextEditingController();
  final TextEditingController _accountNumberCtrl = TextEditingController();
  bool _isActive = true;

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _ifscCtrl.dispose();
    _branchCtrl.dispose();
    _accountHolderCtrl.dispose();
    _accountNumberCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Vendor - Bank')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                _stepHeader(context, currentStep: 2),
                const SizedBox(height: 12),
                Text(
                  'Bank Details',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _formField(
                  context,
                  label: 'Bank Name',
                  controller: _bankNameCtrl,
                ),
                const SizedBox(height: 12),
                _formField(context, label: 'IFSC', controller: _ifscCtrl),
                const SizedBox(height: 12),
                _formField(context, label: 'Branch', controller: _branchCtrl),
                const SizedBox(height: 12),
                _formField(
                  context,
                  label: 'Account Holder',
                  controller: _accountHolderCtrl,
                ),
                const SizedBox(height: 12),
                _formField(
                  context,
                  label: 'Account Number',
                  controller: _accountNumberCtrl,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Switch(
                      value: _isActive,
                      onChanged: (bool v) => setState(() => _isActive = v),
                    ),
                    const SizedBox(width: 8),
                    Text(_isActive ? 'Active' : 'Inactive'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Back'),
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
    final Map<String, dynamic> bank = <String, dynamic>{
      ...widget.initial,
      'bankName': _bankNameCtrl.text,
      'ifsc': _ifscCtrl.text,
      'branch': _branchCtrl.text,
      'accountHolder': _accountHolderCtrl.text,
      'accountNumber': _accountNumberCtrl.text,
      'isActive': _isActive,
    };
    final Map<String, dynamic>? result = await Navigator.of(context).push(
      SmoothPageTransitions.slideFromRight<Map<String, dynamic>>(
        child: VendorServiceInfoScreen(initial: bank),
      ),
    );
    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  // Validation disabled per request

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
