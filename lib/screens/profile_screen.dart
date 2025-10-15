import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(context),
            const SizedBox(height: 16),
            // Removed Stats section per request
            const SizedBox(height: 0),
            // Basic Details
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _SectionTitle('Basic Details'),
                  const SizedBox(height: 12),
                  const _IconKeyValueRow(
                    icon: Icons.alternate_email,
                    label: 'Mail ID',
                    value: 'alex.johnson@example.com',
                  ),
                  const _DividerSpacer(),
                  const _IconKeyValueRow(
                    icon: Icons.cake_outlined,
                    label: 'DOB',
                    value: '14 Mar 1994',
                  ),
                  const _DividerSpacer(),
                  const _IconKeyValueRow(
                    icon: Icons.badge_outlined,
                    label: 'PAN Card',
                    value: 'ABCDE1234F',
                  ),
                  const _DividerSpacer(),
                  const _IconKeyValueRow(
                    icon: Icons.credit_card,
                    label: 'Aadhar Card',
                    value: '1234 5678 9012',
                  ),
                  const _DividerSpacer(),
                  const _IconKeyValueRow(
                    icon: Icons.flag_outlined,
                    label: 'Country',
                    value: 'India',
                  ),
                  const _DividerSpacer(),
                  const _IconKeyValueRow(
                    icon: Icons.map_outlined,
                    label: 'State',
                    value: 'Maharashtra',
                  ),
                  const _DividerSpacer(),
                  const _IconKeyValueRow(
                    icon: Icons.location_city,
                    label: 'City',
                    value: 'Mumbai',
                  ),
                  const _DividerSpacer(),
                  const _IconKeyValueRow(
                    icon: Icons.home_outlined,
                    label: 'Address',
                    value: '221B Baker Street, Andheri West',
                  ),
                  const _DividerSpacer(),
                  const _IconKeyValueRow(
                    icon: Icons.local_post_office_outlined,
                    label: 'Pincode',
                    value: '400053',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Mapping Details
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _SectionTitle('Mapping Details'),
                  const SizedBox(height: 12),
                  Text(
                    'IVR Number Details',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _TableSection(
                    columns: const <String>['Sr. No', 'IVR Name', 'IVR Number'],
                    rows: const <List<String>>[
                      <String>['1', 'Sales Line', '+91 22 4000 1111'],
                      <String>['2', 'Support Line', '+91 22 4000 2222'],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Team Detail',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _TableSection(
                    columns: const <String>['Sr. No', 'Team Name'],
                    rows: const <List<String>>[
                      <String>['1', 'North Sales'],
                      <String>['2', 'Key Accounts'],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Group Detail',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _TableSection(
                    columns: const <String>['Sr. No', 'Group Name'],
                    rows: const <List<String>>[
                      <String>['1', 'Lead Managers'],
                      <String>['2', 'Field Agents'],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Project Name · User Type',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _TableSection(
                    columns: const <String>[
                      'Sr. No',
                      'Project Name',
                      'User Type',
                    ],
                    rows: const <List<String>>[
                      <String>['1', 'Project Alpha', 'Admin'],
                      <String>['2', 'Project Beta', 'Viewer'],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  _SectionTitle('Preferences'),
                  SizedBox(height: 8),
                  _SettingsTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                  ),
                  _SettingsTile(
                    icon: Icons.palette_outlined,
                    title: 'Appearance',
                  ),
                  _SettingsTile(
                    icon: Icons.language_outlined,
                    title: 'Language',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _SectionTitle('About'),
                  const SizedBox(height: 8),
                  _AboutRow(label: 'App', value: 'TiggerOn'),
                  _AboutRow(label: 'Version', value: '1.0.0'),
                  _AboutRow(label: 'Build', value: '2025.09'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return _SectionCard(
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 34,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.12),
            child: const CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Alex Johnson',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'alex.johnson@example.com',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}

// Stats row removed per request

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).iconTheme.color,
      ),
      onTap: () {},
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Copy',
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: value));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('Copied')));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }
}

// (legacy) _KeyValueRow replaced by _IconKeyValueRow; keeping removed to avoid lint

class _IconKeyValueRow extends StatelessWidget {
  const _IconKeyValueRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: Theme.of(context).iconTheme.color),
          const SizedBox(width: 10),
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.9),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _DividerSpacer extends StatelessWidget {
  const _DividerSpacer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(color: _panelBorderColor(context)),
    );
  }
}

class _TableSection extends StatelessWidget {
  const _TableSection({required this.columns, required this.rows});

  final List<String> columns;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final TextStyle? headerStyle = Theme.of(
      context,
    ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700);
    final TextStyle? cellStyle = Theme.of(context).textTheme.bodySmall;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _panelBorderColor(context)),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: <Widget>[
          Container(
            color: _panelColor(context),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: <Widget>[
                for (int i = 0; i < columns.length; i++)
                  Expanded(
                    flex: i == 0 ? 1 : 2,
                    child: Text(columns[i], style: headerStyle),
                  ),
              ],
            ),
          ),
          for (final List<String> row in rows)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: _panelBorderColor(context)),
                ),
              ),
              child: Row(
                children: <Widget>[
                  for (int i = 0; i < row.length; i++)
                    Expanded(
                      flex: i == 0 ? 1 : 2,
                      child: Text(row[i], style: cellStyle),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Color _panelColor(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark
      ? Colors.white.withOpacity(0.06)
      : Colors.black.withOpacity(0.04);
}

Color _panelBorderColor(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? Colors.white.withOpacity(0.12) : const Color(0x22000000);
}
