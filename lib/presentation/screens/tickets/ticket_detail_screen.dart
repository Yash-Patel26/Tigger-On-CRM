import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../../data/services/database_service.dart';
import '../../../data/models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../widgets/ticket_widgets/dispose_ticket_dialog.dart';
import '../../widgets/ticket_widgets/assign_ticket_dialog.dart';

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({super.key, required this.ticket});

  final Ticket ticket;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen>
    with TickerProviderStateMixin {
  late TabController _infoTabController;
  late TabController _logsTabController;
  late Ticket _ticket;
  Lead? _lead;
  bool _isLoadingLead = true;
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _dispositionLogs = [];
  List<Map<String, dynamic>> _allocationLogs = [];
  bool _isLoadingConversations = false;
  bool _isLoadingLogs = false;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
    _infoTabController = TabController(length: 3, vsync: this);
    _logsTabController = TabController(length: 2, vsync: this);
    _loadTicketData();
  }

  @override
  void dispose() {
    _infoTabController.dispose();
    _logsTabController.dispose();
    super.dispose();
  }

  Future<void> _loadTicketData() async {
    setState(() {
      _isLoadingLead = true;
      _isLoadingConversations = true;
      _isLoadingLogs = true;
    });

    // Reload ticket data to get latest assignment info
    try {
      final client = supabase.Supabase.instance.client;
      final response = await client
          .from('tickets')
          .select('*')
          .eq('id', _ticket.id)
          .maybeSingle();
      if (response != null && mounted) {
        setState(() {
          _ticket = Ticket.fromJson(response);
        });
      }
    } catch (e) {
      // If ticket reload fails, continue with existing ticket
      print('Error reloading ticket: $e');
    }

    // Load lead information
    if (_ticket.leadId != null) {
      try {
        final lead = await DatabaseService.getLeadById(_ticket.leadId!);
        setState(() {
          _lead = lead;
          _isLoadingLead = false;
        });
      } catch (e) {
        setState(() {
          _isLoadingLead = false;
        });
      }
    } else {
      setState(() {
        _isLoadingLead = false;
      });
    }

    // Load conversations
    await _loadConversations();

    // Load logs
    await _loadLogs();
  }

  Future<void> _loadConversations() async {
    try {
      final client = supabase.Supabase.instance.client;
      final response = await client
          .from('ticket_conversations')
          .select('*')
          .eq('ticket_id', _ticket.id)
          .order('created_at', ascending: false);

      setState(() {
        _conversations = List<Map<String, dynamic>>.from(response);
        _isLoadingConversations = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingConversations = false;
      });
    }
  }

  Future<void> _loadLogs() async {
    try {
      final client = supabase.Supabase.instance.client;

      // Load disposition logs
      final dispositionResponse = await client
          .from('ticket_dispositions')
          .select('*')
          .eq('ticket_id', _ticket.id)
          .order('created_at', ascending: false);

      // Load allocation logs
      final allocationResponse = await client
          .from('ticket_allocations')
          .select('*')
          .eq('ticket_id', _ticket.id)
          .order('created_at', ascending: false);

      setState(() {
        _dispositionLogs = List<Map<String, dynamic>>.from(dispositionResponse);
        _allocationLogs = List<Map<String, dynamic>>.from(allocationResponse);
        _isLoadingLogs = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingLogs = false;
      });
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '-';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ticket: ${_ticket.ticketNumber}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Card - Ticket Overview
            _buildOverviewCard(),
            const SizedBox(height: 16),
            // Second Card - Info Tabs
            _buildInfoCard(),
            const SizedBox(height: 16),
            // Third Card - Logs Tabs
            _buildLogsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Name (bold)
            Text(
              _lead?.customerName ?? _ticket.contactName,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // Ticket ID
            _buildInfoRow('Ticket ID', _ticket.ticketNumber),
            const SizedBox(height: 8),
            // Created At
            _buildInfoRow('Created At', _formatDateTime(_ticket.createdAt)),
            const SizedBox(height: 8),
            // Status
            _buildInfoRow('Status', _ticket.status.displayName),
            const SizedBox(height: 8),
            // Issue Related To
            _buildInfoRow('Issue Related To', _ticket.ticketType.displayName),
            const SizedBox(height: 8),
            // Contact Number
            _buildInfoRow('Contact Number', _ticket.contactMobile),
            const SizedBox(height: 8),
            // Priority
            _buildInfoRow('Priority', _ticket.priority.displayName),
            const SizedBox(height: 8),
            // Assigned By
            _buildInfoRow(
              'Assigned By',
              _ticket.metadata?['assigned_by_name'] as String? ??
                  _ticket.metadata?['created_by_name'] as String? ??
                  '-',
            ),
            const SizedBox(height: 8),
            // Assigned To
            _buildInfoRow('Assigned To', _ticket.assignedToName ?? '-'),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showDisposeTicketDialog,
                    icon: const Icon(FontAwesomeIcons.arrowsRotate),
                    label: const Text('Dispose Ticket'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showAssignTicketDialog,
                    icon: const Icon(FontAwesomeIcons.userPlus),
                    label: const Text('Assign'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _infoTabController,
            tabs: const [
              Tab(text: 'Ticket Info'),
              Tab(text: 'Customer Info'),
              Tab(text: 'Conversation'),
            ],
          ),
          SizedBox(
            height: 400,
            child: TabBarView(
              controller: _infoTabController,
              children: [
                _buildTicketInfoTab(),
                _buildCustomerInfoTab(),
                _buildConversationTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Service Category', _ticket.ticketCategory ?? '-'),
          const SizedBox(height: 12),
          _buildInfoRow('Service Type', _ticket.serviceType.displayName),
          const SizedBox(height: 12),
          _buildInfoRow('Service Name', _ticket.serviceType.displayName),
          const SizedBox(height: 12),
          _buildInfoRow('Issue Title', _ticket.issueTitle),
          const SizedBox(height: 12),
          _buildInfoRow('Contact Person', _ticket.contactName),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Alternate Mobile Number',
            _ticket.alternateNumber ?? '-',
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Priority', _ticket.priority.displayName),
          const SizedBox(height: 12),
          _buildInfoRow('Unit Number', _ticket.unitNumber ?? '-'),
          const SizedBox(height: 12),
          _buildInfoRow('Description', _ticket.issueDescription),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoTab() {
    if (_isLoadingLead) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_lead == null) {
      return const Center(child: Text('Customer information not available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Customer ID', _lead!.leadId),
          const SizedBox(height: 12),
          _buildInfoRow('Customer Name', _lead!.customerName),
          const SizedBox(height: 12),
          _buildInfoRow('Registered Mobile Number', _lead!.phone),
          const SizedBox(height: 12),
          _buildInfoRow('Customer Email', _lead!.email),
        ],
      ),
    );
  }

  Widget _buildConversationTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _showReplyDialog,
            icon: const Icon(FontAwesomeIcons.reply),
            label: const Text('Reply'),
          ),
        ),
        Expanded(
          child: _isLoadingConversations
              ? const Center(child: CircularProgressIndicator())
              : _conversations.isEmpty
              ? const Center(child: Text('No conversations yet'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = _conversations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              conversation['description'] ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (conversation['image_url'] != null) ...<Widget>[
                              const SizedBox(height: 8),
                              Image.network(
                                conversation['image_url'],
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  'Replied by: ${conversation['replied_by_role'] ?? conversation['replied_by_name'] ?? '-'}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade600),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  'Replied at: ${_formatDateTime(conversation['created_at'] != null ? DateTime.parse(conversation['created_at']) : null)}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLogsCard() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            controller: _logsTabController,
            tabs: const [
              Tab(text: 'Disposition Logs'),
              Tab(text: 'Allocation'),
            ],
          ),
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _logsTabController,
              children: [_buildDispositionLogsTab(), _buildAllocationLogsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDispositionLogsTab() {
    if (_isLoadingLogs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_dispositionLogs.isEmpty) {
      return const Center(child: Text('No disposition logs yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _dispositionLogs.length,
      itemBuilder: (context, index) {
        final log = _dispositionLogs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Main: ${log['main_disposition'] ?? '-'}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    if (log['disposed_by'] != null)
                      Chip(
                        label: Text(
                          log['disposed_by'].toString().toUpperCase(),
                          style: const TextStyle(fontSize: 10),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Sub: ${log['sub_disposition'] ?? '-'}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Disposed at: ${_formatDateTime(log['disposed_at'] != null ? DateTime.parse(log['disposed_at']) : null)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    if (log['follow_up_date'] != null)
                      Expanded(
                        child: Text(
                          'Follow-up: ${_formatDateTime(log['follow_up_date'] != null ? DateTime.parse(log['follow_up_date']) : null)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ),
                  ],
                ),
                if (log['initiated_by_name'] != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    'Initiated by: ${log['initiated_by_name']}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (log['created_by_name'] != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    'Created by: ${log['created_by_name']}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (log['remarks'] != null &&
                    log['remarks'].toString().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Remarks: ',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Expanded(
                          child: Text(
                            log['remarks'].toString(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllocationLogsTab() {
    if (_isLoadingLogs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_allocationLogs.isEmpty) {
      return const Center(child: Text('No allocation logs yet'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allocationLogs.length,
      itemBuilder: (context, index) {
        final log = _allocationLogs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Assigned To: ${log['assigned_to_name'] ?? '-'}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Assigned At: ${_formatDateTime(log['created_at'] != null ? DateTime.parse(log['created_at']) : null)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (log['assigned_by_name'] != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Text('Assigned By: ${log['assigned_by_name']}'),
                ],
                if (log['notes'] != null) ...<Widget>[
                  const SizedBox(height: 4),
                  Text('Notes: ${log['notes']}'),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }

  Future<void> _showDisposeTicketDialog() async {
    await DisposeTicketDialog.show(
      context: context,
      ticket: _ticket,
      onDisposed: () async {
        await _loadTicketData();
      },
    );
  }

  Future<void> _showAssignTicketDialog() async {
    await AssignTicketDialog.show(
      context: context,
      ticket: _ticket,
      onAssigned: () async {
        await _loadTicketData();
      },
    );
  }

  Future<void> _showReplyDialog() async {
    final TextEditingController descriptionController = TextEditingController();
    File? selectedImage;
    String? imagePath;

    // Store the parent context before showing dialog
    final scaffoldContext = context;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Reply'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.image,
                    );
                    if (result != null && result.files.single.path != null) {
                      setDialogState(() {
                        imagePath = result.files.single.path;
                        selectedImage = File(imagePath!);
                      });
                    }
                  },
                  icon: const Icon(FontAwesomeIcons.image),
                  label: const Text('Upload Image'),
                ),
                if (selectedImage != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Image.file(selectedImage!, height: 100, fit: BoxFit.cover),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Please enter a description')),
                  );
                  return;
                }

                try {
                  final client = supabase.Supabase.instance.client;
                  final currentUser = client.auth.currentUser;
                  final userId = currentUser?.id ?? 'system';
                  final userName =
                      (currentUser?.userMetadata?['name'] as String?) ??
                      'System User';
                  final userRole =
                      currentUser?.userMetadata?['role'] as String?;

                  String? imageUrl;
                  if (selectedImage != null && imagePath != null) {
                    // Upload image to storage
                    final fileName =
                        'ticket_${_ticket.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
                    final fileBytes = await selectedImage!.readAsBytes();
                    await client.storage
                        .from('ticket-conversations')
                        .uploadBinary(fileName, fileBytes);
                    imageUrl = client.storage
                        .from('ticket-conversations')
                        .getPublicUrl(fileName);
                  }

                  // Save conversation
                  await client.from('ticket_conversations').insert({
                    'ticket_id': _ticket.id,
                    'description': descriptionController.text.trim(),
                    'image_url': imageUrl,
                    'replied_by': userId,
                    'replied_by_name': userName,
                    'replied_by_role': userRole ?? 'user',
                  });

                  Navigator.of(dialogContext).pop();

                  // Use parent context after dialog is closed
                  if (mounted) {
                    await _loadConversations();
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      const SnackBar(content: Text('Reply sent successfully')),
                    );
                  }
                } catch (e) {
                  // Use parent context for error message
                  if (mounted) {
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      SnackBar(content: Text('Error sending reply: $e')),
                    );
                  }
                }
              },
              child: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}
