import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();
  final int _pageSize = 12;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  List<AppNotification> _items = <AppNotification>[
    AppNotification(
      id: 'n1',
      title: 'New Lead Assigned',
      message: 'You have been assigned a new hot opportunity.',
      time: '2m ago',
      type: NotificationType.lead,
      unread: true,
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
    AppNotification(
      id: 'n2',
      title: 'Site Visit Today',
      message: 'Reminder: Site visit with Raj at 4:30 PM.',
      time: '1h ago',
      type: NotificationType.calendar,
      unread: true,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AppNotification(
      id: 'n3',
      title: 'Booking Confirmed',
      message: 'Booking #BK-1043 has been confirmed.',
      time: 'Yesterday',
      type: NotificationType.booking,
      unread: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    ),
    AppNotification(
      id: 'n4',
      title: 'Follow-up Due',
      message: 'Call Priya regarding proposal feedback.',
      time: 'Tue',
      type: NotificationType.followUp,
      unread: false,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  List<_Row> _flattenedRows() {
    final List<AppNotification> sorted = List<AppNotification>.from(_items)
      ..sort(_compareByTimeDesc);
    final Map<String, List<AppNotification>> buckets =
        <String, List<AppNotification>>{};
    for (final AppNotification n in sorted) {
      final String label = _bucketLabel(n.createdAt);
      buckets.putIfAbsent(label, () => <AppNotification>[]).add(n);
    }
    final List<_Row> out = <_Row>[];
    buckets.forEach((String label, List<AppNotification> list) {
      out.add(_Row.header(label));
      for (final AppNotification n in list) {
        out.add(_Row.item(n));
      }
    });
    return out;
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore) return;
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Widget _buildLoadMore() {
    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: OutlinedButton.icon(
          onPressed: _loadMore,
          icon: const Icon(Icons.more_horiz),
          label: const Text('Load more'),
        ),
      ),
    );
  }

  Future<void> _loadMore() async {
    setState(() => _isLoadingMore = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final int start = _items.length;
    final List<AppNotification> more = List<AppNotification>.generate(
      _pageSize,
      (int i) {
        final int idx = start + i + 1;
        return AppNotification(
          id: 'nx$idx',
          title: 'Auto message #$idx',
          message: 'This is a generated notification item.',
          time: '${2 + i}d ago',
          type: NotificationType.values[idx % NotificationType.values.length],
          unread: i % 3 == 0,
          createdAt: DateTime.now().subtract(Duration(days: 2 + i)),
        );
      },
    );
    setState(() {
      _items = <AppNotification>[..._items, ...more];
      _isLoadingMore = false;
      if (_items.length > 120) _hasMore = false; // stop after some pages
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: <Widget>[
          TextButton(
            onPressed: _markAllRead,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: _flattenedRows().length + (_hasMore ? 1 : 0),
          itemBuilder: (BuildContext context, int index) {
            final List<_Row> rows = _flattenedRows();
            if (index >= rows.length) {
              return _buildLoadMore();
            }
            final _Row row = rows[index];
            if (row.isHeader) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                child: Text(
                  row.header!,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              );
            }
            final AppNotification n = row.item!;
            return Column(
              children: <Widget>[
                Dismissible(
                  key: ValueKey<String>(n.id),
                  direction: DismissDirection.endToStart,
                  background: _dismissBg(context),
                  onDismissed: (_) {
                    setState(
                      () => _items.removeWhere(
                        (AppNotification e) => e.id == n.id,
                      ),
                    );
                  },
                  child: _NotificationTile(
                    notification: n,
                    onTap: () => _openNotification(n),
                    onToggledRead: () => _toggleRead(n),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {});
  }

  void _markAllRead() {
    setState(() {
      for (int i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(unread: false);
      }
    });
  }

  void _toggleRead(AppNotification n) {
    final int idx = _items.indexWhere((AppNotification e) => e.id == n.id);
    if (idx == -1) return;
    setState(() {
      _items[idx] = _items[idx].copyWith(unread: !n.unread);
    });
  }

  void _openNotification(AppNotification n) {
    // Deep-link hook. For now, show details and quick actions.
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  n.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(n.message),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _toggleRead(n);
                      },
                      icon: Icon(
                        n.unread
                            ? Icons.mark_email_read_outlined
                            : Icons.mark_email_unread_outlined,
                      ),
                      label: Text(n.unread ? 'Mark read' : 'Mark unread'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Open related screen – to be wired'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Open'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dismissBg(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Icon(Icons.delete_outline, color: Colors.redAccent),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onToggledRead,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onToggledRead;

  @override
  Widget build(BuildContext context) {
    final IconData icon = _iconFor(notification.type);
    final Color color = _colorFor(context, notification.type);

    return Container(
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
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            if (notification.unread)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          notification.title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 6),
            Text(
              notification.time,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 12),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            notification.unread
                ? Icons.mark_email_unread_outlined
                : Icons.mark_email_read_outlined,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: onToggledRead,
          tooltip: notification.unread ? 'Mark read' : 'Mark unread',
        ),
      ),
    );
  }

  IconData _iconFor(NotificationType t) {
    switch (t) {
      case NotificationType.lead:
        return Icons.person_add_alt_1_rounded;
      case NotificationType.calendar:
        return Icons.event_rounded;
      case NotificationType.booking:
        return Icons.receipt_long_rounded;
      case NotificationType.followUp:
        return Icons.assignment_turned_in_rounded;
    }
  }

  Color _colorFor(BuildContext context, NotificationType t) {
    final Color primary = Theme.of(context).colorScheme.primary;
    switch (t) {
      case NotificationType.lead:
        return Colors.blueAccent;
      case NotificationType.calendar:
        return Colors.orangeAccent;
      case NotificationType.booking:
        return Colors.green;
      case NotificationType.followUp:
        return primary;
    }
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.unread,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  final bool unread;
  final DateTime createdAt;

  AppNotification copyWith({bool? unread}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      time: time,
      type: type,
      unread: unread ?? this.unread,
      createdAt: createdAt,
    );
  }
}

enum NotificationType { lead, calendar, booking, followUp }

// Grouping and pagination helpers
class _Row {
  const _Row.header(this.header) : item = null, isHeader = true;
  const _Row.item(this.item) : header = null, isHeader = false;

  final String? header;
  final AppNotification? item;
  final bool isHeader;
}

String _bucketLabel(DateTime dt) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);
  final DateTime other = DateTime(dt.year, dt.month, dt.day);
  final Duration diff = today.difference(other);
  if (diff.inDays == 0) return 'Today';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays <= 7) return 'This Week';
  return 'Earlier';
}

int _compareByTimeDesc(AppNotification a, AppNotification b) =>
    b.createdAt.compareTo(a.createdAt);
