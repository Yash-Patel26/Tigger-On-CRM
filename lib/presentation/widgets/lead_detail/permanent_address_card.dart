import 'package:flutter/material.dart';
import '../../../data/models/models.dart';

class PermanentAddressCard extends StatelessWidget {
  const PermanentAddressCard({super.key, required this.lead});
  final Lead lead;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (lead.address != null && lead.address!.isNotEmpty)
              _buildInfoRow(context, 'Address', lead.address!),
            if (lead.country != null && lead.country!.isNotEmpty)
              _buildInfoRow(context, 'Country', lead.country!),
            if (lead.stateName != null && lead.stateName!.isNotEmpty)
              _buildInfoRow(context, 'State', lead.stateName!)
            else if (lead.state != null && lead.state!.isNotEmpty)
              _buildInfoRow(context, 'State', lead.state!),
            if (lead.city != null && lead.city!.isNotEmpty)
              _buildInfoRow(context, 'City', lead.city!),
            if (lead.location != null && lead.location!.isNotEmpty)
              _buildInfoRow(context, 'Location', lead.location!),
            if (lead.pincode != null && lead.pincode!.isNotEmpty)
              _buildInfoRow(context, 'Pincode', lead.pincode!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
