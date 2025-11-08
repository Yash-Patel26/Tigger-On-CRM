import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../shared/utils/helpers.dart';

/// Widget for calling a lead
class LeadCallIcon extends StatelessWidget {
  const LeadCallIcon({super.key, required this.phone, required this.leadUuid});

  final String phone;
  final String leadUuid;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await Helpers.placeCallAndLog(
          phone: phone,
          leadId: leadUuid,
          direction: 'outbound',
        );
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Call completed')));
        }
      },
      icon: const Icon(FontAwesomeIcons.phone, size: 12, color: Colors.green),
      tooltip: 'Call',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}
