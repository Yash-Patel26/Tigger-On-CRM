import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart' as notification_model;
import '../services/notification_service.dart';
import '../repositories/notification_repository.dart';
import '../managers/notification_manager.dart';
import '../helpers/notification_helper.dart';

class NotificationSystemTestScreen extends StatefulWidget {
  const NotificationSystemTestScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSystemTestScreen> createState() =>
      _NotificationSystemTestScreenState();
}

class _NotificationSystemTestScreenState
    extends State<NotificationSystemTestScreen> {
  final NotificationManager _notificationManager = NotificationManager();
  final NotificationRepository _repository = NotificationRepository();

  List<notification_model.Notification> _notifications = [];
  Map<String, int> _counts = {};
  int _unreadCount = 0;
  bool _isLoading = false;
  String _statusMessage = '';

  static const String testUserId = '550e8400-e29b-41d4-a716-446655440001';

  @override
  void initState() {
    super.initState();
    _initializeNotificationSystem();
  }

  void _initializeNotificationSystem() {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Initializing notification system...';
    });

    try {
      _notificationManager.initialize(testUserId);

      // Listen to notifications stream
      _notificationManager.notificationsStream.listen((notifications) {
        if (mounted) {
          setState(() {
            _notifications = notifications;
            _isLoading = false;
            _statusMessage = 'Loaded ${notifications.length} notifications';
          });
        }
      });

      // Listen to counts stream
      _notificationManager.countsStream.listen((counts) {
        if (mounted) {
          setState(() {
            _counts = counts;
            _unreadCount = counts['unread'] ?? 0;
          });
        }
      });

      // Load initial data
      _loadNotifications();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error initializing: $e';
      });
    }
  }

  Future<void> _loadNotifications() async {
    try {
      await _notificationManager.getNotifications();
      await _notificationManager.getNotificationCounts();
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading notifications: $e';
      });
    }
  }

  Future<void> _createTestNotification() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Creating test notification...';
      });

      await NotificationHelper.createLeadAssignedNotification(
        userId: testUserId,
        leadId: 'test-lead-${DateTime.now().millisecondsSinceEpoch}',
        customerName: 'Test Customer',
        projectName: 'Test Project',
        priority: notification_model.NotificationPriority.high,
      );

      setState(() {
        _isLoading = false;
        _statusMessage = 'Test notification created successfully!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error creating notification: $e';
      });
    }
  }

  Future<void> _createSystemNotification() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Creating system notification...';
      });

      await NotificationHelper.createSystemMaintenanceNotification(
        title: 'Test System Maintenance',
        message: 'This is a test system maintenance notification',
        maintenanceStart: DateTime.now().add(const Duration(hours: 1)),
        maintenanceEnd: DateTime.now().add(const Duration(hours: 3)),
        userId: testUserId,
      );

      setState(() {
        _isLoading = false;
        _statusMessage = 'System notification created successfully!';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error creating system notification: $e';
      });
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _notificationManager.markAsRead(notificationId);
      setState(() {
        _statusMessage = 'Notification marked as read';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error marking as read: $e';
      });
    }
  }

  Future<void> _archiveNotification(String notificationId) async {
    try {
      await _notificationManager.archiveNotification(notificationId);
      setState(() {
        _statusMessage = 'Notification archived';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error archiving: $e';
      });
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Marking all as read...';
      });

      await _notificationManager.markAllAsRead();

      setState(() {
        _isLoading = false;
        _statusMessage = 'All notifications marked as read';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error marking all as read: $e';
      });
    }
  }

  Future<void> _getNotificationCounts() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Getting notification counts...';
      });

      final counts = await _notificationManager.getNotificationCounts();

      setState(() {
        _isLoading = false;
        _statusMessage = 'Counts updated: ${counts.toString()}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error getting counts: $e';
      });
    }
  }

  Future<void> _searchNotifications(String query) async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Searching notifications...';
      });

      final results = await _notificationManager.searchNotifications(
        query: query,
      );

      setState(() {
        _isLoading = false;
        _statusMessage =
            'Found ${results.length} notifications matching "$query"';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error searching: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification System Test'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          if (_unreadCount > 0)
            Badge(
              label: Text('$_unreadCount'),
              child: IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  // Show notification details
                },
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Status and controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Text(
                  _statusMessage,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: CircularProgressIndicator(),
                  ),
                const SizedBox(height: 16),
                // Control buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: _isLoading ? null : _loadNotifications,
                      child: const Text('Refresh'),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createTestNotification,
                      child: const Text('Create Lead Notification'),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _createSystemNotification,
                      child: const Text('Create System Notification'),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _markAllAsRead,
                      child: const Text('Mark All Read'),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _getNotificationCounts,
                      child: const Text('Get Counts'),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () => _searchNotifications('test'),
                      child: const Text('Search "test"'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Statistics
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', _counts['total'] ?? 0, Colors.blue),
                _buildStatCard('Unread', _counts['unread'] ?? 0, Colors.red),
                _buildStatCard('Read', _counts['read'] ?? 0, Colors.green),
                _buildStatCard(
                  'Archived',
                  _counts['archived'] ?? 0,
                  Colors.orange,
                ),
              ],
            ),
          ),

          // Notifications list
          Expanded(
            child: _notifications.isEmpty
                ? const Center(
                    child: Text(
                      'No notifications found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(notification_model.Notification notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: notification.isUnread ? 4 : 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(
            int.parse(notification.type.colorHex.substring(1), radix: 16) +
                0xFF000000,
          ),
          child: Text(
            notification.type.displayName[0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isUnread
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  notification.timeAgo,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(
                            notification.priority.colorHex.substring(1),
                            radix: 16,
                          ) +
                          0xFF000000,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notification.priority.displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Color(
                      int.parse(
                            notification.status.colorHex.substring(1),
                            radix: 16,
                          ) +
                          0xFF000000,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notification.status.displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'read',
              child: Text(
                notification.isUnread ? 'Mark as Read' : 'Mark as Unread',
              ),
            ),
            const PopupMenuItem(value: 'archive', child: Text('Archive')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) {
            switch (value) {
              case 'read':
                _markAsRead(notification.id);
                break;
              case 'archive':
                _archiveNotification(notification.id);
                break;
              case 'delete':
                // Implement delete functionality
                break;
            }
          },
        ),
        onTap: () {
          if (notification.isUnread) {
            _markAsRead(notification.id);
          }
          // Navigate to notification details or action URL
        },
      ),
    );
  }

  @override
  void dispose() {
    _notificationManager.dispose();
    super.dispose();
  }
}
