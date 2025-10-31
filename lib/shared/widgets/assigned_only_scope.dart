import 'package:flutter/widgets.dart';

class AssignedOnlyScope extends InheritedWidget {
  const AssignedOnlyScope({
    super.key,
    required this.assignedOnly,
    required super.child,
  });

  final bool assignedOnly;

  static AssignedOnlyScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AssignedOnlyScope>();
  }

  static AssignedOnlyScope of(BuildContext context) {
    final AssignedOnlyScope? scope = maybeOf(context);
    assert(scope != null, 'No AssignedOnlyScope found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant AssignedOnlyScope oldWidget) {
    return assignedOnly != oldWidget.assignedOnly;
  }
}
