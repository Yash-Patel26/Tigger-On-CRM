import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../data/services/database_service.dart';
import '../../../../data/models/models.dart';
import '../../../../shared/utils/helpers.dart';

class TicketTab extends StatefulWidget {
  const TicketTab({super.key, required this.leadId});

  final String leadId;

  @override
  State<TicketTab> createState() => _TicketTabState();
}

class _TicketTabState extends State<TicketTab> {
  late Future<List<Ticket>> _ticketsFuture;

  @override
  void initState() {
    super.initState();
    _ticketsFuture = DatabaseService.getTickets(
      leadId: widget.leadId,
      limit: 200,
    );
  }

  String _formatRelative(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    DateTime? ts;
    try {
      ts = DateTime.tryParse(iso)?.toLocal();
    } catch (_) {
      ts = null;
    }
    if (ts == null) return '-';
    final Duration diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    final int days = diff.inDays;
    return days == 1 ? '1d ago' : '${days}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openCreateTicketSheet,
                icon: const Icon(FontAwesomeIcons.plus),
                label: const Text('Create Ticket'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<Ticket>>(
                future: _ticketsFuture,
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<List<Ticket>> snapshot,
                    ) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Failed to load tickets'),
                        );
                      }
                      final List<Ticket> items = snapshot.data ?? <Ticket>[];
                      if (items.isEmpty) {
                        return const Center(
                          child: Text('No tickets created yet'),
                        );
                      }
                      return ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (BuildContext context, int index) {
                          final Ticket item = items[index];
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
                                      child: Tooltip(
                                        message: item.ticketNumber,
                                        child: Text(
                                          item.ticketNumber,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Chip(
                                      label: Text(item.priority.displayName),
                                      backgroundColor: _getPriorityColor(
                                        item.priority.displayName,
                                      ),
                                      labelStyle: TextStyle(
                                        color: _getPriorityTextColor(
                                          item.priority.displayName,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Tooltip(
                                  message: item.issueTitle,
                                  child: Text(
                                    item.issueTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                if (item
                                    .issueDescription
                                    .isNotEmpty) ...<Widget>[
                                  const SizedBox(height: 6),
                                  Tooltip(
                                    message: item.issueDescription,
                                    child: Text(
                                      item.issueDescription,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: <Widget>[
                                    Icon(
                                      FontAwesomeIcons.user,
                                      size: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Assigned to ${item.assignedToName ?? '-'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade400,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      FontAwesomeIcons.clock,
                                      size: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatRelative(
                                        item.createdAt.toIso8601String(),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: <Widget>[
                                    OutlinedButton.icon(
                                      onPressed: () => _viewTicket(item),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        side: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.4),
                                        ),
                                      ),
                                      icon: const Icon(
                                        FontAwesomeIcons.eye,
                                        size: 18,
                                      ),
                                      label: const Text('View'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    // Use unified palette background for all priorities
    return const Color(0xFFE1F0E4);
  }

  Color _getPriorityTextColor(String priority) {
    // Black text on the new light background
    return Colors.black87;
  }

  void _viewTicket(Ticket item) {
    // TODO: Navigate to ticket detail screen when it's available
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Ticket'),
        content: Text('Ticket: ${item.ticketNumber}'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openCreateTicketSheet() {
    final TextEditingController issueTitleCtrl = TextEditingController();
    final TextEditingController issueDescriptionCtrl = TextEditingController();
    String? priority = 'Low';
    String? assignTo;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
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
                        'Create Ticket',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(
                          FontAwesomeIcons.xmark,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: issueTitleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Issue Title *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (String? v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: issueDescriptionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Issue Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: priority,
                    decoration: const InputDecoration(
                      labelText: 'Priority *',
                      border: OutlineInputBorder(),
                    ),
                    items: const <String>['Low', 'Medium', 'High', 'Urgent']
                        .map(
                          (String e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    onChanged: (String? v) => setModal(() => priority = v),
                    validator: (String? v) =>
                        (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        try {
                          await DatabaseService.createTicket(
                            leadId: widget.leadId,
                            issueTitle: issueTitleCtrl.text.trim(),
                            issueDescription: issueDescriptionCtrl.text.trim(),
                            priority: priority == 'High'
                                ? TicketPriority.high
                                : priority == 'Urgent'
                                ? TicketPriority.urgent
                                : priority == 'Medium'
                                ? TicketPriority.medium
                                : TicketPriority.low,
                            assignedToName: assignTo,
                          );
                          if (!mounted) return;
                          setState(() {
                            _ticketsFuture = DatabaseService.getTickets(
                              leadId: widget.leadId,
                              limit: 200,
                            );
                          });
                          Navigator.of(ctx).pop();
                          await Helpers.showSuccessDialog(
                            context,
                            title: 'Ticket created successfully',
                            message: 'Support team will be notified.',
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to create ticket: $e'),
                            ),
                          );
                        }
                      },
                      icon: const Icon(FontAwesomeIcons.check),
                      label: const Text('Create Ticket'),
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
}
