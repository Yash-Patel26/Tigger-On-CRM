import 'package:flutter/material.dart';
import '../../../data/services/database_service.dart';
import '../../../data/models/models.dart';
import '../../../shared/utils/helpers.dart';

class ActiveProjectsScreen extends StatefulWidget {
  const ActiveProjectsScreen({super.key});

  @override
  State<ActiveProjectsScreen> createState() => _ActiveProjectsScreenState();
}

class _ActiveProjectsScreenState extends State<ActiveProjectsScreen> {
  List<Project> _projects = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<Project> projects = await DatabaseService.getProjects(
        status: ProjectStatus.underConstruction,
        limit: 100,
      );

      if (mounted) {
        setState(() {
          _projects = projects;
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
        title: const Text('Active Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
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
                  Text('Error loading projects: $_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProjects,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _projects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active projects found',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProjects,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _projects.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  final Project project = _projects[index];
                  return _card(context, project);
                },
              ),
            ),
    );
  }

  Widget _card(BuildContext context, Project project) {
    final String location = [
      project.city,
      project.state,
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    final String priceText = project.startingPrice != null
        ? '₹ ${Helpers.formatCurrency(project.startingPrice!)}'
        : 'Price not available';

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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: const Icon(Icons.apartment, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    const Icon(Icons.tag, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        project.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.location_on, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    const Icon(Icons.sell_outlined, size: 14),
                    const SizedBox(width: 6),
                    Text(priceText),
                  ],
                ),
                if (project.developerName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: <Widget>[
                      const Icon(Icons.business, size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          project.developerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE55934).withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: const Color(0xFFE55934).withOpacity(0.3),
              ),
            ),
            child: Text(
              project.status.name.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFFE55934),
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
