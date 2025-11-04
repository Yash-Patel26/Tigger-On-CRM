import 'package:flutter/material.dart';
import '../../../data/models/models.dart';

class BasicDetailsCard extends StatelessWidget {
  const BasicDetailsCard({super.key, required this.lead});
  final Lead lead;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (lead.dob != null)
              _buildInfoRow(
                context,
                'Date of Birth',
                lead.dob!.toIso8601String().split('T')[0],
              ),
            if (lead.age != null)
              _buildInfoRow(context, 'Age', lead.age!.toString()),
            if (lead.gender != null && lead.gender!.isNotEmpty)
              _buildInfoRow(context, 'Gender', lead.gender!),
            if (lead.maritalStatus != null && lead.maritalStatus!.isNotEmpty)
              _buildInfoRow(context, 'Marital Status', lead.maritalStatus!),
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
