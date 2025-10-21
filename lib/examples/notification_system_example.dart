import 'package:flutter/material.dart';
import '../models/notification_model.dart' as notification_model;
import '../repositories/notification_repository.dart';
import '../managers/notification_manager.dart';
import '../helpers/notification_helper.dart';

class NotificationSystemExample {
  static final NotificationManager _notificationManager = NotificationManager();
  static final NotificationRepository _repository = NotificationRepository();

  // Example: Initialize notification system for a user
  static Future<void> initializeForUser(String userId) async {
    _notificationManager.initialize(userId);

    // Listen to real-time notifications
    _notificationManager.notificationsStream.listen((notifications) {
      print('Received ${notifications.length} notifications');
      for (var notification in notifications) {
        print('${notification.type.displayName}: ${notification.title}');
      }
    });

    // Listen to unread count changes
    _notificationManager.unreadCountStream.listen((count) {
      print('Unread notifications: $count');
    });
  }

  // Example: Create various types of notifications
  static Future<void> createSampleNotifications(String userId) async {
    try {
      // Create a lead notification
      await NotificationHelper.createLeadAssignedNotification(
        userId: userId,
        leadId: 'lead-123',
        customerName: 'John Doe',
        projectName: 'Green Valley Apartments',
        priority: notification_model.NotificationPriority.high,
      );

      // Create a site visit notification
      await NotificationHelper.createSiteVisitScheduledNotification(
        userId: userId,
        siteVisitId: 'sv-456',
        customerName: 'Jane Smith',
        projectName: 'Green Valley Apartments',
        visitTime: DateTime.now().add(const Duration(days: 1)),
        priority: notification_model.NotificationPriority.high,
      );

      // Create a booking notification
      await NotificationHelper.createBookingConfirmedNotification(
        userId: userId,
        bookingId: 'bk-789',
        customerName: 'Mike Johnson',
        projectName: 'Green Valley Apartments',
        amount: 5000000,
        priority: notification_model.NotificationPriority.urgent,
      );

      // Create a ticket notification
      await NotificationHelper.createTicketCreatedNotification(
        userId: userId,
        ticketId: 'tk-101',
        issueTitle: 'Water leakage issue',
        contactName: 'Sarah Wilson',
        priority: notification_model.NotificationPriority.medium,
      );

      // Create a system notification
      await NotificationHelper.createSystemMaintenanceNotification(
        title: 'Scheduled Maintenance',
        message: 'System will be under maintenance tonight from 11 PM to 1 AM',
        maintenanceStart: DateTime.now().add(const Duration(hours: 2)),
        maintenanceEnd: DateTime.now().add(const Duration(hours: 4)),
        userId: userId,
      );

      // Create a reminder notification
      await NotificationHelper.createTaskReminderNotification(
        userId: userId,
        taskTitle: 'Follow up with client',
        dueDate: DateTime.now().add(const Duration(hours: 2)),
        taskId: 'task-202',
      );

      print('Sample notifications created successfully!');
    } catch (e) {
      print('Error creating sample notifications: $e');
    }
  }

  // Example: Get and display notifications
  static Future<void> displayUserNotifications(String userId) async {
    try {
      // Get all notifications
      final notifications = await _notificationManager.getNotifications();
      print('Total notifications: ${notifications.length}');

      // Get unread notifications
      final unreadNotifications = notifications
          .where((n) => n.isUnread)
          .toList();
      print('Unread notifications: ${unreadNotifications.length}');

      // Get urgent notifications
      final urgentNotifications = await _notificationManager
          .getUrgentNotifications();
      print('Urgent notifications: ${urgentNotifications.length}');

      // Get recent notifications
      final recentNotifications = await _notificationManager
          .getRecentNotifications(limit: 5);
      print('Recent notifications: ${recentNotifications.length}');

      // Display notifications by type
      for (var type in notification_model.NotificationType.values) {
        final typeNotifications = notifications
            .where((n) => n.type == type)
            .toList();
        if (typeNotifications.isNotEmpty) {
          print(
            '${type.displayName} notifications: ${typeNotifications.length}',
          );
        }
      }

      // Display notification details
      for (var notification in notifications.take(3)) {
        print('---');
        print('Title: ${notification.title}');
        print('Message: ${notification.message}');
        print('Type: ${notification.type.displayName}');
        print('Priority: ${notification.priority.displayName}');
        print('Status: ${notification.status.displayName}');
        print('Time: ${notification.timeAgo}');
        print('Action URL: ${notification.actionUrl}');
        if (notification.data != null) {
          print('Data: ${notification.data}');
        }
      }
    } catch (e) {
      print('Error displaying notifications: $e');
    }
  }

