import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddSiteVisitScreen extends StatefulWidget {
  const AddSiteVisitScreen({super.key, this.leadId});

  final String? leadId;

  @override
  State<AddSiteVisitScreen> createState() => _AddSiteVisitScreenState();
}

class _AddSiteVisitScreenState extends State<AddSiteVisitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerContactController = TextEditingController();
  final _leadReferenceIdController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _meetingAddressController = TextEditingController();
  final _meetingPurposeController = TextEditingController();
  final _meetingLocationController = TextEditingController();

  DateTime? _meetingFrom;
  DateTime? _meetingTo;

  @override
  void initState() {
    super.initState();
    // Pre-fill lead reference ID if provided
    if (widget.leadId != null) {
      _leadReferenceIdController.text = widget.leadId!;
    }

    // Add mock data for demonstration
    _customerContactController.text = '+91 98765 43210';
    _customerNameController.text = 'Alex Johnson';
    _meetingAddressController.text =
        '221B Baker Street, Andheri West, Mumbai - 400053';
    _meetingPurposeController.text =
        'Property inspection and site visit for 2 BHK apartment';
    _meetingLocationController.text = 'Project Alpha Site Office';

    // Set default meeting times (tomorrow 2:00 PM to 3:00 PM)
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    _meetingFrom = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0);
    _meetingTo = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 15, 0);
  }

  @override
  void dispose() {
    _customerContactController.dispose();
    _leadReferenceIdController.dispose();
    _customerNameController.dispose();
    _meetingAddressController.dispose();
    _meetingPurposeController.dispose();
    _meetingLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Site Visit'),
        actions: <Widget>[
          TextButton(onPressed: _saveSiteVisit, child: const Text('Save')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _SectionCard(
                title: 'Basic Details',
                children: <Widget>[
                  _FormField(
                    label: 'Customer Contact',
                    controller: _customerContactController,
                    keyboardType: TextInputType.phone,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter customer contact';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    label: 'Lead Reference ID',
                    controller: _leadReferenceIdController,
                    keyboardType: TextInputType.number,
                    maxLength: 11,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter lead reference ID';
                      }
                      if (value.length > 11) {
                        return 'Lead ID must be up to 11 digits';
                      }
                      if (!RegExp(r'^\d{1,11}\$').hasMatch(value)) {
                        return 'Only digits allowed (max 11)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    label: 'Customer Name',
                    controller: _customerNameController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter customer name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    label: 'Meeting Address',
                    controller: _meetingAddressController,
                    maxLines: 2,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter meeting address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    label: 'Meeting Purpose',
                    controller: _meetingPurposeController,
                    maxLines: 2,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter meeting purpose';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _DateTimeField(
                    label: 'Meeting From',
                    value: _meetingFrom,
                    onChanged: (DateTime? value) {
                      setState(() => _meetingFrom = value);
                    },
                    validator: (DateTime? value) {
                      if (value == null) {
                        return 'Please select meeting start time';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _DateTimeField(
                    label: 'Meeting To',
                    value: _meetingTo,
                    onChanged: (DateTime? value) {
                      setState(() => _meetingTo = value);
                    },
                    validator: (DateTime? value) {
                      if (value == null) {
                        return 'Please select meeting end time';
                      }
                      if (_meetingFrom != null &&
                          value.isBefore(_meetingFrom!)) {
                        return 'End time must be after start time';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    label: 'Meeting Location',
                    controller: _meetingLocationController,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter meeting location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _FormField(
                    label: 'Meeting Address',
                    controller: _meetingAddressController,
                    maxLines: 2,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter meeting address';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveSiteVisit,
                  child: const Text('Create Site Visit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSiteVisit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement save site visit functionality
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Site visit created successfully')),
      );
      Navigator.of(context).pop();
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        children: <Widget>[
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
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter $label',
          ),
        ),
      ],
    );
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String? Function(DateTime?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime now = DateTime.now();
            final DateTime? picked = await showDatePicker(
              context: context,
              firstDate: now,
              lastDate: DateTime(now.year + 1),
              initialDate: value ?? now,
            );
            if (picked != null) {
              final TimeOfDay? time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                final DateTime dateTime = DateTime(
                  picked.year,
                  picked.month,
                  picked.day,
                  time.hour,
                  time.minute,
                );
                onChanged(dateTime);
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.event_outlined,
                  color: Theme.of(context).iconTheme.color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value != null
                        ? '${value!.day}/${value!.month}/${value!.year} ${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}'
                        : 'Select date and time',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Theme.of(context).iconTheme.color,
                ),
              ],
            ),
          ),
        ),
        if (validator != null && validator!(value) != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              validator!(value)!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
