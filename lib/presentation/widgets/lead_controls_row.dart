import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../data/models/models.dart';


class LeadControlsRow extends StatelessWidget {
  const LeadControlsRow({
    super.key,
    required this.pageSize,
    required this.pageItems,
    required this.searchText,
    required this.onPageSizeChanged,
    required this.onSortSelected,
    this.leadDataList = const [],
  });

  final int pageSize;
  final List<dynamic> pageItems;
  final String searchText;
  final ValueChanged<int> onPageSizeChanged;
  final ValueChanged<String> onSortSelected;
  final List<dynamic> leadDataList;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            // Page size dropdown
            GestureDetector(
              onTap: () => _showPageSizeDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                constraints: const BoxConstraints(minWidth: 56, minHeight: 36),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      pageSize.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      FontAwesomeIcons.chevronDown,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            const SizedBox(width: 4),
            // Sort button
            GestureDetector(
              onTap: () => _showSortDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(
                      FontAwesomeIcons.upDown,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      'Sort',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Show disposition count button
            GestureDetector(
              onTap: () => _showDispositionCount(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Disposition',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Count display with search indicator
            Text(
              searchText.isNotEmpty
                  ? 'Search results: ${pageItems.length}'
                  : 'Count: ${pageItems.length}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: searchText.isNotEmpty
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Page size dialog
  void _showPageSizeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text('Select Page Size'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('5'),
                onTap: () {
                  onPageSizeChanged(5);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('10'),
                onTap: () {
                  onPageSizeChanged(10);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text('20'),
                onTap: () {
                  onPageSizeChanged(20);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Sort dialog
  void _showSortDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text('Sort Leads'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Name (A-Z)'),
                onTap: () {
                  Navigator.of(context).pop();
                  onSortSelected('name_asc');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sorted by Name (A-Z)')),
                  );
                },
              ),
              ListTile(
                title: const Text('Name (Z-A)'),
                onTap: () {
                  Navigator.of(context).pop();
                  onSortSelected('name_desc');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sorted by Name (Z-A)')),
                  );
                },
              ),
              ListTile(
                title: const Text('Date (Newest)'),
                onTap: () {
                  Navigator.of(context).pop();
                  onSortSelected('date_desc');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sorted by Date (Newest)')),
                  );
                },
              ),
              ListTile(
                title: const Text('Date (Oldest)'),
                onTap: () {
                  Navigator.of(context).pop();
                  onSortSelected('date_asc');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sorted by Date (Oldest)')),
                  );
                },
              ),
              ListTile(
                title: const Text('Status'),
                onTap: () {
                  Navigator.of(context).pop();
                  onSortSelected('status');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sorted by Status')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show disposition count
  void _showDispositionCount(BuildContext context) {
    // Use leadDataList if provided, otherwise use pageItems
    final itemsToCount = leadDataList.isNotEmpty ? leadDataList : pageItems;

    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          title: const Text('Disposition Count'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Hot Leads'),
                trailing: Text(
                  '${_countByStatus(itemsToCount, LeadStatus.hot)}',
                ),
              ),
              ListTile(
                title: const Text('Warm Leads'),
                trailing: Text(
                  '${_countByStatus(itemsToCount, LeadStatus.warm)}',
                ),
              ),
              ListTile(
                title: const Text('Cold Leads'),
                trailing: Text(
                  '${_countByStatus(itemsToCount, LeadStatus.cold)}',
                ),
              ),
              const Divider(),
              ListTile(
                title: const Text('Total'),
                trailing: Text('${itemsToCount.length}'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // Helper method to count leads by status
  int _countByStatus(List<dynamic> items, LeadStatus status) {
    return items.where((item) {
      // Try to access status property
      try {
        final itemStatus = (item as dynamic).status;
        if (itemStatus is LeadStatus) {
          return itemStatus == status;
        }
        if (itemStatus is String) {
          return itemStatus == status.name;
        }
      } catch (_) {
        // If status property doesn't exist, return false
      }
      return false;
    }).length;
  }
}
