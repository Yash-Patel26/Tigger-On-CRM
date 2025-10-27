import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../data/services/database_service.dart';
import '../../../../data/services/database_service_masters.dart' as masters;
import '../../../../data/models/models.dart';
import '../../../../core/config/supabase_config.dart';


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
    _loadCrossSells();
  }

  void _loadCrossSells() {
    setState(() {
      _itemsFuture = DatabaseService.getLeadCrossSells(leadId: widget.leadId);
    });
  }

  // Helper method to get assignable users
  Future<List<Map<String, dynamic>>> _getAssignableUsers() async {
    try {
      final client = SupabaseConfig.client;
      final response = await client
          .from('users')
          .select('id,name,email,role,is_active')
          .eq('is_active', true)
          .order('name', ascending: true);
      return (response as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openAddSheet,
              icon: const Icon(FontAwesomeIcons.plus),
              label: const Text('Create'),
            ),
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
                  // Category dropdown
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
                  // Property Type dropdown
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
                  // Project dropdown
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
                  // Assigned To dropdown
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
                          _loadCrossSells();
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '✅ Cross sell created successfully! A new lead has been linked.',
                                style: TextStyle(fontWeight: FontWeight.w500),
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
}
