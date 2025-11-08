import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/utils/page_transitions.dart';
import '../screens/leads/lead_detail_screen.dart';

/// Widget for viewing lead details
class LeadViewIcon extends StatelessWidget {
  const LeadViewIcon({super.key, required this.leadId});

  final String leadId;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(
          SmoothPageTransitions.slideFromRight<void>(
            child: LeadDetailScreen(leadId: leadId),
          ),
        );
      },
      icon: const Icon(FontAwesomeIcons.eye, size: 12, color: Colors.blue),
      tooltip: 'View',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}
