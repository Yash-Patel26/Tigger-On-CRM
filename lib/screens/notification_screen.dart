import 'package:flutter/material.dart';
import '../models/notification_model.dart' as notification_model;
import '../repositories/notification_repository.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final NotificationRepository _notificationRepository =
      NotificationRepository();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  String? _error;
  List<notification_model.Notification> _allNotifications = [];
  List<notification_model.Notification> _filteredNotifications = [];
  notification_model.NotificationType? _selectedType;
  notification_model.NotificationPriority? _selectedPriority;
  notification_model.NotificationStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _notificationRepository.getNotifications();
      if (response.success && response.data != null) {
        setState(() {
          _allNotifications = response.data!;
          _filteredNotifications = _allNotifications;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message ?? 'Failed to load notifications';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading notifications: $e';
        _isLoading = false;
      });
    }
  }

  void _filterNotifications() {
    setState(() {
      _filteredNotifications = _allNotifications.where((notification) {
        final matchesSearch =
            _searchController.text.isEmpty ||
            notification.title.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ) ||
            notification.message.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            );

        final matchesType =
            _selectedType == null || notification.type == _selectedType;
        final matchesPriority =
            _selectedPriority == null ||
            notification.priority == _selectedPriority;
        final matchesStatus =
            _selectedStatus == null || notification.status == _selectedStatus;

        return matchesSearch && matchesType && matchesPriority && matchesStatus;
      }).toList();
    });
  }

  Future<void> _markAsRead(notification_model.Notification notification) async {
    try {
      final response = await _notificationRepository.markAsRead(
        notification.id,
      );
      if (response.success) {
        _loadNotifications(); // Refresh the list
      } else {
        _showSnackBar('Failed to mark as read: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('Error marking as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final response = await _notificationRepository.markAllAsRead();
      if (response.success) {
        _loadNotifications(); // Refresh the list
        _showSnackBar('All notifications marked as read');
      } else {
        _showSnackBar('Failed to mark all as read: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('Error marking all as read: $e');
    }
  }

  Future<void> _deleteNotification(
    notification_model.Notification notification,
  ) async {
    try {
      final response = await _notificationRepository.deleteNotification(
        notification.id,
      );
      if (response.success) {
        _loadNotifications(); // Refresh the list
        _showSnackBar('Notification deleted');
      } else {
        _showSnackBar('Failed to delete notification: ${response.message}');
      }
    } catch (e) {
      _showSnackBar('Error deleting notification: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<notification_model.NotificationType?>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Types')),
                ...notification_model.NotificationType.values.map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<notification_model.NotificationPriority?>(
              value: _selectedPriority,
              decoration: const InputDecoration(labelText: 'Priority'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Priorities'),
                ),
                ...notification_model.NotificationPriority.values.map(
                  (priority) => DropdownMenuItem(
                    value: priority,
                    child: Text(priority.displayName),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedPriority = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<notification_model.NotificationStatus?>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: 'Status'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Statuses'),
                ),
                ...notification_model.NotificationStatus.values.map(
                  (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.displayName),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedStatus = value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedType = null;
                _selectedPriority = null;
                _selectedStatus = null;
              });
              _filterNotifications();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              _filterNotifications();
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markAllAsRead,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
            Tab(text: 'Today'),
            Tab(text: 'Archived'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notifications...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterNotifications();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => _filterNotifications(),
            ),
          ),
          // Notifications list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationsList(_filteredNotifications),
                _buildNotificationsList(
                  _filteredNotifications.where((n) => !n.isRead).toList(),
                ),
                _buildNotificationsList(
                  _filteredNotifications
                      .where(
                        (n) => n.createdAt.isAfter(
                          DateTime.now().subtract(const Duration(days: 1)),
                        ),
                      )
                      .toList(),
                ),
                _buildNotificationsList(
                  _filteredNotifications.where((n) => n.isArchived).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    List<notification_model.Notification> notifications,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications found',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'re all caught up!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(notification_model.Notification notification) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = _getPriorityColor(notification.priority);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: isDark
          ? Colors.white.withOpacity(0.06)
          : Colors.black.withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark
              ? Colors.white.withOpacity(0.12)
              : const Color(0x22000000),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _markAsRead(notification),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Priority indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Notification content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: notification.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
                                    ),
                              ),
                            ),
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.message,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.7),
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildTypeChip(notification.type),
                            const SizedBox(width: 8),
                            _buildPriorityChip(notification.priority),
                            const Spacer(),
                            Text(
                              _formatDateTime(notification.createdAt),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Actions menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'mark_read':
                          _markAsRead(notification);
                          break;
                        case 'delete':
                          _deleteNotification(notification);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'mark_read',
                        child: Row(
                          children: [
                            Icon(
                              notification.isRead
                                  ? Icons.mark_email_unread
                                  : Icons.mark_email_read,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              notification.isRead
                                  ? 'Mark as unread'
                                  : 'Mark as read',
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(notification_model.NotificationType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        type.displayName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(notification_model.NotificationPriority priority) {
    final color = _getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.displayName,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getPriorityColor(notification_model.NotificationPriority priority) {
    switch (priority) {
      case notification_model.NotificationPriority.low:
        return Colors.green;
      case notification_model.NotificationPriority.medium:
        return Colors.orange;
      case notification_model.NotificationPriority.high:
        return Colors.red;
      case notification_model.NotificationPriority.urgent:
        return Colors.purple;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
