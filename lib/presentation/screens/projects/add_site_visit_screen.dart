import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/lead_model.dart';
import '../../../data/models/site_visit_model.dart';
import '../../../data/models/project_model.dart';

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
  Lead? _lead;
  bool _loading = false;
  String? _selectedProjectId;
  String? _selectedProjectName;

  @override
  void initState() {
    super.initState();
    // Pre-fill lead reference ID if provided
    if (widget.leadId != null) {
      _leadReferenceIdController.text = widget.leadId!;
    }
    _loadLeadAndPrefill();
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
          TextButton(
            onPressed: _loading ? null : _saveSiteVisit,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (_loading) const LinearProgressIndicator(),
              _SectionCard(
                title: 'Basic Details',
                children: <Widget>[
                  _ProjectPicker(
                    selectedProjectName: _selectedProjectName,
                    onPick: (String id, String name) {
                      setState(() {
                        _selectedProjectId = id;
                        _selectedProjectName = name;
                        if (_meetingLocationController.text.trim().isEmpty) {
                          _meetingLocationController.text = name;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
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
                    keyboardType: TextInputType.text,
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter lead reference ID';
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
                  // address already captured above
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _saveSiteVisit,
                  child: const Text('Create Site Visit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadLeadAndPrefill() async {
    if (widget.leadId == null || widget.leadId!.trim().isEmpty) {
      // still set a reasonable default time window
      final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
      setState(() {
        _meetingFrom = DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          14,
          0,
        );
        _meetingTo = DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          15,
          0,
        );
      });
      return;
    }
    setState(() => _loading = true);
    try {
      final Lead? lead = await DatabaseService.getLeadById(
        widget.leadId!.trim(),
      );
      final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
      setState(() {
        _lead = lead;
        if (lead != null) {
          _customerNameController.text = lead.customerName;
          _customerContactController.text = lead.phone;
          if (lead.projectName != null && lead.projectName!.isNotEmpty) {
            _meetingLocationController.text = lead.projectName!;
            _selectedProjectId = lead.projectId;
            _selectedProjectName = lead.projectName;
          }
          if (lead.address != null && lead.address!.isNotEmpty) {
            _meetingAddressController.text = lead.address!;
          }
        }
        _meetingFrom = DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          14,
          0,
        );
        _meetingTo = DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          15,
          0,
        );
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load lead: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _saveSiteVisit() {
    if (!_formKey.currentState!.validate()) return;
    final String leadIdInput = _leadReferenceIdController.text.trim();
    final String name = _customerNameController.text.trim();
    final String phone = _customerContactController.text.trim();
    final String address = _meetingAddressController.text.trim();
    final String purpose = _meetingPurposeController.text.trim();
    final String location = _meetingLocationController.text.trim();
    final DateTime? from = _meetingFrom;
    final DateTime? to = _meetingTo;

    if (from == null || to == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select meeting time')),
      );
      return;
    }

    setState(() => _loading = true);
    DatabaseService.createSiteVisit(
          leadId: leadIdInput,
          customerName: name.isNotEmpty ? name : _lead?.customerName,
          customerPhone: phone.isNotEmpty ? phone : _lead?.phone,
          projectId: _selectedProjectId ?? _lead?.projectId,
          projectName: _selectedProjectName ?? _lead?.projectName ?? location,
          attenderName: _lead?.assignedToName,
          purpose: purpose,
          address: address,
          visitMode: VisitMode.physical,
          status: SiteVisitStatus.scheduled,
          meetingFrom: from,
          meetingTo: to,
        )
        .then((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Site visit created')));
          Navigator.of(context).pop();
        })
        .catchError((e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to create site visit: $e')),
          );
        })
        .whenComplete(() {
          if (mounted) setState(() => _loading = false);
        });
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
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
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

class _ProjectPicker extends StatefulWidget {
  const _ProjectPicker({
    required this.selectedProjectName,
    required this.onPick,
  });

  final String? selectedProjectName;
  final void Function(String id, String name) onPick;

  @override
  State<_ProjectPicker> createState() => _ProjectPickerState();
}

class _ProjectPickerState extends State<_ProjectPicker> {
  String _search = '';
  Future<List<Project>>? _future;

  void _openPicker() {
    setState(() {
      _future = DatabaseService.getProjects(
        search: _search.isEmpty ? null : _search,
        page: 1,
        limit: 20,
      );
    });
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Select Project',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Search projects',
                  prefixIcon: Icon(Icons.search_rounded),
                  border: OutlineInputBorder(),
                ),
                onChanged: (String v) {
                  setState(() => _search = v.trim());
                  setState(() {
                    _future = DatabaseService.getProjects(
                      search: _search.isEmpty ? null : _search,
                      page: 1,
                      limit: 20,
                    );
                  });
                },
              ),
              const SizedBox(height: 12),
              Flexible(
                child: FutureBuilder<List<Project>>(
                  future: _future,
                  builder:
                      (
                        BuildContext context,
                        AsyncSnapshot<List<Project>> snapshot,
                      ) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: Text(
                                  'Failed to load projects',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _future = DatabaseService.getProjects(
                                      search: _search.isEmpty ? null : _search,
                                      page: 1,
                                      limit: 20,
                                    );
                                  });
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          );
                        }
                        final List<Project> items =
                            snapshot.data ?? <Project>[];
                        if (items.isEmpty) {
                          return const Center(child: Text('No projects found'));
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (BuildContext context, int index) {
                            final Project p = items[index];
                            return ListTile(
                              title: Text(p.name),
                              subtitle: p.city != null ? Text(p.city!) : null,
                              onTap: () {
                                widget.onPick(p.id, p.name);
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        );
                      },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Project',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: _openPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.business_outlined),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.selectedProjectName ?? 'Select project',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
