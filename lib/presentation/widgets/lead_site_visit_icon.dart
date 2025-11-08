import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/utils/page_transitions.dart';
import '../screens/projects/add_site_visit_screen.dart';

/// Widget for adding a site visit
class LeadSiteVisitIcon extends StatelessWidget {
  const LeadSiteVisitIcon({super.key, required this.leadId});

  final String leadId;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).push(
          SmoothPageTransitions.slideFromBottom<void>(
            child: AddSiteVisitScreen(leadId: leadId),
          ),
        );
      },
      icon: const Icon(
        FontAwesomeIcons.locationDot,
        size: 12,
        color: Colors.orange,
      ),
      tooltip: 'Site Visit',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}
