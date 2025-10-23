import 'package:flutter/material.dart';
import '../../../data/models/notification_model.dart' as notification_model;
import '../../../data/repositories/notification_repository.dart';
import '../../../data/services/supabase_service.dart';
import '../leads/lead_detail_screen.dart';
import '../leads/lead_screen.dart';
import '../bookings/booking_screen.dart';
import '../projects/site_visit_detail_screen.dart';
import '../projects/site_visit_screen.dart';
import '../ticket_hub_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../customer_screen.dart';
import '../projects/project_detail_screen.dart';

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
      // Get current user ID
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated. Please log in.');
      }

      final notifications = await _notificationRepository.getNotifications(
        userId: currentUser.id,
      );
      if (mounted) {
        setState(() {
          _allNotifications = notifications;
          _filteredNotifications = _allNotifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading notifications: $e';
          _isLoading = false;
        });
      }
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
      await _notificationRepository.markAsRead(notification.id);
      _loadNotifications(); // Refresh the list
      _showSnackBar('Notification marked as read');
    } catch (e) {
      _showSnackBar('Error marking as read: $e');
    }
  }

  void _navigateToRelatedScreen(notification_model.Notification notification) {
    // Debug: Print notification details
    print('🔔 Notification tapped:');
    print('  Type: ${notification.type}');
    print('  Related ID: ${notification.relatedId}');
    print('  Related Type: ${notification.relatedType}');
    print('  Action URL: ${notification.actionUrl}');

    // Mark as read first
    _markAsRead(notification);

    // Navigate based on notification type and related data
    switch (notification.type) {
      case notification_model.NotificationType.lead:
        print('📍 Navigating to Lead screen');
        if (notification.relatedId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  LeadDetailScreen(leadId: notification.relatedId!),
            ),
          );
        } else {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const LeadScreen()));
        }
        break;

      case notification_model.NotificationType.booking:
        print('📍 Navigating to Booking screen');
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const BookingScreen()));
        break;

      case notification_model.NotificationType.siteVisit:
        print('📍 Navigating to Site Visit screen');
        if (notification.relatedId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SiteVisitDetailScreen(
                siteVisitId: notification.relatedId!,
                siteVisitData: notification.data ?? {},
              ),
            ),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SiteVisitScreen()),
          );
        }
        break;

      case notification_model.NotificationType.ticket:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const TicketHubScreen()),
        );
        break;

      case notification_model.NotificationType.system:
        // For system notifications, check if there's a specific action URL
        if (notification.actionUrl != null &&
            notification.actionUrl!.isNotEmpty) {
          _navigateToActionUrl(notification.actionUrl!);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
        break;

      case notification_model.NotificationType.reminder:
        // For reminders, navigate to the related entity or dashboard
        if (notification.relatedType == 'lead' &&
            notification.relatedId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  LeadDetailScreen(leadId: notification.relatedId!),
            ),
          );
        } else if (notification.relatedType == 'booking' &&
            notification.relatedId != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const BookingScreen()),
          );
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
        break;

      case notification_model.NotificationType.alert:
        // For alerts, navigate to dashboard or specific screen based on data
        if (notification.data != null && notification.data!['screen'] != null) {
          // Handle specific screen navigation based on data
          _navigateToSpecificScreen(notification.data!['screen']);
        } else {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
        break;
    }
  }

  void _navigateToSpecificScreen(String screenName) {
    // Handle specific screen navigation based on screen name
    switch (screenName) {
      case 'leads':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const LeadScreen()));
        break;
      case 'bookings':
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const BookingScreen()));
        break;
      case 'site-visits':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const SiteVisitScreen()),
        );
        break;
      case 'tickets':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const TicketHubScreen()),
        );
        break;
      default:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
        break;
    }
  }

  void _navigateToActionUrl(String actionUrl) {
    print('🔗 Navigating to action URL: $actionUrl');
    // Handle different action URL patterns
    if (actionUrl.startsWith('/')) {
      // Internal navigation - map to specific screens
      switch (actionUrl) {
        case '/dashboard':
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
          break;
        case '/leads':
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const LeadScreen()));
          break;
        case '/bookings':
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const BookingScreen()),
          );
          break;
        case '/site-visits':
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SiteVisitScreen()),
          );
          break;
        case '/tickets':
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const TicketHubScreen()),
          );
          break;
        default:
          // Handle specific ID-based URLs
          if (actionUrl.startsWith('/leads/')) {
            print('📍 Navigating to Lead Detail for URL: $actionUrl');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    LeadDetailScreen(leadId: actionUrl.split('/')[2]),
              ),
            );
          } else if (actionUrl.startsWith('/bookings/')) {
            print('📍 Navigating to Booking Screen for URL: $actionUrl');
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const BookingScreen()),
            );
          } else if (actionUrl.startsWith('/site-visits/')) {
            print('📍 Navigating to Site Visit Detail for URL: $actionUrl');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SiteVisitDetailScreen(
                  siteVisitId: actionUrl.split('/')[2],
                  siteVisitData: {},
                ),
              ),
            );
          } else if (actionUrl.startsWith('/customers/')) {
            print('📍 Navigating to Customer Screen for URL: $actionUrl');
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CustomerScreen()),
            );
          } else if (actionUrl.startsWith('/projects/')) {
            print('📍 Navigating to Project Detail for URL: $actionUrl');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProjectDetailScreen(
                  project: {'id': actionUrl.split('/')[2]},
                ),
              ),
            );
          } else if (actionUrl.startsWith('/maintenance')) {
            print('📍 Navigating to Dashboard for maintenance URL: $actionUrl');
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          } else {
            print('📍 Unknown action URL, defaulting to Dashboard: $actionUrl');
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          }
          break;
      }
    } else if (actionUrl.startsWith('http')) {
      // External URL - could open in browser or show webview
      _showSnackBar('External link: $actionUrl');
      // TODO: Implement external URL handling
    } else {
      // Default to dashboard
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const DashboardScreen()));
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      // Get current user ID
      final currentUser = SupabaseService.currentUser;
      if (currentUser == null) {
        _showSnackBar('User not authenticated. Please log in.');
        return;
      }

      await _notificationRepository.markAllAsRead(currentUser.id);
      _loadNotifications(); // Refresh the list
      _showSnackBar('All notifications marked as read');
    } catch (e) {
      _showSnackBar('Error marking all as read: $e');
    }
  }

  Future<void> _deleteNotification(
    notification_model.Notification notification,
  ) async {
    try {
      await _notificationRepository.deleteNotification(notification.id);
      _loadNotifications(); // Refresh the list
      _showSnackBar('Notification deleted');
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
              initialValue: _selectedType,
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
              initialValue: _selectedPriority,
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
              initialValue: _selectedStatus,
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
        onTap: () => _navigateToRelatedScreen(notification),
        splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        highlightColor: Theme.of(context).colorScheme.primary.withOpacity(0.05),
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
                            const SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.3),
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
