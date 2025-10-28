import 'package:flutter/material.dart';

import '../widgets/timeline_activity_list.dart';

class TimelineTabWhatsApp extends StatelessWidget {
  const TimelineTabWhatsApp({super.key, required this.activities});
  final List<Map<String, dynamic>> activities;

  @override
  Widget build(BuildContext context) {
    return TimelineActivityList(activities: activities);
  }
}
