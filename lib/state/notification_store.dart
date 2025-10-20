import 'package:flutter/foundation.dart';
import '../models/app_notification.dart';

class NotificationStore extends ChangeNotifier {
  final List<AppNotification> _items = <AppNotification>[];

  List<AppNotification> get items => List<AppNotification>.unmodifiable(_items);

  int get unreadCount => _items.where((AppNotification n) => n.unread).length;

  void add(AppNotification n) {
    _items.insert(0, n);
    notifyListeners();
  }

  void addAll(Iterable<AppNotification> list) {
    _items.insertAll(0, list);
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((AppNotification n) => n.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void markAllRead() {
    for (int i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(unread: false);
    }
    notifyListeners();
  }

  void toggleRead(String id) {
    final int idx = _items.indexWhere((AppNotification e) => e.id == id);
    if (idx == -1) return;
    _items[idx] = _items[idx].copyWith(unread: !_items[idx].unread);
    notifyListeners();
  }
}
