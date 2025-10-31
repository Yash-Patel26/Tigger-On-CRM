import 'package:flutter/material.dart';
import '../../../core/config/supabase_config.dart';

class PropertyCategoryQuickStatsScreen extends StatefulWidget {
  const PropertyCategoryQuickStatsScreen({super.key});

  @override
  State<PropertyCategoryQuickStatsScreen> createState() =>
      _PropertyCategoryQuickStatsScreenState();
}

class _PropertyCategoryQuickStatsScreenState
    extends State<PropertyCategoryQuickStatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _statusFilter = 0; // 0=All, 1=Active, 2=Inactive

  List<PropertyCategory> _categories = <PropertyCategory>[];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPropertyCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPropertyCategories() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch property categories from Supabase
      final response = await SupabaseConfig.client
          .from('property_categories')
          .select('''
            id,
            name,
            is_active
          ''')
          .order('name');

      final List<PropertyCategory> categories = (response as List).map((json) {
        return PropertyCategory(
          id: json['id'] as String,
          name: json['name'] as String,
          isActive: json['is_active'] as bool? ?? true,
        );
      }).toList();

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load property categories: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Property Categories'), elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Property Categories'), elevation: 0),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPropertyCategories,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final int total = _categories.length;
    final int active = _categories
        .where((PropertyCategory c) => c.isActive)
        .length;
    final int inactive = total - active;

    final String query = _searchController.text.trim().toLowerCase();
    final List<PropertyCategory> filtered = _categories.where((
      PropertyCategory c,
    ) {
      final bool matchesQuery =
          query.isEmpty || c.name.toLowerCase().contains(query);
      final bool matchesStatus =
          _statusFilter == 0 ||
          (_statusFilter == 1 && c.isActive) ||
          (_statusFilter == 2 && !c.isActive);
      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Property Category'), elevation: 0),
      body: Column(
        children: <Widget>[
          // Quick Stats Cards (Active/Inactive only)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Active',
                    active.toString(),
                    Icons.check_circle_outline,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Inactive',
                    inactive.toString(),
                    Icons.pause_circle_outline,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),

          // Search and Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search property categories...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: _panelColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _panelBorderColor(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: _panelBorderColor(context)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        children: <Widget>[
                          ChoiceChip(
                            label: const Text('All'),
                            selected: _statusFilter == 0,
                            onSelected: (_) =>
                                setState(() => _statusFilter = 0),
                          ),
                          ChoiceChip(
                            label: const Text('Active'),
                            selected: _statusFilter == 1,
                            onSelected: (_) =>
                                setState(() => _statusFilter = 1),
                          ),
                          ChoiceChip(
                            label: const Text('Inactive'),
                            selected: _statusFilter == 2,
                            onSelected: (_) =>
                                setState(() => _statusFilter = 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Category List
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(color: _panelBorderColor(context), height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final PropertyCategory item = filtered[index];
                      return _buildCategoryCard(context, item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return InkWell(
      onTap: () => setState(
        () => _statusFilter = label == 'Active'
            ? 1
            : label == 'Inactive'
            ? 2
            : 0,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _panelColor(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _panelBorderColor(context)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, PropertyCategory item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panelColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _panelBorderColor(context)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.category,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          _buildStatusChip(context, item.isActive),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, bool isActive) {
    final Color color = isActive ? Colors.green : Colors.redAccent;
    final String label = isActive ? 'Active' : 'Inactive';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No categories found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filter criteria',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Color _panelColor(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);
  }

  Color _panelBorderColor(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.12)
        : const Color(0x22000000);
  }
}

class PropertyCategory {
  const PropertyCategory({
    required this.id,
    required this.name,
    required this.isActive,
  });

  final String id; // property category id
  final String name; // property category name
  final bool isActive;
}
