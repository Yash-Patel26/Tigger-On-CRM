import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../data/services/database_service.dart';
import '../../../../data/models/models.dart';
import '../../../../shared/utils/helpers.dart';
import '../../../presentation/screens/property/create_property_option_screen.dart';

class PropertyOptionTab extends StatefulWidget {
  const PropertyOptionTab({super.key});

  @override
  State<PropertyOptionTab> createState() => _PropertyOptionTabState();
}

class _PropertyOptionTabState extends State<PropertyOptionTab> {
  List<Project> _projects = <Project>[];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final List<Project> res = await DatabaseService.getProjects(limit: 50);
      if (!mounted) return;
      setState(() {
        _projects = res;
      });
    } catch (_) {}
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
                onPressed: _openAddPropertyOptionScreen,
                icon: const Icon(FontAwesomeIcons.plus),
                label: const Text('Create Property Option'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _projects.isEmpty
                  ? const Center(child: Text('No projects found'))
                  : _buildProjectsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList() {
    final List<Project> items = _projects;
    final ScrollController scrollController = ScrollController();
    return Scrollbar(
      controller: scrollController,
      child: ListView.separated(
        controller: scrollController,
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 16),
        itemBuilder: (BuildContext context, int i) {
          final Project p = items[i];
          final String typeText =
              p.type.toString().split('.').last[0].toUpperCase() +
              p.type.toString().split('.').last.substring(1);
          final String startText =
              p.startingPrice != null && p.startingPrice! > 0
              ? '₹ ${p.startingPrice!.toStringAsFixed(0)} / ${p.priceUnit ?? ''}'
                    .trim()
              : '-';
          final String locationText = <String?>[
            p.address,
            p.city,
            p.state,
          ].where((String? s) => (s ?? '').isNotEmpty).join(', ');

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: <Widget>[
                        Text(
                          p.name,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text('/', style: Theme.of(context).textTheme.bodySmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Text(
                            typeText,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: <TextSpan>[
                          const TextSpan(
                            text: 'Starting From : ',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: startText,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: <TextSpan>[
                          const TextSpan(
                            text: 'Location : ',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: locationText.isEmpty ? '-' : locationText,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openAddPropertyOptionScreen() async {
    final Map<String, String>? result = await Navigator.of(context).push(
      MaterialPageRoute<Map<String, String>>(
        builder: (BuildContext ctx) => const CreatePropertyOptionScreen(),
      ),
    );
    if (result != null) {
      if (!mounted) return;
      await Helpers.showSuccessDialog(
        context,
        title: 'Property option created successfully',
        message: 'Property has been added.',
      );
    }
  }
}
