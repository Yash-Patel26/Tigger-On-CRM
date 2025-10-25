import 'package:flutter/material.dart';
import '../../core/utils/page_transitions.dart';
import 'dashboard/developer_quick_stats_screen.dart';
import 'dashboard/city_quick_stats_screen.dart';
import 'dashboard/location_quick_stats_screen.dart';
import 'dashboard/property_category_quick_stats_screen.dart';
import 'dashboard/property_type_quick_stats_screen.dart';
import 'dashboard/project_management_stats_screen.dart';

class PropertyFinderScreen extends StatelessWidget {
  const PropertyFinderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0, toolbarHeight: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(context),
            // Search and filter removed as requested
            // Property Categories section removed as requested
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final List<_QuickStat> stats = [
      _QuickStat(
        label: 'Developer',
        count: 112,
        icon: Icons.account_balance,
        iconColor: const Color(0xFFE55934),
        onTap: () {
          Navigator.of(context).push(
            SmoothPageTransitions.slideFromRight<void>(
              child: const DeveloperQuickStatsScreen(),
            ),
          );
        },
      ),
      _QuickStat(
        label: 'City',
        count: 18,
        icon: Icons.location_city,
        iconColor: const Color(0xFFE55934),
        onTap: () {
          Navigator.of(context).push(
            SmoothPageTransitions.slideFromRight<void>(
              child: const CityQuickStatsScreen(),
            ),
          );
        },
      ),
      _QuickStat(
        label: 'Location',
        count: 301,
        icon: Icons.map,
        iconColor: const Color(0xFFE55934),
        onTap: () {
          Navigator.of(context).push(
            SmoothPageTransitions.slideFromRight<void>(
              child: const LocationQuickStatsScreen(),
            ),
          );
        },
      ),
      _QuickStat(
        label: 'Property Category',
        count: 2,
        icon: Icons.apartment,
        iconColor: const Color(0xFFE55934),
        onTap: () {
          Navigator.of(context).push(
            SmoothPageTransitions.slideFromRight<void>(
              child: const PropertyCategoryQuickStatsScreen(),
            ),
          );
        },
      ),
      _QuickStat(
        label: 'Property Type',
        count: 33,
        icon: Icons.playlist_add_check,
        iconColor: const Color(0xFFE55934),
        onTap: () {
          Navigator.of(context).push(
            SmoothPageTransitions.slideFromRight<void>(
              child: const PropertyTypeQuickStatsScreen(),
            ),
          );
        },
      ),
      _QuickStat(
        label: 'Project Management',
        count: 450,
        icon: Icons.church,
        iconColor: const Color(0xFFE55934),
        onTap: () {
          Navigator.of(context).push(
            SmoothPageTransitions.slideFromRight<void>(
              child: const ProjectManagementStatsScreen(),
            ),
          );
        },
      ),
    ];

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth >= 1000) {
          crossAxisCount = 6;
        } else if (constraints.maxWidth >= 700) {
          crossAxisCount = 3;
        }

        double aspectRatio;
        if (crossAxisCount == 6) {
          aspectRatio = 1.1;
        } else if (crossAxisCount == 3) {
          aspectRatio = 1.5;
        } else {
          aspectRatio = 2.2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: aspectRatio,
          ),
          itemCount: stats.length,
          itemBuilder: (BuildContext context, int index) {
            final _QuickStat stat = stats[index];
            return _buildQuickStatTile(context, stat);
          },
        );
      },
    );
  }

  Widget _buildQuickStatTile(BuildContext context, _QuickStat stat) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: stat.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                stat.icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 4),
              Text(
                stat.count.toString(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  stat.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Search and filter section removed
}

class _QuickStat {
  const _QuickStat({
    required this.label,
    required this.count,
    required this.icon,
    required this.iconColor,
    this.onTap,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
}
