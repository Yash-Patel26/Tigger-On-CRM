import 'package:flutter/material.dart';
// removed unused imports

class VendorServiceInfoScreen extends StatefulWidget {
  const VendorServiceInfoScreen({super.key, required this.initial});

  final Map<String, dynamic> initial;

  @override
  State<VendorServiceInfoScreen> createState() =>
      _VendorServiceInfoScreenState();
}

class _VendorServiceInfoScreenState extends State<VendorServiceInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _serviceTypeCtrl = TextEditingController(
    text: 'Service',
  );
  final TextEditingController _servicesOfferedCtrl = TextEditingController();
  final TextEditingController _serviceAreaCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();

  @override
  void dispose() {
    _serviceTypeCtrl.dispose();
    _servicesOfferedCtrl.dispose();
    _serviceAreaCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Vendor - Service Info')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                _stepHeader(context, currentStep: 3),
                const SizedBox(height: 12),
                Text(
                  'Service Information',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                _formField(
                  context,
                  label: 'Service Type',
                  controller: _serviceTypeCtrl,
                ),
                const SizedBox(height: 12),
                _formField(
                  context,
                  label: 'Services Offered',
                  controller: _servicesOfferedCtrl,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _formField(
                  context,
                  label: 'Service Area / Coverage',
                  controller: _serviceAreaCtrl,
                ),
                const SizedBox(height: 12),
                _formField(
                  context,
                  label: 'Description',
                  controller: _descriptionCtrl,
                  maxLines: 3,
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
                        onPressed: _finish,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Finish'),
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

  void _finish() {
    final Map<String, dynamic> all = <String, dynamic>{
      ...widget.initial,
      'serviceType': _serviceTypeCtrl.text,
      'servicesOffered': _servicesOfferedCtrl.text,
      'serviceArea': _serviceAreaCtrl.text,
      'serviceDescription': _descriptionCtrl.text,
    };
    Navigator.pop(context, all);
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
