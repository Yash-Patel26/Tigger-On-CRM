import 'package:flutter/material.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Map<String, dynamic> project;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> p = _mergeWithDefaults(project);
    final bool hasRera =
        (p['reraNo'] as String?) != null && (p['reraNo'] as String).isNotEmpty;
    final Color reraColor = hasRera
        ? const Color(0xFFE55934)
        : const Color(0xFFC62828);

    return Scaffold(
      appBar: AppBar(title: Text(p['name'] as String? ?? 'Project Detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _buildTopSummary(context, p, hasRera, reraColor),
          const SizedBox(height: 16),
          _buildAddressSection(context, p),
          const SizedBox(height: 16),
          _buildHighlightsSection(context, p),
          const SizedBox(height: 16),
          _buildMediaSection(context, p),
          const SizedBox(height: 16),
          _buildDetailsSection(context, p),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Map<String, dynamic> _mergeWithDefaults(Map<String, dynamic> input) {
    String? s(dynamic v) =>
        (v is String && v.trim().isEmpty) ? null : (v as String?);
    return <String, dynamic>{
      'projectId': s(input['projectId']) ?? 'PRJ-0000',
      'name': s(input['name']) ?? 'Sample Project',
      'category': s(input['category']) ?? 'Residential',
      'launchPrice': s(input['launchPrice']) ?? '₹ 30 L',
      'currentPrice':
          s(input['currentPrice']) ?? s(input['price']) ?? '₹ 45 L',
      'logo': input['logo'],
      'reraNo': s(input['reraNo']),
      'reraAuthority': s(input['reraAuthority']) ?? 'GujRERA',
      'location': s(input['location']) ?? 'Gift City',
      'city': s(input['city']) ?? 'Ahmedabad',
      'state': s(input['state']) ?? 'Gujarat',
      'lat': (input['lat'] as num?) ?? 23.0225,
      'lng': (input['lng'] as num?) ?? 72.5714,
      'highlights':
          s(input['highlights']) ??
          'Spacious units, green campus, premium amenities',
      'amenities':
          (input['amenities'] as List<String>?) ??
          <String>['Gym', 'Swimming Pool', 'Clubhouse', 'Children Park'],
      'locationAdvantage':
          s(input['locationAdvantage']) ??
          '5 mins from Metro, easy access to Ring Road and Airport',
      'paymentPlan':
          s(input['paymentPlan']) ?? '20:80 Subvention Plan available',
      'images':
          (input['images'] as List<String>?) ??
          <String>['img1', 'img2', 'img3'],
      'attachments':
          (input['attachments'] as List<Map<String, String>>?) ??
          <Map<String, String>>[
            <String, String>{'name': 'Price List.pdf'},
          ],
      'brochure': s(input['brochure']) ?? 'brochure.pdf',
      'details':
          s(input['details']) ??
          'A premium residential development offering modern living with excellent connectivity and amenities.',
    };
  }

  Widget _buildTopSummary(
    BuildContext context,
    Map<String, dynamic> p,
    bool hasRera,
    Color reraColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildLogo(p['logo']),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  p['name'] as String? ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                _kv('Project ID', p['projectId']),
                _kv('Category', p['category'] ?? '—'),
                _kv('Launch price (start)', p['launchPrice'] ?? '—'),
                _kv(
                  'Current market price',
                  p['currentPrice'] ?? (p['price'] ?? '—'),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _badge(
                      hasRera ? 'RERA Approved' : 'RERA Not Approved',
                      reraColor,
                    ),
                    if (hasRera) _badge('RERA No: ${p['reraNo']}', reraColor),
                    if (hasRera && p['reraAuthority'] != null)
                      _badge('Authority: ${p['reraAuthority']}', reraColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection(BuildContext context, Map<String, dynamic> p) {
    return _section(
      context,
      title: 'Project Address',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _kv('Location', p['location'] ?? '—'),
          _kv('City', p['city'] ?? '—'),
          _kv('State', p['state'] ?? '—'),
          _kv('Latitude', p['lat']?.toString() ?? '—'),
          _kv('Longitude', p['lng']?.toString() ?? '—'),
        ],
      ),
    );
  }

  Widget _buildHighlightsSection(BuildContext context, Map<String, dynamic> p) {
    final List<String> amenities =
        (p['amenities'] as List<String>?) ?? <String>[];
    return _section(
      context,
      title: 'Project Highlights',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (p['highlights'] != null) Text(p['highlights'] as String),
          const SizedBox(height: 8),
          if (amenities.isNotEmpty) ...<Widget>[
            Text(
              'Amenities',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: amenities
                  .map((String a) => Chip(label: Text(a)))
                  .toList(),
            ),
          ],
          if (p['locationAdvantage'] != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              'Location Advantage',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(p['locationAdvantage'] as String),
          ],
          if (p['paymentPlan'] != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              'Payment Plan',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(p['paymentPlan'] as String),
          ],
        ],
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context, Map<String, dynamic> p) {
    final List<String> images = (p['images'] as List<String>?) ?? <String>[];
    final List<Map<String, String>> attachments =
        (p['attachments'] as List<Map<String, String>>?) ??
        <Map<String, String>>[];

    return _section(
      context,
      title: 'Media & Documents',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (images.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, int i) => _imageThumb(images[i]),
              ),
            ),
          if (p['brochure'] != null) ...<Widget>[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('View Brochure'),
            ),
          ],
          if (attachments.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              'Attachments',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            ...attachments.map(
              (Map<String, String> a) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.attach_file),
                title: Text(a['name'] ?? 'Attachment'),
                onTap: () {},
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context, Map<String, dynamic> p) {
    return _section(
      context,
      title: 'Project Details',
      child: Text(p['details'] as String? ?? '—'),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _kv(String label, Object? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text('${value ?? '—'}')),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _imageThumb(String url) {
    return Container(
      width: 160,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _buildLogo(dynamic logo) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: const Icon(Icons.apartment, color: Colors.grey),
    );
  }
}
