import 'package:flutter/material.dart';

import '../widgets/timeline_activity_list.dart';

class TimelineTabAll extends StatelessWidget {
  const TimelineTabAll({super.key, required this.activities});
  final List<Map<String, dynamic>> activities;

  @override
  Widget build(BuildContext context) {
    return TimelineActivityList(activities: activities);
  }
}
