import 'package:flutter/material.dart';
import 'package:realtime_client/realtime_client.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'dart:math' as math;
import '../../../../shared/utils/helpers.dart';
import '../../../../data/repositories/lead_repository.dart';
import '../../../../data/repositories/booking_repository.dart';
import '../../../../data/services/database_service.dart';
import '../../../../data/services/database_service_masters.dart' as masters;
import '../../../../data/services/location_data_service.dart';
import '../../../../data/services/master_data_service.dart';
import '../../../../data/models/models.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widgets/lead_detail_tabs/reference_tab.dart';
import '../../widgets/lead_detail_tabs/site_visit_tab.dart';
import '../../widgets/lead_detail_tabs/task_tab.dart';
import '../../widgets/lead_detail_tabs/question_tab.dart';
import '../../widgets/lead_detail_tabs/property_option_tab.dart';
import '../../widgets/lead_detail_tabs/ticket_tab.dart';
import '../../widgets/dispose_lead_widget.dart';
import '../../widgets/assign_lead_widget.dart';
import '../../widgets/lead_detail/collapsible_card.dart';
import '../../widgets/lead_detail/basic_details_card.dart';
import '../../widgets/lead_detail/professional_details_card.dart';
import '../../widgets/lead_detail/permanent_address_card.dart';
import '../../widgets/lead_detail/requirement_notes_card.dart';
import '../../widgets/lead_detail/activity_compact.dart';
import '../../widgets/lead_detail/project_location_compact.dart';
import 'timeline/tabbed_timeline_card.dart';

class LeadDetailScreen extends StatefulWidget {
  const LeadDetailScreen({super.key, required this.leadId});

