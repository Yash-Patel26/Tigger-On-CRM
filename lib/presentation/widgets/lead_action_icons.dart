import 'package:flutter/material.dart';
import 'lead_view_icon.dart';
import 'lead_assign_icon.dart';
import 'lead_site_visit_icon.dart';
import 'lead_call_icon.dart';

/// Widget that displays action icons for a lead in the lead list
/// Includes: View, Assign (conditional), Site Visit, and Call icons
class LeadActionIcons extends StatelessWidget {
  const LeadActionIcons({
    super.key,
    required this.leadId,
    required this.leadUuid,
    required this.phone,
  });

  final String leadId; // Human-readable lead ID
  final String leadUuid; // UUID for database operations
  final String phone; // Phone number for calling

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        LeadViewIcon(leadId: leadId),
        LeadAssignIcon(leadId: leadId),
        LeadSiteVisitIcon(leadId: leadId),
        LeadCallIcon(phone: phone, leadUuid: leadUuid),
      ],
    );
  }
}