  // Example: Manage notification states
  static Future<void> manageNotificationStates(String userId) async {
    try {
      // Get notifications
      final notifications = await _notificationManager.getNotifications();

      if (notifications.isNotEmpty) {
        final firstNotification = notifications.first;

        // Mark as read
        await _notificationManager.markAsRead(firstNotification.id);
        print('Marked notification as read: ${firstNotification.title}');

        // Archive notification
        if (notifications.length > 1) {
          final secondNotification = notifications[1];
          await _notificationManager.archiveNotification(secondNotification.id);
          print('Archived notification: ${secondNotification.title}');
        }

        // Mark all as read
        await _notificationManager.markAllAsRead();
        print('Marked all notifications as read');

        // Get updated counts
        final counts = await _notificationManager.getNotificationCounts();
        print('Updated counts: $counts');
      }
    } catch (e) {
      print('Error managing notification states: $e');
    }
  }

  // Example: Search notifications
  static Future<void> searchNotifications(String userId, String query) async {
    try {
      final searchResults = await _notificationManager.searchNotifications(
        query: query,
      );
      print('Search results for "$query": ${searchResults.length}');

      for (var notification in searchResults) {
        print('- ${notification.title}: ${notification.message}');
      }
    } catch (e) {
      print('Error searching notifications: $e');
    }
  }

  // Example: Get notification statistics
  static Future<void> getNotificationStatistics(String userId) async {
    try {
      final counts = await _notificationManager.getNotificationCounts();

      print('=== Notification Statistics ===');
      print('Total: ${counts['total']}');
      print('Unread: ${counts['unread']}');
      print('Read: ${counts['read']}');
      print('Archived: ${counts['archived']}');
      print('--- By Type ---');
      print('Leads: ${counts['lead']}');
      print('Bookings: ${counts['booking']}');
      print('Site Visits: ${counts['siteVisit']}');
      print('Tickets: ${counts['ticket']}');
      print('System: ${counts['system']}');
      print('Reminders: ${counts['reminder']}');
      print('Alerts: ${counts['alert']}');
    } catch (e) {
      print('Error getting notification statistics: $e');
    }
  }

  // Example: Real-time notification handling
  static void setupRealTimeHandling(String userId) {
    // Listen to notifications stream
    _notificationManager.notificationsStream.listen((notifications) {
      // Handle new notifications
      for (var notification in notifications) {
        if (notification.isUnread) {
          _showNotificationAlert(notification);
        }
      }
    });

    // Listen to unread count changes
    _notificationManager.unreadCountStream.listen((count) {
      // Update UI badge or indicator
      _updateUnreadBadge(count);
    });
  }

  static void _showNotificationAlert(
    notification_model.Notification notification,
  ) {
    // This would typically show a system notification or in-app alert
    print(
      '🔔 New ${notification.type.displayName} notification: ${notification.title}',
    );
  }

  static void _updateUnreadBadge(int count) {
    // This would typically update a badge in the UI
    print('Badge updated: $count unread notifications');
  }

  // Example: Cleanup
  static void cleanup() {
    _notificationManager.dispose();
    _repository.dispose();
  }
}

// Example widget for displaying notifications
class NotificationListWidget extends StatefulWidget {
  final String userId;

  const NotificationListWidget({Key? key, required this.userId})
    : super(key: key);

  @override
  State<NotificationListWidget> createState() => _NotificationListWidgetState();
}

class _NotificationListWidgetState extends State<NotificationListWidget> {
  final NotificationManager _notificationManager = NotificationManager();
  List<notification_model.Notification> _notifications = [];
  Map<String, int> _counts = {};
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    _notificationManager.initialize(widget.userId);

    // Listen to notifications
    _notificationManager.notificationsStream.listen((notifications) {
      if (mounted) {
        setState(() {
          _notifications = notifications;
        });
      }
    });

    // Listen to counts
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
  }

  Future<void> _loadNotifications() async {
    try {
      await _notificationManager.getNotifications();
      await _notificationManager.getNotificationCounts();
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await _notificationManager.markAsRead(notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> _archiveNotification(String notificationId) async {
    try {
      await _notificationManager.archiveNotification(notificationId);
    } catch (e) {
      print('Error archiving notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
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
          // Statistics
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', _counts['total'] ?? 0),
                _buildStatCard('Unread', _counts['unread'] ?? 0),
                _buildStatCard('Read', _counts['read'] ?? 0),
                _buildStatCard('Archived', _counts['archived'] ?? 0),
              ],
            ),
          ),
          // Notifications list
          Expanded(
            child: ListView.builder(
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

  Widget _buildStatCard(String label, int count) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(notification_model.Notification notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
