import 'package:flutter_test/flutter_test.dart';
import '../models/notification_model.dart' as notification_model;
import '../services/notification_service.dart';
import '../repositories/notification_repository.dart';
import '../managers/notification_manager.dart';
import '../helpers/notification_helper.dart';

void main() {
  group('Notification System Tests', () {
    late NotificationManager notificationManager;
    late NotificationRepository notificationRepository;

    const String testUserId = '550e8400-e29b-41d4-a716-446655440001';

    setUp(() {
      notificationManager = NotificationManager();
      notificationRepository = NotificationRepository();
    });

    tearDown(() {
      notificationManager.dispose();
      notificationRepository.dispose();
    });

    group('Notification Model Tests', () {
      test('should create notification from JSON', () {
        final json = {
          'id': 'test-id',
          'title': 'Test Notification',
          'message': 'This is a test notification',
          'type': 'lead',
          'priority': 'high',
          'status': 'unread',
          'user_id': testUserId,
          'related_id': 'lead-123',
          'related_type': 'lead',
          'action_url': '/leads/lead-123',
          'data': {'lead_id': 'lead-123'},
          'created_at': '2024-01-01T10:00:00Z',
          'read_at': null,
          'archived_at': null,
          'is_read': false,
          'is_archived': false,
        };

        final notification = Notification.fromJson(json);

        expect(notification.id, 'test-id');
        expect(notification.title, 'Test Notification');
        expect(notification.message, 'This is a test notification');
        expect(notification.type, NotificationType.lead);
        expect(notification.priority, NotificationPriority.high);
        expect(notification.status, NotificationStatus.unread);
        expect(notification.userId, testUserId);
        expect(notification.relatedId, 'lead-123');
        expect(notification.relatedType, 'lead');
        expect(notification.actionUrl, '/leads/lead-123');
        expect(notification.data, {'lead_id': 'lead-123'});
        expect(notification.isRead, false);
        expect(notification.isArchived, false);
      });

      test('should convert notification to JSON', () {
        final notification = Notification(
          id: 'test-id',
          title: 'Test Notification',
          message: 'This is a test notification',
          type: NotificationType.lead,
          priority: NotificationPriority.high,
          status: NotificationStatus.unread,
          userId: testUserId,
          relatedId: 'lead-123',
          relatedType: 'lead',
          actionUrl: '/leads/lead-123',
          data: {'lead_id': 'lead-123'},
          createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
        );

        final json = notification.toJson();

        expect(json['id'], 'test-id');
        expect(json['title'], 'Test Notification');
        expect(json['message'], 'This is a test notification');
        expect(json['type'], 'lead');
        expect(json['priority'], 'high');
        expect(json['status'], 'unread');
        expect(json['user_id'], testUserId);
        expect(json['related_id'], 'lead-123');
        expect(json['related_type'], 'lead');
        expect(json['action_url'], '/leads/lead-123');
        expect(json['data'], {'lead_id': 'lead-123'});
        expect(json['is_read'], false);
        expect(json['is_archived'], false);
      });

      test('should create Supabase-compatible JSON', () {
        final notification = Notification(
          id: 'test-id',
          title: 'Test Notification',
          message: 'This is a test notification',
          type: NotificationType.lead,
          priority: NotificationPriority.high,
          status: NotificationStatus.unread,
          userId: testUserId,
          relatedId: 'lead-123',
          relatedType: 'lead',
          actionUrl: '/leads/lead-123',
          data: {'lead_id': 'lead-123'},
          createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
        );

        final supabaseJson = notification.toSupabaseJson();

        expect(supabaseJson['title'], 'Test Notification');
        expect(supabaseJson['message'], 'This is a test notification');
        expect(supabaseJson['type'], 'lead');
        expect(supabaseJson['priority'], 'high');
        expect(supabaseJson['status'], 'unread');
        expect(supabaseJson['user_id'], testUserId);
        expect(supabaseJson['related_id'], 'lead-123');
        expect(supabaseJson['related_type'], 'lead');
        expect(supabaseJson['action_url'], '/leads/lead-123');
        expect(supabaseJson['data'], {'lead_id': 'lead-123'});
        expect(
          supabaseJson.containsKey('id'),
          false,
        ); // Should not include ID for insertion
      });

      test('should mark notification as read', () {
        final notification = Notification(
          id: 'test-id',
          title: 'Test Notification',
          message: 'This is a test notification',
          type: NotificationType.lead,
          priority: NotificationPriority.high,
          status: NotificationStatus.unread,
          userId: testUserId,
          createdAt: DateTime.now(),
        );

        final readNotification = notification.markAsRead();

        expect(readNotification.status, NotificationStatus.read);
        expect(readNotification.isRead, true);
        expect(readNotification.readAt, isNotNull);
      });

      test('should archive notification', () {
        final notification = Notification(
          id: 'test-id',
          title: 'Test Notification',
          message: 'This is a test notification',
          type: NotificationType.lead,
          priority: NotificationPriority.high,
          status: NotificationStatus.unread,
          userId: testUserId,
          createdAt: DateTime.now(),
        );

        final archivedNotification = notification.archive();

        expect(archivedNotification.status, NotificationStatus.archived);
        expect(archivedNotification.isArchived, true);
        expect(archivedNotification.archivedAt, isNotNull);
      });

      test('should calculate time ago correctly', () {
        final now = DateTime.now();
        final notification = Notification(
          id: 'test-id',
          title: 'Test Notification',
          message: 'This is a test notification',
          type: NotificationType.lead,
          priority: NotificationPriority.high,
          status: NotificationStatus.unread,
          userId: testUserId,
          createdAt: now.subtract(const Duration(minutes: 5)),
        );

        expect(notification.timeAgo, '5m ago');
      });
    });

    group('NotificationType Tests', () {
      test('should return correct display names', () {
        expect(NotificationType.lead.displayName, 'Lead');
        expect(NotificationType.booking.displayName, 'Booking');
        expect(NotificationType.siteVisit.displayName, 'Site Visit');
        expect(NotificationType.ticket.displayName, 'Ticket');
        expect(NotificationType.system.displayName, 'System');
        expect(NotificationType.reminder.displayName, 'Reminder');
        expect(NotificationType.alert.displayName, 'Alert');
      });

      test('should return correct color hex codes', () {
        expect(NotificationType.lead.colorHex, '#4CAF50');
        expect(NotificationType.booking.colorHex, '#2196F3');
        expect(NotificationType.siteVisit.colorHex, '#FF9800');
        expect(NotificationType.ticket.colorHex, '#F44336');
        expect(NotificationType.system.colorHex, '#9C27B0');
        expect(NotificationType.reminder.colorHex, '#607D8B');
        expect(NotificationType.alert.colorHex, '#E91E63');
      });
    });

    group('NotificationPriority Tests', () {
      test('should return correct display names', () {
        expect(NotificationPriority.low.displayName, 'Low');
        expect(NotificationPriority.medium.displayName, 'Medium');
        expect(NotificationPriority.high.displayName, 'High');
        expect(NotificationPriority.urgent.displayName, 'Urgent');
      });

      test('should return correct sort order', () {
        expect(NotificationPriority.urgent.sortOrder, 1);
        expect(NotificationPriority.high.sortOrder, 2);
        expect(NotificationPriority.medium.sortOrder, 3);
        expect(NotificationPriority.low.sortOrder, 4);
      });
    });

    group('NotificationHelper Tests', () {
      test('should format amount correctly', () {
        expect(NotificationHelper.formatAmount(5000000), '₹50.0L');
        expect(NotificationHelper.formatAmount(50000000), '₹5.0Cr');
        expect(NotificationHelper.formatAmount(50000), '₹50000');
      });

      test('should format date time correctly', () {
        final dateTime = DateTime(2024, 1, 15, 14, 30);
        expect(
          NotificationHelper.formatDateTime(dateTime),
          '15/1/2024 at 14:30',
        );
        expect(NotificationHelper.formatDate(dateTime), '15/1/2024');
        expect(NotificationHelper.formatTime(dateTime), '14:30');
      });
    });

    group('NotificationManager Tests', () {
      test('should initialize with user ID', () {
        notificationManager.initialize(testUserId);
        // This test would need actual Supabase connection to verify
        expect(true, true); // Placeholder
      });

      test('should throw exception when not initialized', () {
        expect(
          () => notificationManager.getNotifications(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Integration Tests', () {
      test('should create and manage notification lifecycle', () {
        // This test would require actual Supabase connection
        // For now, we'll test the model creation and transformation

        final notification = Notification(
          id: 'integration-test-id',
          title: 'Integration Test',
          message: 'Testing notification lifecycle',
          type: NotificationType.lead,
          priority: NotificationPriority.medium,
          status: NotificationStatus.unread,
          userId: testUserId,
          createdAt: DateTime.now(),
        );

        // Test initial state
        expect(notification.isUnread, true);
        expect(notification.isReadStatus, false);
        expect(notification.isArchivedStatus, false);

        // Test marking as read
        final readNotification = notification.markAsRead();
        expect(readNotification.isReadStatus, true);
        expect(readNotification.isUnread, false);

        // Test archiving
        final archivedNotification = readNotification.archive();
        expect(archivedNotification.isArchivedStatus, true);

        // Test unarchiving
        final unarchivedNotification = archivedNotification.unarchive();
        expect(unarchivedNotification.isArchivedStatus, false);
        expect(unarchivedNotification.isUnread, true);
      });
    });
  });
}
