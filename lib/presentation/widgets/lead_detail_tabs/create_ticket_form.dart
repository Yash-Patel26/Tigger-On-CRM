import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../data/services/database_service.dart';
import '../../../../data/services/lead_duplicate_service.dart';
import '../../../../data/services/booking_service.dart';
import '../../../../data/models/models.dart';
import '../../../../shared/utils/helpers.dart';

class CreateTicketForm extends StatefulWidget {
  const CreateTicketForm({
    super.key,
    required this.onTicketCreated,
    this.initialLeadId,
  });

  final VoidCallback onTicketCreated;
  final String? initialLeadId;

  @override
  State<CreateTicketForm> createState() => _CreateTicketFormState();
}

class _CreateTicketFormState extends State<CreateTicketForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _ticketCategoryCtrl = TextEditingController();
  final TextEditingController _registeredMobileCtrl = TextEditingController();
  final TextEditingController _contactNameCtrl = TextEditingController();
  final TextEditingController _alternateMobileCtrl = TextEditingController();
  final TextEditingController _issueTitleCtrl = TextEditingController();
  final TextEditingController _unitNumberCtrl = TextEditingController();
  final TextEditingController _issueDescriptionCtrl = TextEditingController();

  String? _selectedLeadId;
  String? _ticketType;
  String? _serviceType;
  String _priority = 'Low';
  String? _assignToUserId;
  String? _assignToUserName;
  bool _isFetchingLead = false;
  List<Lead> _availableLeads = [];

  @override
  void initState() {
    super.initState();
    _selectedLeadId = widget.initialLeadId;
  }

  @override
  void dispose() {
    _ticketCategoryCtrl.dispose();
    _registeredMobileCtrl.dispose();
    _contactNameCtrl.dispose();
    _alternateMobileCtrl.dispose();
    _issueTitleCtrl.dispose();
    _unitNumberCtrl.dispose();
    _issueDescriptionCtrl.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _getUsers() async {
    try {
      final client = supabase.Supabase.instance.client;
      final response = await client
          .from('users')
          .select('id,name,email,role,is_active')
          .eq('is_active', true)
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  Future<void> _fetchLeadByMobile() async {
    final mobile = _registeredMobileCtrl.text.trim();
    if (mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a mobile number')),
      );
      return;
    }

    setState(() => _isFetchingLead = true);
    try {
      final leadData = await LeadDuplicateService.getLeadByContactNumber(
        mobile,
      );
      if (leadData != null) {
        final lead = Lead.fromJson(leadData);
        setState(() {
          _selectedLeadId = lead.id;
          _contactNameCtrl.text = lead.customerName;
          _availableLeads = [lead];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lead fetched successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No lead found with this mobile number'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching lead: $e')));
    } finally {
      setState(() => _isFetchingLead = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLeadId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fetch and select a lead')),
      );
      return;
    }

    try {
      // Map ticket type
      TicketType mappedTicketType;
      if (_ticketType == 'General Query') {
        mappedTicketType = TicketType.generalQuery;
      } else if (_ticketType == 'Complaint') {
        mappedTicketType = TicketType.complaint;
      } else {
        mappedTicketType = TicketType.issue;
      }

      // Map service type
      ServiceType mappedServiceType;
      switch (_serviceType) {
        case 'Gas Supply':
          mappedServiceType = ServiceType.gasSupply;
          break;
        case 'Parking Space':
          mappedServiceType = ServiceType.parkingSpace;
          break;
        case 'Security Space':
          mappedServiceType = ServiceType.securitySpace;
          break;
        case 'Water Supply Space':
          mappedServiceType = ServiceType.waterSupplySpace;
          break;
        case 'WiFi':
          mappedServiceType = ServiceType.wifi;
          break;
        default:
          mappedServiceType = ServiceType.other;
      }

      // Map priority
      TicketPriority mappedPriority;
      switch (_priority) {
        case 'High':
          mappedPriority = TicketPriority.high;
          break;
        case 'Medium':
          mappedPriority = TicketPriority.medium;
          break;
        case 'Low':
        default:
          mappedPriority = TicketPriority.low;
      }

      // Get customer ID from booking if booking exists for this lead
      String? customerId;
      try {
        // Use the lead UUID directly (bookings.lead_id is a UUID, not the human-readable lead_id)
        // Fetch the most recent booking for this lead using the UUID
        final booking = await BookingService.getBookingByLeadId(
          _selectedLeadId!,
        );

        // Use the booking's customerId which is a UUID foreign key to the customers table
        // Note: customer_code in custom_fields is just a human-readable code, not the UUID
        if (booking != null &&
            booking.customerId.isNotEmpty) {
          customerId = booking.customerId;
        }
      } catch (e) {
        // If error fetching booking, continue without customer ID
        print('Error fetching booking for customer ID: $e');
      }

      await DatabaseService.createTicket(
        leadId: _selectedLeadId!,
        issueTitle: _issueTitleCtrl.text.trim(),
        issueDescription: _issueDescriptionCtrl.text.trim(),
        ticketCategory: _ticketCategoryCtrl.text.trim().isEmpty
            ? null
            : _ticketCategoryCtrl.text.trim(),
        priority: mappedPriority,
        type: mappedTicketType,
        serviceType: mappedServiceType,
        assignedTo: _assignToUserId,
        assignedToName: _assignToUserName,
        contactName: _contactNameCtrl.text.trim(),
        contactMobile: _registeredMobileCtrl.text.trim(),
        unitNumber: _unitNumberCtrl.text.trim().isEmpty
            ? null
            : _unitNumberCtrl.text.trim(),
        alternateNumber: _alternateMobileCtrl.text.trim().isEmpty
            ? null
            : _alternateMobileCtrl.text.trim(),
        customerId: customerId,
      );

      widget.onTicketCreated();
      await Helpers.showSuccessDialog(
        context,
        title: 'Ticket created successfully',
        message: 'Support team will be notified.',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create ticket: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    'Create Ticket',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      FontAwesomeIcons.xmark,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Ticket Category
              TextFormField(
                controller: _ticketCategoryCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ticket Category *',
                  border: OutlineInputBorder(),
                ),
                validator: (String? v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Registered Mobile Number with Fetch Button
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _registeredMobileCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Registered Mobile Number *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required';
                        }
                        final digits = v.replaceAll(RegExp(r'\D'), '');
                        if (digits.length < 10) {
                          return 'Enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isFetchingLead ? null : _fetchLeadByMobile,
                    child: _isFetchingLead
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Fetch'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Lead List
              DropdownButtonFormField<String>(
                initialValue: _selectedLeadId,
                decoration: const InputDecoration(
                  labelText: 'Lead List *',
                  border: OutlineInputBorder(),
                ),
                items: _availableLeads.isEmpty
                    ? null
                    : _availableLeads
                          .map(
                            (Lead lead) => DropdownMenuItem<String>(
                              value: lead.id,
                              child: Text(
                                '${lead.customerName} (${lead.leadId})',
                              ),
                            ),
                          )
                          .toList(),
                onChanged: (String? v) {
                  setState(() {
                    _selectedLeadId = v;
                    if (v != null) {
                      final lead = _availableLeads.firstWhere((l) => l.id == v);
                      _contactNameCtrl.text = lead.customerName;
                    }
                  });
                },
                validator: (String? v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Ticket Type
              DropdownButtonFormField<String>(
                initialValue: _ticketType,
                decoration: const InputDecoration(
                  labelText: 'Ticket Type *',
                  border: OutlineInputBorder(),
                ),
                items: const <String>['General Query', 'Complaint']
                    .map(
                      (String e) =>
                          DropdownMenuItem<String>(value: e, child: Text(e)),
                    )
                    .toList(),
                onChanged: (String? v) => setState(() => _ticketType = v),
                validator: (String? v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Service Type
              DropdownButtonFormField<String>(
                initialValue: _serviceType,
                decoration: const InputDecoration(
                  labelText: 'Service Type *',
                  border: OutlineInputBorder(),
                ),
                items:
                    const <String>[
                          'Gas Supply',
                          'Parking Space',
                          'Security Space',
                          'Water Supply Space',
                          'WiFi',
                        ]
                        .map(
                          (String e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                onChanged: (String? v) => setState(() => _serviceType = v),
                validator: (String? v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Priority
              DropdownButtonFormField<String>(
                initialValue: _priority,
                decoration: const InputDecoration(
                  labelText: 'Priority *',
                  border: OutlineInputBorder(),
                ),
                items: const <String>['Low', 'Medium', 'High']
                    .map(
                      (String e) =>
                          DropdownMenuItem<String>(value: e, child: Text(e)),
                    )
                    .toList(),
                onChanged: (String? v) {
                  if (v != null) {
                    setState(() => _priority = v);
                  }
                },
                validator: (String? v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Contact Name
              TextFormField(
                controller: _contactNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (String? v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Alternate Mobile Number
              TextFormField(
                controller: _alternateMobileCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Alternate Mobile Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Issue Title
              TextFormField(
                controller: _issueTitleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Issue Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (String? v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // Unit Number
              TextFormField(
                controller: _unitNumberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Unit Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              // Assign To
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _getUsers(),
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
                    ) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Text('Failed to load users');
                      }
                      final List<Map<String, dynamic>> users =
                          snapshot.data ?? <Map<String, dynamic>>[];
                      return DropdownButtonFormField<String>(
                        initialValue: _assignToUserId,
                        decoration: const InputDecoration(
                          labelText: 'Assign To',
                          border: OutlineInputBorder(),
                        ),
                        items: users
                            .map(
                              (Map<String, dynamic> u) =>
                                  DropdownMenuItem<String>(
                                    value: (u['id'] ?? '') as String,
                                    child: Text((u['name'] ?? '-') as String),
                                  ),
                            )
                            .toList(),
                        onChanged: (String? v) {
                          setState(() {
                            _assignToUserId = v;
                            if (v != null) {
                              final user = users.firstWhere(
                                (u) => (u['id'] ?? '') == v,
                                orElse: () => <String, dynamic>{},
                              );
                              _assignToUserName =
                                  (user['name'] ?? '-') as String;
                            }
                          });
                        },
                      );
                    },
              ),
              const SizedBox(height: 16),
              // Issue Description
              TextFormField(
                controller: _issueDescriptionCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Issue Description *',
                  border: OutlineInputBorder(),
                ),
                validator: (String? v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submitForm,
                  icon: const Icon(FontAwesomeIcons.check),
                  label: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
