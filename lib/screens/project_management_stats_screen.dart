import 'package:flutter/material.dart';
import 'project_detail_screen.dart';
import 'project_price_logs_screen.dart';

class ProjectManagementStatsScreen extends StatefulWidget {
  const ProjectManagementStatsScreen({super.key});

  @override
  State<ProjectManagementStatsScreen> createState() =>
      _ProjectManagementStatsScreenState();
}

class _ProjectManagementStatsScreenState
    extends State<ProjectManagementStatsScreen> {
  // Filters
  final TextEditingController _projectNameController = TextEditingController();
  String? _selectedPropertyCategory;
  String? _selectedPropertyType;
  String? _selectedState;
  String? _selectedCity;
  String? _selectedLocation;
  String? _selectedDeveloper;

  // Mock data
  final List<Map<String, dynamic>> _properties =
      List<Map<String, dynamic>>.generate(10, (int index) {
        return <String, dynamic>{
          'projectId': 'PRJ-${1000 + index}',
          'name': 'Sunrise Residency ${index + 1}',
          'acre99Id': '99A-${5000 + index}',
          'reraNo': index % 2 == 0 ? 'RERA-${200 + index}' : null,
          'logo': null,
          'price': '₹ ${35 + index} L',
          'address': '123, Main Street',
          'location': 'Sector ${10 + index}',
          'status': index % 3 == 0 ? 'Active' : 'Inactive',
        };
      });

  @override
  void dispose() {
    _projectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Management Stats'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Filters',
            icon: const Icon(Icons.tune),
            onPressed: _openFiltersBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildHeaderStats(context),
          const Divider(height: 1),
          Expanded(child: _buildPropertyList(context)),
        ],
      ),
    );
  }

  Widget _buildHeaderStats(BuildContext context) {
    final int activeCount = _properties
        .where((Map<String, dynamic> p) => p['status'] == 'Active')
        .length;
    final int inactiveCount = _properties.length - activeCount;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: <Widget>[
          _buildStatChip(
            context,
            'Active Projects',
            activeCount,
            Icons.check_circle,
            const Color(0xFFE55934),
          ),
          _buildStatChip(
            context,
            'Inactive Projects',
            inactiveCount,
            Icons.pause_circle,
            const Color(0xFFC62828),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    String label,
    int count,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _openFiltersBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _buildFiltersSheet(context),
        );
      },
    );
  }

  Widget _buildFiltersSheet(BuildContext context) {
    final InputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Filters',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _projectNameController,
            decoration: InputDecoration(
              labelText: 'Project name',
              prefixIcon: const Icon(Icons.search),
              border: border,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          _buildDropdown<String>(
            label: 'Property category',
            value: _selectedPropertyCategory,
            items: const <String>['Residential', 'Commercial'],
            onChanged: (String? v) =>
                setState(() => _selectedPropertyCategory = v),
          ),
          const SizedBox(height: 8),
          _buildDropdown<String>(
            label: 'Property type',
            value: _selectedPropertyType,
            items: const <String>['Apartment', 'Villa', 'Shop', 'Office'],
            onChanged: (String? v) => setState(() => _selectedPropertyType = v),
          ),
          const SizedBox(height: 8),
          _buildDropdown<String>(
            label: 'State',
            value: _selectedState,
            items: const <String>['Gujarat', 'Maharashtra', 'Karnataka'],
            onChanged: (String? v) => setState(() => _selectedState = v),
          ),
          const SizedBox(height: 8),
          _buildDropdown<String>(
            label: 'City',
            value: _selectedCity,
            items: const <String>['Ahmedabad', 'Mumbai', 'Bengaluru'],
            onChanged: (String? v) => setState(() => _selectedCity = v),
          ),
          const SizedBox(height: 8),
          _buildDropdown<String>(
            label: 'Location',
            value: _selectedLocation,
            items: const <String>['Sector 10', 'Sector 11', 'Sector 12'],
            onChanged: (String? v) => setState(() => _selectedLocation = v),
          ),
          const SizedBox(height: 8),
          _buildDropdown<String>(
            label: 'Developer',
            value: _selectedDeveloper,
            items: const <String>['ABC Builders', 'XYZ Developers'],
            onChanged: (String? v) => setState(() => _selectedDeveloper = v),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {});
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Apply Filters'),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _projectNameController.clear();
                    _selectedPropertyCategory = null;
                    _selectedPropertyType = null;
                    _selectedState = null;
                    _selectedCity = null;
                    _selectedLocation = null;
                    _selectedDeveloper = null;
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: items
          .map((T e) => DropdownMenuItem<T>(value: e, child: Text('$e')))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildPropertyList(BuildContext context) {
    final List<Map<String, dynamic>> filtered = _properties.where((
      Map<String, dynamic> p,
    ) {
      final String name = (p['name'] as String).toLowerCase();
      if (_projectNameController.text.isNotEmpty &&
          !name.contains(_projectNameController.text.toLowerCase())) {
        return false;
      }
      // Add more filter logic when real data is wired
      return true;
    }).toList();

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        final Map<String, dynamic> p = filtered[index];
        return _buildPropertyCard(context, p);
      },
    );
  }

  Widget _buildPropertyCard(BuildContext context, Map<String, dynamic> p) {
    final bool hasRera =
        (p['reraNo'] as String?) != null && (p['reraNo'] as String).isNotEmpty;
    final Color reraColor = hasRera
        ? const Color(0xFFE55934)
        : const Color(0xFFC62828);
    final String reraText = hasRera ? 'RERA Approved' : 'RERA Not Approved';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildLogo(p['logo']),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        p['name'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildIdLine(
                            'Project ID: ${p['projectId']}',
                            Icons.tag,
                          ),
                          const SizedBox(height: 4),
                          _buildIdLine(
                            '99acres ID: ${p['acre99Id']}',
                            Icons.numbers,
                          ),
                          if (hasRera) ...<Widget>[
                            const SizedBox(height: 4),
                            _buildIdLine(
                              'RERA: ${p['reraNo']}',
                              Icons.verified,
                              color: reraColor,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: <Widget>[
                          _buildBadge(reraText, reraColor),
                          _buildBadge(p['price'] as String, Colors.indigo),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.location_on, size: 16),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${p['address']}, ${p['location']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProjectDetailScreen(project: p),
                      ),
                    );
                  },
                  child: const Text('View'),
                ),
                ElevatedButton(onPressed: () {}, child: const Text('Activate')),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ProjectPriceLogsScreen(project: p),
                      ),
                    );
                  },
                  child: const Text('Price Log'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(dynamic logo) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: const Icon(Icons.apartment, color: Colors.grey),
    );
  }

  // Removed unused _buildChip after switching to vertical ID lines

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildIdLine(String text, IconData icon, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: color ?? Colors.black54),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
