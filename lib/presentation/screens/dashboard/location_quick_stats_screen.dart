import 'package:flutter/material.dart';

class LocationQuickStatsScreen extends StatefulWidget {
  const LocationQuickStatsScreen({super.key});

  @override
  State<LocationQuickStatsScreen> createState() =>
      _LocationQuickStatsScreenState();
}

class _LocationQuickStatsScreenState extends State<LocationQuickStatsScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _statusFilter = 0; // 0=All, 1=Active, 2=Inactive

  // Mock data - replace with real data source
  final List<LocationItem> _locations = <LocationItem>[
    const LocationItem(
      name: 'Andheri East',
      city: 'Mumbai',
      state: 'Maharashtra',
      isActive: true,
    ),
    const LocationItem(
      name: 'Bandra West',
      city: 'Mumbai',
      state: 'Maharashtra',
      isActive: true,
    ),
    const LocationItem(
      name: 'Koramangala',
      city: 'Bangalore',
      state: 'Karnataka',
      isActive: true,
    ),
    const LocationItem(
      name: 'Indiranagar',
      city: 'Bangalore',
      state: 'Karnataka',
      isActive: false,
    ),
    const LocationItem(
      name: 'Connaught Place',
      city: 'Delhi',
      state: 'Delhi',
      isActive: true,
    ),
    const LocationItem(
      name: 'Hauz Khas',
      city: 'Delhi',
      state: 'Delhi',
      isActive: false,
    ),
    const LocationItem(
      name: 'Gachibowli',
      city: 'Hyderabad',
      state: 'Telangana',
      isActive: true,
    ),
    const LocationItem(
      name: 'Banjara Hills',
      city: 'Hyderabad',
      state: 'Telangana',
      isActive: true,
    ),
    const LocationItem(
      name: 'Anna Nagar',
      city: 'Chennai',
      state: 'Tamil Nadu',
      isActive: true,
    ),
    const LocationItem(
      name: 'Velachery',
      city: 'Chennai',
      state: 'Tamil Nadu',
      isActive: false,
    ),
    const LocationItem(
      name: 'Salt Lake',
      city: 'Kolkata',
      state: 'West Bengal',
      isActive: false,
    ),
    const LocationItem(
      name: 'Viman Nagar',
      city: 'Pune',
      state: 'Maharashtra',
      isActive: true,
    ),
    const LocationItem(
      name: 'Aundh',
      city: 'Pune',
      state: 'Maharashtra',
      isActive: true,
    ),
    const LocationItem(
      name: 'Vastrapur',
      city: 'Ahmedabad',
      state: 'Gujarat',
      isActive: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int total = _locations.length;
    final int active = _locations.where((LocationItem l) => l.isActive).length;
    final int inactive = total - active;

    final String query = _searchController.text.trim().toLowerCase();
    final List<LocationItem> filtered = _locations.where((LocationItem l) {
      final bool matchesQuery =
          query.isEmpty ||
          l.name.toLowerCase().contains(query) ||
          l.city.toLowerCase().contains(query) ||
          l.state.toLowerCase().contains(query);
      final bool matchesStatus =
          _statusFilter == 0 ||
          (_statusFilter == 1 && l.isActive) ||
          (_statusFilter == 2 && !l.isActive);
      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Location'), elevation: 0),
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
                    hintText: 'Search by location, city or state...',
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

          // Location List
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(color: _panelBorderColor(context), height: 1),
                    itemBuilder: (BuildContext context, int index) {
                      final LocationItem item = filtered[index];
                      return _buildLocationCard(context, item);
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
    return Container(
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
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, LocationItem item) {
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
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.place,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.location_city,
                      size: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${item.city}, ${item.state}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
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
            'No locations found',
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

class LocationItem {
  const LocationItem({
    required this.name,
    required this.city,
    required this.state,
    required this.isActive,
  });

  final String name; // location name
  final String city; // city name
  final String state; // state name
  final bool isActive;
}
