import 'package:flutter/material.dart';
import '../../data/services/database_service.dart';

class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  List<Map<String, dynamic>> _teamMembers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTeamMembers();
  }

  Future<void> _loadTeamMembers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<Map<String, dynamic>> users =
          await DatabaseServiceUsersAndDisposition.getAssignableUsers();

      if (mounted) {
        setState(() {
          _teamMembers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTeamMembers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text('Error loading team members: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTeamMembers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _teamMembers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No team members found',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTeamMembers,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _teamMembers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, dynamic> member = _teamMembers[index];
                  return _card(context, member);
                },
              ),
            ),
    );
  }

  Widget _card(BuildContext context, Map<String, dynamic> member) {
    final String name = member['name'] as String? ?? 'Unknown';
    final String email = member['email'] as String? ?? '';
    final String role = member['role'] as String? ?? 'No role';
    final bool isActive = member['is_active'] as bool? ?? true;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.12),
            child: Text(
              _getInitials(name),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          'Inactive',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    const Icon(Icons.email_outlined, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    const Icon(Icons.badge_outlined, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      role,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String s) => s.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
