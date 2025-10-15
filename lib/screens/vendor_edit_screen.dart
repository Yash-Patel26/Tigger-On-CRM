import 'package:flutter/material.dart';

class VendorEditScreen extends StatefulWidget {
  const VendorEditScreen({
    super.key,
    required this.vendorId,
    required this.name,
    required this.contactNumber,
    required this.email,
    required this.type,
    required this.commenceDate,
    required this.isActive,
  });

  final String vendorId;
  final String name;
  final String contactNumber;
  final String email;
  final String type;
  final String commenceDate;
  final bool isActive;

  @override
  State<VendorEditScreen> createState() => _VendorEditScreenState();
}

class _VendorEditScreenState extends State<VendorEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _contactController;
  late final TextEditingController _emailController;
  late final TextEditingController _typeController;
  late final TextEditingController _commenceController;
  late bool _active;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _contactController = TextEditingController(text: widget.contactNumber);
    _emailController = TextEditingController(text: widget.email);
    _typeController = TextEditingController(text: widget.type);
    _commenceController = TextEditingController(text: widget.commenceDate);
    _active = widget.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _typeController.dispose();
    _commenceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Vendor')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _ReadOnlyRow(label: 'Vendor ID', value: widget.vendorId),
              const SizedBox(height: 12),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Primary Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Vendor Name *',
                        prefixIcon: Icon(
                          Icons.store_mall_directory_outlined,
                          size: 18,
                        ),
                      ),
                      validator: (String? v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contactController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Number *',
                        prefixIcon: Icon(Icons.phone_outlined, size: 18),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (String? v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        prefixIcon: Icon(Icons.alternate_email, size: 18),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (String? v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final bool ok = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$',
                        ).hasMatch(v);
                        return ok ? null : 'Invalid email';
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _typeController,
                      decoration: const InputDecoration(
                        labelText: 'Vendor Type *',
                        prefixIcon: Icon(Icons.category_outlined, size: 18),
                      ),
                      validator: (String? v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _commenceController,
                      decoration: const InputDecoration(
                        labelText: 'Date of Commence *',
                        prefixIcon: Icon(Icons.event_outlined, size: 18),
                      ),
                      validator: (String? v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        const Text('Active'),
                        const SizedBox(width: 8),
                        Switch(
                          value: _active,
                          onChanged: (bool v) => setState(() => _active = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onSave,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Vendor updated (mock).'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
    Navigator.of(context).pop();
  }
}

class _ReadOnlyRow extends StatelessWidget {
  const _ReadOnlyRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          '$label: ',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panelColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: child,
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