  final String leadId;

  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen>
    with SingleTickerProviderStateMixin {
  final LeadRepository _leadRepository = LeadRepository();

  late Future<Lead> _leadFuture;
  RealtimeChannel? _leadRealtimeChannel;
  late TabController _tabController;
  final GlobalKey<TabbedTimelineCardState> _timelineKey =
      GlobalKey<TabbedTimelineCardState>();
  final Set<int> _loadedTabs = <int>{0};

  @override
  void initState() {
    super.initState();
    _leadFuture = _fetchLead();
    _subscribeToLeadUpdates();
    _tabController = TabController(length: 8, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  Future<Lead> _fetchLead() async {
    final response = await _leadRepository.getLead(widget.leadId);
    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.error ?? 'Failed to load lead');
  }

  void refreshLead() {
    if (!mounted) return;
    setState(() {
      _leadFuture = _fetchLead();
    });
  }

  void _subscribeToLeadUpdates() {
    // Listen for updates to this lead and refresh UI in realtime
    final client = supabase.Supabase.instance.client;
    _leadRealtimeChannel = client.channel('public:leads:${widget.leadId}');

    _leadRealtimeChannel!
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.update,
          schema: 'public',
          table: 'leads',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: widget.leadId,
          ),
          callback: (PostgresChangePayload payload) {
            if (!mounted) return;

            // Refresh the lead data
            setState(() {
              _leadFuture = _fetchLead();
            });

            // Show a subtle notification that the data was updated
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lead information updated'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          },
        )
        .onPostgresChanges(
          event: supabase.PostgresChangeEvent.insert,
          schema: 'public',
          table: 'leads',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: widget.leadId,
          ),
          callback: (PostgresChangePayload payload) {
            if (!mounted) return;
            setState(() {
              _leadFuture = _fetchLead();
            });
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _leadRealtimeChannel?.unsubscribe();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final int idx = _tabController.index;
      if (!_loadedTabs.contains(idx)) {
        setState(() {
          _loadedTabs.add(idx);
        });
      }
    }
  }

  Widget _lazyTab(int index, Widget child, {Widget? placeholder}) {
    if (_loadedTabs.contains(index)) return child;
    return placeholder ?? const Center(child: Text('Select this tab to load'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F0E4),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Lead Details', style: TextStyle(fontSize: 18)),
            Text(
              widget.leadId,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
        actions: <Widget>[
          AssignLeadButton(
            onAssignComplete: refreshLead,
            getLeadFuture: () => _leadFuture,
          ),
          DisposeLeadButton(
            leadId: widget.leadId,
            onDisposeComplete: refreshLead,
            onShowCreateBooking: _showCreateBookingDialog,
            onFocusTimelineDisposition: () {
              // Expand/focus timeline if needed then select Disposition tab
              _timelineKey.currentState?.selectDispositionTab();
            },
            onAutoCreateBooking: _quickCreateBooking,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: FutureBuilder<Lead>(
                  future: _leadFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final lead = snapshot.data!;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          _IconAction(
                            assetPng: 'assets/icons/phone-call.png',
                            tooltip: 'Call',
                            onTap: () async {
                              await Helpers.placeCallAndLog(
                                phone: lead.phone,
                                leadId: lead.id,
                                direction: 'outbound',
                              );
                            },
                          ),
                          _IconAction(
                            assetPng: 'assets/icons/phone-call.png',
                            tooltip: 'Edit Before Call',
                            onTap: () async {
                              final String? number = await _promptPhone(
                                context,
                                initial: lead.phone,
                              );
                              if (number != null && number.trim().isNotEmpty) {
                                await Helpers.placeCallAndLog(
                                  phone: number.trim(),
                                  leadId: lead.id,
                                  direction: 'outbound',
                                );
                              }
                            },
                            rotateTurns: 2, // rotate 180° to differentiate
                          ),
                          _IconAction(
                            assetPng: 'assets/icons/email.png',
                            tooltip: 'Email',
                            onTap: () => _launchEmail(lead.email, lead.id),
                          ),
                          _IconAction(
                            assetPng: 'assets/icons/conversation.png',
                            tooltip: 'SMS',
                            onTap: () => _launchSms(lead.phone, lead.id),
                          ),
                          _IconAction(
                            assetPng: 'assets/icons/whatsapp.png',
                            tooltip: 'WhatsApp',
                            onTap: () => _launchWhatsApp(lead.phone, lead.id),
                          ),
                          _IconAction(
                            assetPng: 'assets/icons/whatsapp.png',
                            tooltip: 'Offline WA',
                            onTap: () =>
                                _launchWhatsAppWeb(lead.phone, lead.id),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error loading lead data'),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                  tabs: const <Tab>[
                    Tab(text: 'Lead Detail'),
                    Tab(text: 'Cross Sell'),
                    Tab(text: 'Reference'),
                    Tab(text: 'Site Visit'),
                    Tab(text: 'Task'),
                    Tab(text: 'Question'),
                    Tab(text: 'Property Option'),
                    Tab(text: 'Ticket'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<Lead>(
        future: _leadFuture,
        builder: (BuildContext context, AsyncSnapshot<Lead> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load lead: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final Lead lead = snapshot.data!;
          return TabBarView(
            controller: _tabController,
            children: <Widget>[
              // Lead Detail tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _StaticCard(
                      title: 'Contact Information',
                      action: IconButton(
                        onPressed: () => _showEditContactDialog(context, lead),
                        icon: const Icon(
                          FontAwesomeIcons.penToSquare,
                          size: 20,
                        ),
                        tooltip: 'Edit Contact Information',
                      ),
                      child: _ContactCompact(lead: lead),
                    ),
                    const SizedBox(height: 12),
                    _StaticCard(
                      title: 'Preferred Project & Location',
                      action: IconButton(
                        onPressed: () =>
                            _showEditProjectLocationDialog(context, lead),
                        icon: const Icon(
                          FontAwesomeIcons.penToSquare,
                          size: 20,
                        ),
                        tooltip: 'Edit Project & Location',
                      ),
                      child: ProjectLocationCompact(leadId: lead.id),
                    ),
                    const SizedBox(height: 12),

                    CollapsibleCard(
                      title: 'Basic Details',
                      action: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (lead.status == LeadStatus.hot) ...<Widget>[
                            const Chip(
                              label: Text('HOT'),
                              labelStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              backgroundColor: Colors.red,
                              visualDensity: VisualDensity(
                                horizontal: -4,
                                vertical: -4,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            const SizedBox(width: 8),
                          ],
                          IconButton(
                            onPressed: () =>
                                _showEditBasicInfoDialog(context, lead),
                            icon: const Icon(
                              FontAwesomeIcons.penToSquare,
                              size: 20,
                            ),
                            tooltip: 'Edit Basic Details',
                          ),
                        ],
                      ),
                      child: BasicDetailsCard(lead: lead),
                    ),
                    const SizedBox(height: 12),

                    CollapsibleCard(
                      title: 'Professional Details',
                      action: IconButton(
                        onPressed: () =>
                            _showEditProfessionalInfoDialog(context, lead),
                        icon: const Icon(
                          FontAwesomeIcons.penToSquare,
                          size: 20,
                        ),
                        tooltip: 'Edit Professional Details',
                      ),
                      child: ProfessionalDetailsCard(lead: lead),
                    ),
                    const SizedBox(height: 12),

                    CollapsibleCard(
                      title: 'Permanent Address',
                      action: IconButton(
                        onPressed: () =>
                            _showEditPermanentAddressDialog(context, lead),
                        icon: const Icon(
                          FontAwesomeIcons.penToSquare,
                          size: 20,
                        ),
                        tooltip: 'Edit Permanent Address',
                      ),
                      child: PermanentAddressCard(lead: lead),
                    ),
                    const SizedBox(height: 12),

                    CollapsibleCard(
                      title: 'Requirements & Notes',
                      action: IconButton(
                        onPressed: () =>
                            _showEditRequirementsDialog(context, lead),
                        icon: const Icon(
                          FontAwesomeIcons.penToSquare,
                          size: 20,
                        ),
                        tooltip: 'Edit Requirements & Notes',
                      ),
                      child: RequirementNotesCard(leadId: lead.id),
                    ),
                    const SizedBox(height: 12),

                    CollapsibleCard(
                      title: 'Timeline',
                      child: TabbedTimelineCard(
                        key: _timelineKey,
                        leadId: lead.id,
                      ),
                    ),
                    const SizedBox(height: 12),
                    CollapsibleCard(
                      title: 'Activity & Assignment History',
                      child: ActivityCompact(leadId: lead.id),
                    ),
                    const SizedBox(height: 72),
                  ],
                ),
              ),
              // Cross Sell
              _lazyTab(1, CrossSellTab(leadId: lead.id)),
              // Reference
              _lazyTab(2, ReferenceTab(leadId: lead.id)),
              // Site Visit
              _lazyTab(3, SiteVisitTab(leadId: lead.id)),
              // Task
              _lazyTab(4, TaskTab(leadId: lead.id)),
              // Question
              _lazyTab(5, QuestionTab(leadId: lead.id)),
              // Property Option
              _lazyTab(6, const PropertyOptionTab()),
              // Ticket
              _lazyTab(7, TicketTab(leadId: lead.id)),
            ],
          );
        },
      ),
    );
  }

  // Show create booking dialog
  Future<void> _showCreateBookingDialog() async {
    try {
      // Get the lead data
      final lead = await _fetchLead();

      // Extract booking data from lead for pre-population
      final bookingData = _extractBookingDataFromLead(
        lead,
        supabase.Supabase.instance.client.auth.currentUser?.id ?? 'system',
        (supabase
                    .Supabase
                    .instance
                    .client
                    .auth
                    .currentUser
                    ?.userMetadata?['name']
                as String?) ??
            'System User',
      );

      if (!mounted) return;

      // Show booking form dialog
      await showDialog(
        context: context,
        builder: (context) => _CreateBookingDialog(
          lead: lead,
          prePopulatedData: bookingData,
          onBookingCreated: () {
            // Refresh lead data after booking creation
            refreshLead();
          },
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load lead data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Quick create booking without user interaction (used when sub-disposition is 'booking done')
  Future<void> _quickCreateBooking() async {
    try {
      final lead = await _fetchLead();
      final currentUser = supabase.Supabase.instance.client.auth.currentUser;
      final String userId = currentUser?.id ?? 'system';
      final String userName =
          (currentUser?.userMetadata?['name'] as String?) ?? 'System User';

      final Map<String, dynamic> data = _extractBookingDataFromLead(
        lead,
        userId,
        userName,
      );

      final BookingRepository bookingRepo = BookingRepository();

      // Provide safe defaults if any fields are missing
      final String projectId =
          (data['projectId'] as String?) ?? (lead.projectId ?? '');
      final String projectName =
          (data['projectName'] as String?) ??
          (lead.projectName?.isNotEmpty == true ? lead.projectName! : '');
      final String salesExecId =
          (data['salesExecutiveId'] as String?) ?? userId;
      final String salesExecName =
          (data['salesExecutiveName'] as String?) ?? userName;
      final String propertyType =
          (data['propertyType'] as String?) ?? 'residential';
      final String category = (data['category'] as String?) ?? 'b';
      final double bookingAmount = (data['bookingAmount'] as double?) ?? 0.0;
      final double? advanceAmount = (data['advanceAmount'] as double?);
      final double? balanceAmount = (data['balanceAmount'] as double?);
      final String unitNo = (data['unitNo'] as String?) ?? '';
      final String unitDetails = (data['unitDetails'] as String?) ?? '';
      final PaymentMode paymentMode =
          (data['paymentMode'] as PaymentMode?) ?? PaymentMode.cash;
      final BookingStatus status =
          (data['status'] as BookingStatus?) ?? BookingStatus.confirmed;
      final DateTime bookingDate =
          (data['bookingDate'] as DateTime?) ?? DateTime.now();

      await bookingRepo.createBooking(
        customerId: lead.id,
        customerName: lead.customerName,
        customerEmail: lead.email ?? '',
        customerPhone: lead.phone,
        leadId: lead.leadId,
        projectId: projectId,
        projectName: projectName,
        propertyType: propertyType,
        category: category,
        unitNo: unitNo,
        unitDetails: unitDetails,
        bookingAmount: bookingAmount,
        advanceAmount: advanceAmount,
        balanceAmount: balanceAmount,
        paymentMode: paymentMode,
        paymentReference: null,
        salesExecutiveId: salesExecId,
        salesExecutiveName: salesExecName,
        commission: (data['commission'] as double?) ?? 0.0,
        approvedBy: userName,
        approvedById: userId,
        status: status,
        bookingDate: bookingDate,
        possessionDate: data['possessionDate'] as DateTime?,
        notes:
            (data['notes'] as String?) ??
            'Auto-created from disposition: Booking Done',
        termsAndConditions: (data['termsAndConditions'] as String?) ?? '',
        documents: <String>[],
        createdBy: userId,
        createdByName: userName,
        customFields: data['customFields'] as Map<String, dynamic>?,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking created (Booking Done)'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to auto-create booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Extract booking data from lead
  Map<String, dynamic> _extractBookingDataFromLead(
    Lead lead,
    String performedBy,
    String performedByName,
  ) {
    // Get current user info for sales executive
    final currentUser = supabase.Supabase.instance.client.auth.currentUser;
    final String userId = currentUser?.id ?? 'system';
    final String userName =
        (currentUser?.userMetadata?['name'] as String?) ?? 'System User';

    // Calculate booking amount based on budget range or use default
    double bookingAmount = 100000.0; // Default booking amount
    if (lead.budgetRange != null && lead.budgetRange!.isNotEmpty) {
      // Extract numeric value from budget range (e.g., "10-15 Lakhs" -> 1250000)
      final budgetMatch = RegExp(
        r'(\d+(?:\.\d+)?)',
      ).firstMatch(lead.budgetRange!);
      if (budgetMatch != null) {
        final budgetValue = double.parse(budgetMatch.group(1)!);
        if (lead.budgetRange!.toLowerCase().contains('lakh')) {
          bookingAmount = budgetValue * 100000; // Convert lakhs to rupees
        } else if (lead.budgetRange!.toLowerCase().contains('crore')) {
          bookingAmount = budgetValue * 10000000; // Convert crores to rupees
        } else {
          bookingAmount = budgetValue;
        }
      }
    }

    // Calculate advance amount (typically 10% of booking amount)
    final advanceAmount = bookingAmount * 0.1;
    final balanceAmount = bookingAmount - advanceAmount;

    // Calculate commission (typically 2% of booking amount)
    final commission = bookingAmount * 0.02;

    return {
      'customerName': lead.customerName,
      'customerEmail': lead.email,
      'customerPhone': lead.phone,
      'projectId': lead.projectId ?? 'default-project',
      'projectName': lead.projectName ?? 'Default Project',
      'propertyType': lead.propertyType.name,
      'category': lead.categoryType.name,
      'unitNo': 'TBD', // To be determined
      'unitDetails': lead.requirements ?? 'Unit details to be finalized',
      'bookingAmount': bookingAmount,
      'advanceAmount': advanceAmount,
      'balanceAmount': balanceAmount,
      'paymentMode': PaymentMode.cash, // Default payment mode
      'paymentReference': null,
      'salesExecutiveId': lead.assignedTo.isNotEmpty ? lead.assignedTo : userId,
      'salesExecutiveName': lead.assignedToName.isNotEmpty
          ? lead.assignedToName
          : userName,
      'commission': commission,
      'approvedBy': performedByName,
      'approvedById': performedBy,
      'status': BookingStatus.confirmed,
      'bookingDate': DateTime.now(),
      'possessionDate': null, // To be determined later
      'notes':
          'Booking created automatically from lead disposition: ${lead.leadId}',
      'termsAndConditions': 'Standard terms and conditions apply',
      'documents': <String>[],
      'customFields': {
        'lead_source': lead.source.name,
        'lead_created_at': lead.createdAt.toIso8601String(),
        'original_budget_range': lead.budgetRange,
        'lead_requirements': lead.requirements,
      },
    };
  }

  // Missing method implementations
  Widget _IconAction({
    required String assetPng,
    required String tooltip,
    required VoidCallback onTap,
    double rotateTurns = 0,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Transform.rotate(
            angle: rotateTurns * math.pi,
            child: Image.asset(
              assetPng,
              width: 24,
              height: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _promptPhone(BuildContext context, {String? initial}) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Phone Number'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email, String leadId) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        query: 'subject=Regarding Lead $leadId',
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not launch email';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to open email: $e')));
      }
    }
  }

  Future<void> _launchSms(String phone, String leadId) async {
    try {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phone,
        query: 'body=Regarding Lead $leadId',
      );
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        throw 'Could not launch SMS';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to open SMS: $e')));
      }
    }
  }

  Future<void> _launchWhatsApp(String phone, String leadId) async {
    try {
      final Uri whatsappUri = Uri.parse(
        'https://wa.me/$phone?text=Regarding Lead $leadId',
      );
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else {
        throw 'Could not launch WhatsApp';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to open WhatsApp: $e')));
      }
    }
  }

  Future<void> _launchWhatsAppWeb(String phone, String leadId) async {
    try {
      final Uri whatsappWebUri = Uri.parse(
        'https://web.whatsapp.com/send?phone=$phone&text=Regarding Lead $leadId',
      );
      if (await canLaunchUrl(whatsappWebUri)) {
        await launchUrl(whatsappWebUri);
      } else {
        throw 'Could not launch WhatsApp Web';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open WhatsApp Web: $e')),
        );
      }
    }
  }

  void _showEditContactDialog(BuildContext context, Lead lead) {
    showDialog(
      context: context,
      builder: (context) => _EditContactDialog(lead: lead),
    );
  }

  void _showEditBasicInfoDialog(BuildContext context, Lead lead) {
    showDialog(
      context: context,
      builder: (context) => _EditBasicInfoDialog(lead: lead),
    );
  }

  void _showEditProfessionalInfoDialog(BuildContext context, Lead lead) {
    showDialog(
      context: context,
      builder: (context) => _EditProfessionalInfoDialog(lead: lead),
    );
  }

  void _showEditPermanentAddressDialog(BuildContext context, Lead lead) {
    showDialog(
      context: context,
      builder: (context) => _EditPermanentAddressDialog(lead: lead),
    );
  }

  void _showEditRequirementsDialog(BuildContext context, Lead lead) {
    showDialog(
      context: context,
      builder: (context) => _EditRequirementsDialog(lead: lead),
    );
  }

  void _showEditProjectLocationDialog(BuildContext context, Lead lead) {
    showDialog(
      context: context,
      builder: (context) => _EditProjectLocationDialog(lead: lead),
    );
  }
}

class _EditContactDialog extends StatefulWidget {
  const _EditContactDialog({required this.lead});
  final Lead lead;

  @override
  State<_EditContactDialog> createState() => _EditContactDialogState();
}

class _EditContactDialogState extends State<_EditContactDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _alternatePhoneController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Parse the name or customerName into first, middle, last
    final nameParts = (widget.lead.name ?? widget.lead.customerName)
        .trim()
        .split(' ');
    _firstNameController = TextEditingController(
      text: nameParts.isNotEmpty ? nameParts[0] : '',
    );
    _middleNameController = TextEditingController(
      text: nameParts.length > 2 ? nameParts[1] : '',
    );
    _lastNameController = TextEditingController(
      text: nameParts.length > 1 ? nameParts.last : '',
    );
    _emailController = TextEditingController(text: widget.lead.email);
    _phoneController = TextEditingController(text: widget.lead.phone);
    _alternatePhoneController = TextEditingController(
      text: widget.lead.alternatePhone ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _alternatePhoneController.dispose();
    super.dispose();
  }

  Future<void> _saveContactInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Construct full name
      final parts = [_firstNameController.text.trim()];
      if (_middleNameController.text.trim().isNotEmpty) {
        parts.add(_middleNameController.text.trim());
      }
      if (_lastNameController.text.trim().isNotEmpty) {
        parts.add(_lastNameController.text.trim());
      }
      final fullName = parts.join(' ');

      await DatabaseService.patchLead(widget.lead.id, {
        'name': fullName,
        'customer_name': fullName,
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'alternate_phone': _alternatePhoneController.text.trim().isNotEmpty
            ? _alternatePhoneController.text.trim()
            : null,
      });

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact information updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the lead data
        final parent = context
            .findAncestorStateOfType<_LeadDetailScreenState>();
        if (parent != null) {
          parent.refreshLead();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update contact information: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      scrollable: true,
      title: const Text('Edit Contact Information'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, minWidth: 360),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _middleNameController,
                decoration: const InputDecoration(
                  labelText: 'Middle Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _alternatePhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Alternate Phone Number',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveContactInfo,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}

class _EditBasicInfoDialog extends StatefulWidget {
  const _EditBasicInfoDialog({required this.lead});
  final Lead lead;

  @override
  State<_EditBasicInfoDialog> createState() => _EditBasicInfoDialogState();
}

class _EditBasicInfoDialogState extends State<_EditBasicInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _dobController;
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  late TextEditingController _maritalStatusController;
  DateTime? _selectedDob;

  List<GenderMaster> _genders = [];
  List<MaritalStatusMaster> _maritalStatuses = [];
  bool _isLoading = false;
  bool _isLoadingMasterData = true;

  @override
  void initState() {
    super.initState();
    _dobController = TextEditingController(
      text: widget.lead.dob?.toIso8601String().split('T')[0] ?? '',
    );
    _ageController = TextEditingController(
      text: widget.lead.age?.toString() ?? '',
    );
    _genderController = TextEditingController(text: widget.lead.gender ?? '');
    _maritalStatusController = TextEditingController(
      text: widget.lead.maritalStatus ?? '',
    );
    _selectedDob = widget.lead.dob;
    _loadMasterData();
  }

  Future<void> _loadMasterData() async {
    try {
      final results = await Future.wait([
        MasterDataService.getGenderMaster(),
        MasterDataService.getMaritalStatusMaster(),
      ]);
      if (!mounted) return;
      setState(() {
        _genders = results[0] as List<GenderMaster>;
        _maritalStatuses = results[1] as List<MaritalStatusMaster>;
        _isLoadingMasterData = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingMasterData = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = picked.toIso8601String().split('T')[0];
        final now = DateTime.now();
        int age = now.year - picked.year;
        if (now.month < picked.month ||
            (now.month == picked.month && now.day < picked.day)) {
          age--;
        }
        _ageController.text = age.toString();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await DatabaseService.patchLead(widget.lead.id, {
        'dob': _selectedDob?.toIso8601String().split('T')[0],
        'age': _ageController.text.trim().isNotEmpty
            ? int.tryParse(_ageController.text.trim())
            : null,
        'gender': _genderController.text.trim().isNotEmpty
            ? _genderController.text.trim()
            : null,
        'marital_status': _maritalStatusController.text.trim().isNotEmpty
            ? _maritalStatusController.text.trim()
            : null,
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Basic information updated'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update basic info: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      scrollable: true,
      title: const Text('Edit Basic Information'),
      content: _isLoadingMasterData
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640, minWidth: 360),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: _selectDate,
                      child: const InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Date of Birth',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _dobController.text.isEmpty
                          ? 'Select Date'
                          : _dobController.text,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final age = int.tryParse(value);
                          if (age == null || age < 0 || age > 120) {
                            return 'Enter valid age';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _genderController.text.isEmpty
                          ? null
                          : _genderController.text,
                      items: _genders
                          .map(
                            (g) => DropdownMenuItem(
                              value: g.name,
                              child: Text(g.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _genderController.text = v ?? ''),
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _maritalStatusController.text.isEmpty
                          ? null
                          : _maritalStatusController.text,
                      items: _maritalStatuses
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.name,
                              child: Text(s.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(
                        () => _maritalStatusController.text = v ?? '',
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Marital Status',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}

class _EditProfessionalInfoDialog extends StatefulWidget {
  const _EditProfessionalInfoDialog({required this.lead});
  final Lead lead;

  @override
  State<_EditProfessionalInfoDialog> createState() =>
      _EditProfessionalInfoDialogState();
}

class _EditProfessionalInfoDialogState
    extends State<_EditProfessionalInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _employmentTypeController;
  late TextEditingController _itrFilingStatusController;
  late TextEditingController _occupationController;
  bool _isLoading = false;
  bool _isLoadingMasterData = true;
  List<EmploymentTypeMaster> _employmentTypes = [];
  List<ItrFilingStatusMaster> _itrFilingStatuses = [];

  @override
  void initState() {
    super.initState();
    _employmentTypeController = TextEditingController(
      text: widget.lead.employmentType ?? '',
    );
    _itrFilingStatusController = TextEditingController(
      text: widget.lead.itrFilingStatus ?? '',
    );
    _occupationController = TextEditingController(
      text: widget.lead.occupation ?? '',
    );
    _loadMasterData();
  }

  Future<void> _loadMasterData() async {
    try {
      final results = await Future.wait([
        MasterDataService.getEmploymentTypeMaster(),
        MasterDataService.getItrFilingStatusMaster(),
      ]);
      if (!mounted) return;
      setState(() {
        _employmentTypes = results[0] as List<EmploymentTypeMaster>;
        _itrFilingStatuses = results[1] as List<ItrFilingStatusMaster>;
        _isLoadingMasterData = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMasterData = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await DatabaseService.patchLead(widget.lead.id, {
        'employment_type': _employmentTypeController.text.trim().isNotEmpty
            ? _employmentTypeController.text.trim()
            : null,
        'itr_filing_status': _itrFilingStatusController.text.trim().isNotEmpty
            ? _itrFilingStatusController.text.trim()
            : null,
        'occupation': _occupationController.text.trim().isNotEmpty
            ? _occupationController.text.trim()
            : null,
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Professional information updated'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update professional info: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      scrollable: true,
      title: const Text('Edit Professional Information'),
      content: _isLoadingMasterData
          ? const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            )
          : ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640, minWidth: 360),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _employmentTypeController.text.isEmpty
                          ? null
                          : _employmentTypeController.text,
                      items: _employmentTypes
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e.name,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(
                        () => _employmentTypeController.text = v ?? '',
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Employment Type',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _itrFilingStatusController.text.isEmpty
                          ? null
                          : _itrFilingStatusController.text,
                      items: _itrFilingStatuses
                          .map(
                            (e) => DropdownMenuItem<String>(
                              value: e.name,
                              child: Text(e.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(
                        () => _itrFilingStatusController.text = v ?? '',
                      ),
                      decoration: const InputDecoration(
                        labelText: 'ITR Filing Status',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _occupationController,
                      decoration: const InputDecoration(
                        labelText: 'Occupation',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}

class _EditPermanentAddressDialog extends StatefulWidget {
  const _EditPermanentAddressDialog({required this.lead});
  final Lead lead;

  @override
  State<_EditPermanentAddressDialog> createState() =>
      _EditPermanentAddressDialogState();
}

class _EditPermanentAddressDialogState
    extends State<_EditPermanentAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _countryController;
  late TextEditingController _locationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController(text: widget.lead.address ?? '');
    _cityController = TextEditingController(text: widget.lead.city ?? '');
    _stateController = TextEditingController(text: widget.lead.state ?? '');
    _pincodeController = TextEditingController(text: widget.lead.pincode ?? '');
    _countryController = TextEditingController(text: widget.lead.country ?? '');
    _locationController = TextEditingController(
      text: widget.lead.location ?? '',
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _countryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await DatabaseService.patchLead(widget.lead.id, {
        'address': _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        'city': _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        'state_name': _stateController.text.trim().isNotEmpty
            ? _stateController.text.trim()
            : null,
        'pincode': _pincodeController.text.trim().isNotEmpty
            ? _pincodeController.text.trim()
            : null,
        'country': _countryController.text.trim().isNotEmpty
            ? _countryController.text.trim()
            : null,
        'location': _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
      });
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permanent address updated'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update address: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      scrollable: true,
      title: const Text('Edit Permanent Address'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, minWidth: 360),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _addressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(
                  labelText: 'State',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Pincode',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final bool isSixDigits =
                        value.length == 6 && int.tryParse(value) != null;
                    if (!isSixDigits) return 'Enter valid 6-digit pincode';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}

class _EditRequirementsDialog extends StatefulWidget {
  const _EditRequirementsDialog({required this.lead});
  final Lead lead;

  @override
  State<_EditRequirementsDialog> createState() =>
      _EditRequirementsDialogState();
}

class _EditRequirementsDialogState extends State<_EditRequirementsDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _requirementsController;
  late TextEditingController _notesController;
  String? _selectedBudget;
  List<BudgetMaster> _budgets = [];
  bool _isLoadingBudgets = true;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requirementsController = TextEditingController(
      text: widget.lead.requirements ?? '',
    );
    _notesController = TextEditingController(text: widget.lead.notes ?? '');
    _selectedBudget = widget.lead.budgetRange;
    _loadBudgets();
  }

  @override
  void dispose() {
    _requirementsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadBudgets() async {
    try {
      final List<BudgetMaster> budgets =
          await MasterDataService.getBudgetMaster();
      if (!mounted) return;
      setState(() {
        _budgets = budgets;
        _isLoadingBudgets = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingBudgets = false;
      });
    }
  }

  Future<void> _saveRequirements() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseService.patchLead(widget.lead.id, {
        'requirements': _requirementsController.text.trim().isNotEmpty
            ? _requirementsController.text.trim()
            : null,
        'notes': _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        'budget_range':
            (_selectedBudget != null && _selectedBudget!.trim().isNotEmpty)
            ? _selectedBudget!.trim()
            : null,
      });

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Requirements and notes updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the lead data
        final parent = context
            .findAncestorStateOfType<_LeadDetailScreenState>();
        if (parent != null) {
          parent.refreshLead();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update requirements and notes: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      scrollable: true,
      title: const Text('Edit Requirements & Notes'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, minWidth: 360),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _isLoadingBudgets
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      initialValue:
                          (_selectedBudget != null &&
                              _selectedBudget!.isNotEmpty)
                          ? _selectedBudget
                          : null,
                      items: _budgets
                          .map(
                            (b) => DropdownMenuItem<String>(
                              value: b.name,
                              child: Text(b.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _selectedBudget = v),
                      decoration: const InputDecoration(
                        labelText: 'Budget Range',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _requirementsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Requirements',
                  hintText: 'Describe the customer requirements...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Add any additional notes...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveRequirements,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}

class _EditProjectLocationDialog extends StatefulWidget {
  const _EditProjectLocationDialog({required this.lead});
  final Lead lead;

  @override
  State<_EditProjectLocationDialog> createState() =>
      _EditProjectLocationDialogState();
}

class _EditProjectLocationDialogState
    extends State<_EditProjectLocationDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _projectNameController;
  late TextEditingController _locationController;
  late TextEditingController _budgetRangeController;

  String? _selectedProjectId;
  String? _selectedPropertyType;
  String? _selectedCategoryType;

  bool _isLoading = false;
  List<Map<String, dynamic>> _projects = [];
  bool _projectsLoaded = false;

  @override
  void initState() {
    super.initState();
    _projectNameController = TextEditingController(
      text: widget.lead.projectName ?? '',
    );
    _locationController = TextEditingController(
      text: widget.lead.location ?? '',
    );
    _budgetRangeController = TextEditingController(
      text: widget.lead.budgetRange ?? '',
    );
    _selectedProjectId = widget.lead.projectId;
    _selectedPropertyType = widget.lead.propertyType.name;
    _selectedCategoryType = widget.lead.categoryType.name;
    _loadProjects();
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _locationController.dispose();
    _budgetRangeController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await LocationDataService.getProjects();
      setState(() {
        _projects = projects;
        _projectsLoaded = true;
      });
    } catch (e) {
      print('Error loading projects: $e');
      setState(() {
        _projectsLoaded = true;
      });
    }
  }

  Future<void> _saveProjectLocation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await DatabaseService.patchLead(widget.lead.id, {
        'project_id': _selectedProjectId,
        'project_name': _projectNameController.text.trim().isNotEmpty
            ? _projectNameController.text.trim()
            : null,
        'location': _locationController.text.trim().isNotEmpty
            ? _locationController.text.trim()
            : null,
        'budget_range': _budgetRangeController.text.trim().isNotEmpty
            ? _budgetRangeController.text.trim()
            : null,
        'property_type': _selectedPropertyType,
        'category_type': _selectedCategoryType,
      });

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project and location updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the lead data
        final parent = context
            .findAncestorStateOfType<_LeadDetailScreenState>();
        if (parent != null) {
          parent.refreshLead();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update project and location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      scrollable: true,
      title: const Text('Edit Project & Location'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, minWidth: 360),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Selection
              if (!_projectsLoaded)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<String>(
                  initialValue: _selectedProjectId,
                  decoration: const InputDecoration(
                    labelText: 'Select Project',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('No Project Selected'),
                    ),
                    ..._projects.map(
                      (project) => DropdownMenuItem<String>(
                        value: project['id'] as String,
                        child: Text(project['name'] as String),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedProjectId = value;
                      if (value != null) {
                        final project = _projects.firstWhere(
                          (p) => p['id'] == value,
                        );
                        _projectNameController.text = project['name'] as String;
                      } else {
                        _projectNameController.clear();
                      }
                    });
                  },
                ),
              const SizedBox(height: 16),

              // Project Name
              TextFormField(
                controller: _projectNameController,
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  hintText: 'Enter project name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home_work),
                ),
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter preferred location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),

              // Budget Range
              TextFormField(
                controller: _budgetRangeController,
                decoration: const InputDecoration(
                  labelText: 'Budget Range',
                  hintText: 'e.g., 50L - 1Cr',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 16),

              // Property Type
              DropdownButtonFormField<String>(
                initialValue: _selectedPropertyType,
                decoration: const InputDecoration(
                  labelText: 'Property Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: PropertyType.values
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type.name,
                        child: Text(type.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPropertyType = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Category Type
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryType,
                decoration: const InputDecoration(
                  labelText: 'Category Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                items: CategoryType.values
                    .map(
                      (type) => DropdownMenuItem<String>(
                        value: type.name,
                        child: Text(type.name.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryType = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveProjectLocation,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}

// Missing widget implementations
class _ContactCompact extends StatelessWidget {
  const _ContactCompact({required this.lead});
  final Lead lead;

  @override
  Widget build(BuildContext context) {
    final displayName = lead.name ?? lead.customerName;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Mobile Number', lead.phone),
            if (lead.alternatePhone != null && lead.alternatePhone!.isNotEmpty)
              _buildInfoRow(context, 'Alternate Number', lead.alternatePhone!),
            if (lead.email.isNotEmpty)
              _buildInfoRow(context, 'Email', lead.email),
            _buildInfoRow(context, 'Allocated To', lead.assignedToName),
            if (lead.location != null && lead.location!.isNotEmpty)
              _buildInfoRow(context, 'Customer Location', lead.location!),
            if (lead.budgetRange != null && lead.budgetRange!.isNotEmpty)
              _buildInfoRow(context, 'Purchase Plan', lead.budgetRange!),
            if (lead.nextFollowUpDate != null)
              _buildInfoRow(
                context,
                'Follow Up',
                lead.nextFollowUpDate!.toIso8601String().split('T')[0],
              )
            else if (lead.followUpCount > 0)
              _buildInfoRow(
                context,
                'Follow Up',
                '${lead.followUpCount} times',
              ),
            _buildInfoRow(context, 'Status', lead.status.name.toUpperCase()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _LazyProjectLocationCompact extends StatefulWidget {
  const _LazyProjectLocationCompact({required this.leadId});
  final String leadId;

  @override
  State<_LazyProjectLocationCompact> createState() =>
      _LazyProjectLocationCompactState();
}

class _LazyProjectLocationCompactState
    extends State<_LazyProjectLocationCompact> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Lead>(
      future: LeadRepository().getLead(widget.leadId).then((response) {
        if (response.success && response.data != null) {
          return response.data!;
        }
        throw Exception(response.error ?? 'Failed to load lead');
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final lead = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lead.categoryType.toString().split('.').last.isNotEmpty)
              _buildInfoRow(
                context,
                'Category',
                lead.categoryType.toString().split('.').last.toUpperCase(),
              ),
            if (lead.propertyType.toString().split('.').last.isNotEmpty)
              _buildInfoRow(
                context,
                'Property Type',
                lead.propertyType
                    .toString()
                    .split('.')
                    .last
                    .replaceAll('_', ' ')
                    .split(' ')
                    .map(
                      (word) =>
                          word[0].toUpperCase() +
                          word.substring(1).toLowerCase(),
                    )
                    .join(' '),
              ),
            if (lead.stateName != null && lead.stateName!.isNotEmpty)
              _buildInfoRow(context, 'State', lead.stateName!)
            else if (lead.state != null && lead.state!.isNotEmpty)
              _buildInfoRow(context, 'State', lead.state!),
            if (lead.city != null && lead.city!.isNotEmpty)
              _buildInfoRow(context, 'City', lead.city!),
            if (lead.location != null && lead.location!.isNotEmpty)
              _buildInfoRow(context, 'Location', lead.location!),
            if (lead.projectName != null && lead.projectName!.isNotEmpty)
              _buildInfoRow(context, 'Project Name', lead.projectName!),
            if (lead.budgetRange != null && lead.budgetRange!.isNotEmpty)
              _buildInfoRow(context, 'Budget', lead.budgetRange!),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// Basic Details Card
class _BasicDetailsCard extends StatelessWidget {
  const _BasicDetailsCard({required this.lead});
  final Lead lead;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lead.dob != null)
              _buildInfoRow(
                context,
                'Date of Birth',
                lead.dob!.toIso8601String().split('T')[0],
              ),
            if (lead.age != null)
              _buildInfoRow(context, 'Age', lead.age!.toString()),
            if (lead.gender != null && lead.gender!.isNotEmpty)
              _buildInfoRow(context, 'Gender', lead.gender!),
            if (lead.maritalStatus != null && lead.maritalStatus!.isNotEmpty)
              _buildInfoRow(context, 'Marital Status', lead.maritalStatus!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// Professional Details Card
class _ProfessionalDetailsCard extends StatelessWidget {
  const _ProfessionalDetailsCard({required this.lead});
  final Lead lead;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lead.employmentType != null && lead.employmentType!.isNotEmpty)
              _buildInfoRow(context, 'Employment Type', lead.employmentType!),
            if (lead.itrFilingStatus != null &&
                lead.itrFilingStatus!.isNotEmpty)
              _buildInfoRow(
                context,
                'ITR Filing Status',
                lead.itrFilingStatus!,
              ),
            if (lead.occupation != null && lead.occupation!.isNotEmpty)
              _buildInfoRow(context, 'Occupation', lead.occupation!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// Permanent Address Card
class _PermanentAddressCard extends StatelessWidget {
  const _PermanentAddressCard({required this.lead});
  final Lead lead;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lead.address != null && lead.address!.isNotEmpty)
              _buildInfoRow(context, 'Address', lead.address!),
            if (lead.country != null && lead.country!.isNotEmpty)
              _buildInfoRow(context, 'Country', lead.country!),
            if (lead.stateName != null && lead.stateName!.isNotEmpty)
              _buildInfoRow(context, 'State', lead.stateName!)
            else if (lead.state != null && lead.state!.isNotEmpty)
              _buildInfoRow(context, 'State', lead.state!),
            if (lead.city != null && lead.city!.isNotEmpty)
              _buildInfoRow(context, 'City', lead.city!),
            if (lead.location != null && lead.location!.isNotEmpty)
              _buildInfoRow(context, 'Location', lead.location!),
            if (lead.pincode != null && lead.pincode!.isNotEmpty)
              _buildInfoRow(context, 'Pincode', lead.pincode!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _RequirementNotesCard extends StatefulWidget {
  const _RequirementNotesCard({required this.leadId});
  final String leadId;

  @override
  State<_RequirementNotesCard> createState() => _RequirementNotesCardState();
}

class _RequirementNotesCardState extends State<_RequirementNotesCard> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Lead>(
      future: LeadRepository().getLead(widget.leadId).then((response) {
        if (response.success && response.data != null) {
          return response.data!;
        }
        throw Exception(response.error ?? 'Failed to load lead');
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        final lead = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lead.requirements != null && lead.requirements!.isNotEmpty) ...[
              Text(
                'Requirements:',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(lead.requirements!),
              const SizedBox(height: 12),
            ],
            Text(
              'Notes:',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'No additional notes available.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        );
      },
    );
  }
}

class _ActivityCompact extends StatefulWidget {
  const _ActivityCompact({required this.leadId});
  final String leadId;

  @override
  State<_ActivityCompact> createState() => _ActivityCompactState();
}

class _ActivityCompactState extends State<_ActivityCompact> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: LeadRepository().getLeadTimeline(widget.leadId).then((
                response,
              ) {
                return response.data ?? [];
              }),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final activities = snapshot.data ?? [];
                if (activities.isEmpty) {
                  return const Text('No recent activity');
                }
                return Column(
                  children: activities.take(5).map((activity) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            _getActivityIcon(activity['type'] as String? ?? ''),
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              activity['description'] as String? ??
                                  'No description',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          Text(
                            _formatActivityTime(
                              activity['created_at'] as String? ?? '',
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'call':
      case 'call_initiated':
        return FontAwesomeIcons.phone;
      case 'email':
        return FontAwesomeIcons.envelope;
      case 'sms':
        return FontAwesomeIcons.message;
      case 'whatsapp':
        return FontAwesomeIcons.whatsapp;
      case 'disposition_change':
        return FontAwesomeIcons.arrowRotateRight;
      default:
        return FontAwesomeIcons.circle;
    }
  }

  String _formatActivityTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateTimeString;
    }
  }
}

class _CollapsibleCard extends StatefulWidget {
  const _CollapsibleCard({
    required this.title,
    required this.child,
    this.action,
  });
  final String title;
  final Widget child;
  final Widget? action;
  @override
  State<_CollapsibleCard> createState() => _CollapsibleCardState();
}

class _StaticCard extends StatelessWidget {
  const _StaticCard({required this.title, required this.child, this.action});
  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (action != null) ...[action!, const SizedBox(width: 8)],
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 12),
                child: Divider(color: primary.withOpacity(0.15), height: 1),
              ),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

class _LazyCollapsibleCard extends StatefulWidget {
  const _LazyCollapsibleCard({required this.title, required this.childBuilder});
  final String title;
  final Widget Function() childBuilder;
  @override
  State<_LazyCollapsibleCard> createState() => _LazyCollapsibleCardState();
}

class _LazyCollapsibleCardState extends State<_LazyCollapsibleCard> {
  late bool expanded = false;
  Widget? _cachedChild;
  bool _hasLoaded = false;

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  setState(() {
                    expanded = !expanded;
                    if (expanded && !_hasLoaded) {
                      _cachedChild = widget.childBuilder();
                      _hasLoaded = true;
                    }
                  });
                },
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Icon(
                      expanded
                          ? FontAwesomeIcons.chevronUp
                          : FontAwesomeIcons.chevronDown,
                    ),
                  ],
                ),
              ),
              if (expanded) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 12),
                  child: Divider(color: primary.withOpacity(0.15), height: 1),
                ),
                _cachedChild ?? const SizedBox.shrink(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CreateBookingDialog extends StatefulWidget {
  final Lead lead;
  final Map<String, dynamic> prePopulatedData;
  final VoidCallback onBookingCreated;

  const _CreateBookingDialog({
    required this.lead,
    required this.prePopulatedData,
    required this.onBookingCreated,
  });

  @override
  State<_CreateBookingDialog> createState() => _CreateBookingDialogState();
}

class _CreateBookingDialogState extends State<_CreateBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final BookingRepository _bookingRepository = BookingRepository();

  // Form controllers
  late TextEditingController _customerNameController;
  late TextEditingController _customerEmailController;
  late TextEditingController _customerPhoneController;
  late TextEditingController _projectNameController;
  late TextEditingController _unitNoController;
  late TextEditingController _unitDetailsController;
  late TextEditingController _bookingAmountController;
  late TextEditingController _advanceAmountController;
  late TextEditingController _balanceAmountController;
  late TextEditingController _commissionController;
  late TextEditingController _salesExecutiveController;
  late TextEditingController _approvedByController;
  late TextEditingController _notesController;
  late TextEditingController _termsController;

  // Form values
  String _propertyType = 'residential';
  String _category = 'b';
  PaymentMode _paymentMode = PaymentMode.cash;
  BookingStatus _status = BookingStatus.confirmed;
  DateTime _bookingDate = DateTime.now();
  DateTime? _possessionDate;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _customerNameController = TextEditingController(
      text: widget.prePopulatedData['customerName'],
    );
    _customerEmailController = TextEditingController(
      text: widget.prePopulatedData['customerEmail'],
    );
    _customerPhoneController = TextEditingController(
      text: widget.prePopulatedData['customerPhone'],
    );
    _projectNameController = TextEditingController(
      text: widget.prePopulatedData['projectName'],
    );
    _unitNoController = TextEditingController(
      text: widget.prePopulatedData['unitNo'],
    );
    _unitDetailsController = TextEditingController(
      text: widget.prePopulatedData['unitDetails'],
    );
    _bookingAmountController = TextEditingController(
      text: widget.prePopulatedData['bookingAmount'].toString(),
    );
    _advanceAmountController = TextEditingController(
      text: widget.prePopulatedData['advanceAmount'].toString(),
    );
    _balanceAmountController = TextEditingController(
      text: widget.prePopulatedData['balanceAmount'].toString(),
    );
    _commissionController = TextEditingController(
      text: widget.prePopulatedData['commission'].toString(),
    );
    _salesExecutiveController = TextEditingController(
      text: widget.prePopulatedData['salesExecutiveName'],
    );
    _approvedByController = TextEditingController(
      text: widget.prePopulatedData['approvedBy'],
    );
    _notesController = TextEditingController(
      text: widget.prePopulatedData['notes'],
    );
    _termsController = TextEditingController(
      text: widget.prePopulatedData['termsAndConditions'],
    );

    _propertyType = widget.prePopulatedData['propertyType'];
    _category = widget.prePopulatedData['category'];
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerEmailController.dispose();
    _customerPhoneController.dispose();
    _projectNameController.dispose();
    _unitNoController.dispose();
    _unitDetailsController.dispose();
    _bookingAmountController.dispose();
    _advanceAmountController.dispose();
    _balanceAmountController.dispose();
    _commissionController.dispose();
    _salesExecutiveController.dispose();
    _approvedByController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.book_online, size: 28, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Create Booking - ${widget.lead.leadId}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),

            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Information Section
                      _buildSectionHeader('Customer Information', Icons.person),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _customerNameController,
                              decoration: const InputDecoration(
                                labelText: 'Customer Name *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Customer name is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _customerEmailController,
                              decoration: const InputDecoration(
                                labelText: 'Email *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _customerPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone number is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      // Property Information Section
                      _buildSectionHeader('Property Information', Icons.home),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _propertyType,
                              decoration: const InputDecoration(
                                labelText: 'Property Type *',
                                border: OutlineInputBorder(),
                              ),
                              items: PropertyType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type.name,
                                  child: Text(type.name.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _propertyType = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _category,
                              decoration: const InputDecoration(
                                labelText: 'Category *',
                                border: OutlineInputBorder(),
                              ),
                              items: CategoryType.values.map((category) {
                                return DropdownMenuItem(
                                  value: category.name,
                                  child: Text(category.name.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _category = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _projectNameController,
                              decoration: const InputDecoration(
                                labelText: 'Project Name *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Project name is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _unitNoController,
                              decoration: const InputDecoration(
                                labelText: 'Unit Number',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _unitDetailsController,
                        decoration: const InputDecoration(
                          labelText: 'Unit Details',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 24),

                      // Financial Information Section
                      _buildSectionHeader(
                        'Financial Information',
                        Icons.attach_money,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _bookingAmountController,
                              decoration: const InputDecoration(
                                labelText: 'Booking Amount *',
                                prefixText: '₹ ',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Booking amount is required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Enter a valid amount';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                _calculateAmounts();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _advanceAmountController,
                              decoration: const InputDecoration(
                                labelText: 'Advance Amount',
                                prefixText: '₹ ',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _balanceAmountController,
                              decoration: const InputDecoration(
                                labelText: 'Balance Amount',
                                prefixText: '₹ ',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _commissionController,
                              decoration: const InputDecoration(
                                labelText: 'Commission',
                                prefixText: '₹ ',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Payment & Status Section
                      _buildSectionHeader('Payment & Status', Icons.payment),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<PaymentMode>(
                              initialValue: _paymentMode,
                              decoration: const InputDecoration(
                                labelText: 'Payment Mode *',
                                border: OutlineInputBorder(),
                              ),
                              items: PaymentMode.values.map((mode) {
                                return DropdownMenuItem(
                                  value: mode,
                                  child: Text(mode.name.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _paymentMode = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<BookingStatus>(
                              initialValue: _status,
                              decoration: const InputDecoration(
                                labelText: 'Status *',
                                border: OutlineInputBorder(),
                              ),
                              items: BookingStatus.values.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status.name.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _status = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _bookingDate,
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 30),
                                  ),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (date != null) {
                                  setState(() {
                                    _bookingDate = date;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Booking Date *',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(_formatDate(_bookingDate)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _possessionDate ??
                                      DateTime.now().add(
                                        const Duration(days: 365),
                                      ),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 2000),
                                  ),
                                );
                                if (date != null) {
                                  setState(() {
                                    _possessionDate = date;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Possession Date',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _possessionDate != null
                                      ? _formatDate(_possessionDate!)
                                      : 'Select Date',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Sales Information Section
                      _buildSectionHeader('Sales Information', Icons.sell),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _salesExecutiveController,
                              decoration: const InputDecoration(
                                labelText: 'Sales Executive *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Sales executive is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _approvedByController,
                              decoration: const InputDecoration(
                                labelText: 'Approved By *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Approved by is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Additional Information Section
                      _buildSectionHeader('Additional Information', Icons.note),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _termsController,
                        decoration: const InputDecoration(
                          labelText: 'Terms & Conditions',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _createBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Create Booking'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  void _calculateAmounts() {
    final bookingAmount = double.tryParse(_bookingAmountController.text);
    if (bookingAmount != null) {
      final advanceAmount = bookingAmount * 0.1;
      final balanceAmount = bookingAmount - advanceAmount;
      final commission = bookingAmount * 0.02;

      _advanceAmountController.text = advanceAmount.toStringAsFixed(2);
      _balanceAmountController.text = balanceAmount.toStringAsFixed(2);
      _commissionController.text = commission.toStringAsFixed(2);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _createBooking() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Get current user info
      final currentUser = supabase.Supabase.instance.client.auth.currentUser;
      final String userId = currentUser?.id ?? 'system';
      final String userName =
          (currentUser?.userMetadata?['name'] as String?) ?? 'System User';

      // Create booking
      await _bookingRepository.createBooking(
        customerId: widget.lead.id,
        customerName: _customerNameController.text,
        customerEmail: _customerEmailController.text,
        customerPhone: _customerPhoneController.text,
        leadId: widget.lead.leadId,
        projectId: widget.prePopulatedData['projectId'],
        projectName: _projectNameController.text,
        propertyType: _propertyType,
        category: _category,
        unitNo: _unitNoController.text,
        unitDetails: _unitDetailsController.text,
        bookingAmount: double.parse(_bookingAmountController.text),
        advanceAmount: double.tryParse(_advanceAmountController.text),
        balanceAmount: double.tryParse(_balanceAmountController.text),
        paymentMode: _paymentMode,
        paymentReference: null,
        salesExecutiveId: widget.prePopulatedData['salesExecutiveId'],
        salesExecutiveName: _salesExecutiveController.text,
        commission: double.parse(_commissionController.text),
        approvedBy: _approvedByController.text,
        approvedById: userId,
        status: _status,
        bookingDate: _bookingDate,
        possessionDate: _possessionDate,
        notes: _notesController.text,
        termsAndConditions: _termsController.text,
        documents: <String>[],
        createdBy: userId,
        createdByName: userName,
        customFields: widget.prePopulatedData['customFields'],
      );

      // Close dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Callback to refresh lead data
      widget.onBookingCreated();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _CollapsibleCardState extends State<_CollapsibleCard> {
  late bool expanded = false;
  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).colorScheme.primary;
    return Stack(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () => setState(() => expanded = !expanded),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (widget.action != null) ...[
                      widget.action!,
                      const SizedBox(width: 8),
                    ],
                    Icon(
                      expanded
                          ? FontAwesomeIcons.chevronUp
                          : FontAwesomeIcons.chevronDown,
                    ),
                  ],
                ),
              ),
              if (expanded) ...<Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 12),
                  child: Divider(color: primary.withOpacity(0.15), height: 1),
                ),
                widget.child,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// extracted Tabbed Timeline implementation moved to timeline/tabbed_timeline_card.dart

class CrossSellTab extends StatefulWidget {
  const CrossSellTab({super.key, required this.leadId});
  final String leadId;

  @override
  State<CrossSellTab> createState() => _CrossSellTabState();
}

class _CrossSellTabState extends State<CrossSellTab> {
  late Future<List<Map<String, dynamic>>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = DatabaseService.getLeadCrossSells(leadId: widget.leadId);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Cross Sell Opportunities',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _openAddSheet,
                icon: const Icon(FontAwesomeIcons.plus),
                label: const Text('Create'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _itemsFuture,
              builder:
                  (
                    BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
                  ) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text('Failed to load cross sells'),
                      );
                    }
                    final items = snapshot.data ?? <Map<String, dynamic>>[];
                    if (items.isEmpty) {
                      return const Center(child: Text('No cross sells yet'));
                    }
                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> it = items[index];
                        return _crossSellCard(context, it);
                      },
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }

  void _openAddSheet() {
    String category = '';
    String propertyType = '';
    String project = '';
    String? projectId;
    String allocatedTo = '';
    String? allocatedToId;
    final TextEditingController descCtrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModal) {
            return SingleChildScrollView(
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
                        'Create Cross Sell',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(FontAwesomeIcons.xmark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future:
                        masters.DatabaseServiceMasters.getPropertyCategories(),
                    builder:
                        (
                          BuildContext _,
                          AsyncSnapshot<List<Map<String, dynamic>>> snap,
                        ) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snap.hasError) {
                            return const Text('Failed to load categories');
                          }
                          final List<Map<String, dynamic>> cats =
                              snap.data ?? <Map<String, dynamic>>[];
                          return DropdownButtonFormField<String>(
                            initialValue: category.isEmpty ? null : category,
                            items: cats
                                .map(
                                  (Map<String, dynamic> c) =>
                                      DropdownMenuItem<String>(
                                        value: (c['name'] ?? '-') as String,
                                        child: Text(
                                          (c['name'] ?? '-') as String,
                                        ),
                                      ),
                                )
                                .toList(),
                            onChanged: (String? v) =>
                                setModal(() => category = v ?? category),
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: masters.DatabaseServiceMasters.getPropertyTypes(),
                    builder:
                        (
                          BuildContext _,
                          AsyncSnapshot<List<Map<String, dynamic>>> snap,
                        ) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snap.hasError) {
                            return const Text('Failed to load property types');
                          }
                          final List<Map<String, dynamic>> types =
                              snap.data ?? <Map<String, dynamic>>[];
                          return DropdownButtonFormField<String>(
                            initialValue: propertyType.isEmpty
                                ? null
                                : propertyType,
                            items: types
                                .map(
                                  (Map<String, dynamic> t) =>
                                      DropdownMenuItem<String>(
                                        value: (t['name'] ?? '-') as String,
                                        child: Text(
                                          (t['name'] ?? '-') as String,
                                        ),
                                      ),
                                )
                                .toList(),
                            onChanged: (String? v) => setModal(
                              () => propertyType = v ?? propertyType,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Property Type',
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Project>>(
                    future: DatabaseService.getProjects(limit: 200),
                    builder:
                        (BuildContext _, AsyncSnapshot<List<Project>> snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snap.hasError) {
                            return const Text('Failed to load projects');
                          }
                          final List<Project> projs = snap.data ?? <Project>[];
                          return DropdownButtonFormField<String>(
                            initialValue: projectId,
                            items: projs
                                .map(
                                  (Project p) => DropdownMenuItem<String>(
                                    value: p.id,
                                    child: Text(p.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (String? v) => setModal(() {
                              projectId = v;
                              Project? selected;
                              if (v != null) {
                                for (final Project e in projs) {
                                  if (e.id == v) {
                                    selected = e;
                                    break;
                                  }
                                }
                              }
                              project = selected?.name ?? '';
                            }),
                            decoration: const InputDecoration(
                              labelText: 'Project Name',
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getAssignableUsers(),
                    builder:
                        (
                          BuildContext _,
                          AsyncSnapshot<List<Map<String, dynamic>>> snap,
                        ) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snap.hasError) {
                            return const Text('Failed to load assignees');
                          }
                          final List<Map<String, dynamic>> users =
                              snap.data ?? <Map<String, dynamic>>[];
                          return DropdownButtonFormField<String>(
                            initialValue: allocatedToId,
                            items: users
                                .map(
                                  (Map<String, dynamic> u) =>
                                      DropdownMenuItem<String>(
                                        value: (u['id'] ?? '') as String,
                                        child: Text(
                                          (u['name'] ?? '-') as String,
                                        ),
                                      ),
                                )
                                .toList(),
                            onChanged: (String? v) => setModal(() {
                              allocatedToId = v;
                              final Map<String, dynamic> user = users
                                  .firstWhere(
                                    (Map<String, dynamic> e) => e['id'] == v,
                                    orElse: () => <String, dynamic>{},
                                  );
                              allocatedTo = (user['name'] ?? '-') as String;
                            }),
                            decoration: const InputDecoration(
                              labelText: 'Assigned To',
                              border: OutlineInputBorder(),
                            ),
                          );
                        },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        try {
                          // Auto-create a minimal linked lead based on context
                          final String inferredName = [
                            project.trim().isEmpty ? null : project.trim(),
                            category.trim().isEmpty ? null : category.trim(),
                            propertyType.trim().isEmpty
                                ? null
                                : propertyType.trim(),
                          ].whereType<String>().join(' ');
                          final Lead linkedLead =
                              await DatabaseService.createLeadMinimal(
                                customerName: inferredName.isEmpty
                                    ? 'Cross-sell Lead'
                                    : 'Cross-sell: $inferredName',
                                source: LeadSource.referral,
                              );

                          await DatabaseService.createLeadCrossSell(
                            leadId: widget.leadId,
                            category: category,
                            propertyType: propertyType,
                            projectId: projectId,
                            projectName: project,
                            assignedToName: allocatedTo,
                            assignedToId: allocatedToId,
                            description: descCtrl.text.trim(),
                            linkedLeadId: linkedLead.id,
                          );
                          if (!mounted) return;
                          setState(() {
                            _itemsFuture = DatabaseService.getLeadCrossSells(
                              leadId: widget.leadId,
                            );
                          });
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.circleCheck,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '✅ Cross sell created successfully! A new lead has been linked.',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 4),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Failed: $e')));
                        }
                      },
                      icon: const Icon(FontAwesomeIcons.check),
                      label: const Text('Create'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _crossSellCard(BuildContext context, Map<String, dynamic> it) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
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
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  (it['project_name'] ?? it['project'] ?? '-') as String,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.60),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.30),
                  ),
                ),
                child: Text(
                  (it['category'] ?? '-') as String,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: <Widget>[
              const Icon(FontAwesomeIcons.building, size: 14),
              const SizedBox(width: 6),
              Text(
                (it['property_type'] ?? it['propertyType'] ?? '-') as String,
              ),
              const SizedBox(width: 12),
              const Icon(FontAwesomeIcons.user, size: 14),
              const SizedBox(width: 6),
              Text(
                'Assigned: ${(it['assigned_to_name'] ?? it['assignedTo'] ?? '-') as String}',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            (it['description'] ?? '-') as String,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Helper method for getting assignable users
  Future<List<Map<String, dynamic>>> _getAssignableUsers() async {
    try {
      final client = supabase.Supabase.instance.client;
      final response = await client
          .from('users')
          .select('id,name,email,role,is_active')
          .eq('is_active', true)
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching assignable users: $e');
      return [];
    }
  }
}
