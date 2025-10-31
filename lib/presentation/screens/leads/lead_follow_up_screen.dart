import 'package:flutter/material.dart';
import '../../../../data/models/lead_model.dart';
import '../../../../data/services/database_service.dart';

class LeadFollowUpScreen extends StatefulWidget {
  const LeadFollowUpScreen({super.key});

  @override
  State<LeadFollowUpScreen> createState() => _LeadFollowUpScreenState();
}

class _LeadFollowUpScreenState extends State<LeadFollowUpScreen> {
  List<Lead> _leads = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  // Optional: Add filters later

  @override
  void initState() {
    super.initState();
    _loadFollowUpTasks();
  }

  Future<void> _loadFollowUpTasks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load leads and keep those with a scheduled next follow-up
      final leads = await DatabaseService.getLeads(limit: 200);

      List<Lead> filtered =
          leads.where((l) => l.nextFollowUpDate != null).toList()..sort(
            (a, b) => a.nextFollowUpDate!.compareTo(b.nextFollowUpDate!),
          );

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        filtered = filtered.where((lead) {
          final name = (lead.customerName ?? '').toLowerCase();
          final proj = (lead.projectName ?? '').toLowerCase();
          final phone = (lead.phone ?? '').toLowerCase();
          return name.contains(q) || proj.contains(q) || phone.contains(q);
        }).toList();
      }

      setState(() {
        _leads = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load follow-up tasks: $e';
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _loadFollowUpTasks();
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
    });
    _loadFollowUpTasks();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No date';
    return '${date.day}/${date.month}/${date.year}';
  }

  // End helpers

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead Follow-ups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFollowUpTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search follow-ups...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _onSearchChanged(''),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 12),
                // Filter Chips
                Row(
                  children: [
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.clear_all),
                      onPressed: _clearFilters,
                      tooltip: 'Clear Filters',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Follow-ups list
          Expanded(child: _buildLeadsList()),
        ],
      ),
    );
  }

  Widget _buildLeadsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFollowUpTasks,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_leads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No follow-ups scheduled',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Schedule follow-ups from dispositions or lead details',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _leads.length,
      itemBuilder: (context, index) {
        final lead = _leads[index];
        return _buildLeadCard(lead);
      },
    );
  }

  Widget _buildLeadCard(Lead lead) {
    final DateTime? next = lead.nextFollowUpDate;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(lead.customerName ?? 'Lead'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lead.projectName != null && lead.projectName!.isNotEmpty)
              Text(lead.projectName!),
            if (next != null) Text('Next follow-up: ${_formatDate(next)}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Optionally navigate to lead details screen
        },
      ),
    );
  }
}
