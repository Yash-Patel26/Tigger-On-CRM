import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/services/supabase_service.dart';
import '../../../data/services/location_data_service.dart';
import '../../../data/models/profile_model.dart';
import '../../../shared/utils/validation_utils.dart';
import '../../../shared/managers/auth_state_manager.dart';
import 'edit_profile_screen.dart';
import '../auth/email_login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<Profile?>? _profileFuture;

  // Location data cache
  final Map<String, String> _locationNames = {};

  @override
  void initState() {
    super.initState();
    final userId = SupabaseService.currentUser?.id;
    if (userId != null) {
      _profileFuture = _loadProfile(userId);
    }
  }

  Future<Profile?> _loadProfile(String userId) async {
    final Map<String, dynamic>? row = await SupabaseService.getProfile(userId);
    if (row == null) return null;

    // Map data based on whether it comes from users table or profiles table
    final Map<String, dynamic> mapped = <String, dynamic>{
      ...row,
      // tolerate snake/camel
      'id': row['id'] ?? row['ID'],
      'user_id': row['user_id'] ?? row['userId'] ?? userId,
      'full_name': row['full_name'] ?? row['name'] ?? row['username'] ?? '-',
      'avatar_url': row['avatar_url'] ?? row['profile_image_url'],
      'phone': row['phone'],
      'designation': row['designation'],
      'department': row['department'],
      'role': row['role'],
      'is_active': row['is_active'] ?? row['isActive'] ?? true,
      'created_at':
          row['created_at'] ??
          row['createdAt'] ??
          DateTime.now().toIso8601String(),
      'updated_at':
          row['updated_at'] ??
          row['updatedAt'] ??
          DateTime.now().toIso8601String(),
    };

    final profile = Profile.fromJson(mapped);

    // Load location names for display
    await _loadLocationNames(profile);

    return profile;
  }

  Future<void> _loadLocationNames(Profile profile) async {
    try {
      final metadata = profile.metadata ?? {};

      // Load country name
      if (metadata['country_id'] != null) {
        final countries = await LocationDataService.getCountries();
        final country = countries.firstWhere(
          (c) => c['id'].toString() == metadata['country_id'].toString(),
          orElse: () => {'name': 'Unknown'},
        );
        _locationNames['country'] = country['name'];
      }

      // Load state name
      if (metadata['state_id'] != null) {
        final states = await LocationDataService.getStatesByCountry(
          metadata['country_id'].toString(),
        );
        final state = states.firstWhere(
          (s) => s['id'].toString() == metadata['state_id'].toString(),
          orElse: () => {'name': 'Unknown'},
        );
        _locationNames['state'] = state['name'];
      }

      // Load city name
      if (metadata['city_id'] != null) {
        final cities = await LocationDataService.getCitiesByState(
          metadata['state_id'].toString(),
        );
        final city = cities.firstWhere(
          (c) => c['id'].toString() == metadata['city_id'].toString(),
          orElse: () => {'name': 'Unknown'},
        );
        _locationNames['city'] = city['name'];
      }

      // Load pincode
      if (metadata['pincode_id'] != null) {
        final pincodes = await LocationDataService.getPincodesByCity(
          metadata['city_id'].toString(),
        );
        final pincode = pincodes.firstWhere(
          (p) => p['id'].toString() == metadata['pincode_id'].toString(),
          orElse: () => {'pincode': 'Unknown'},
        );
        _locationNames['pincode'] = pincode['pincode'];
      }

      // Load project name
      if (metadata['project_id'] != null) {
        final projects = await LocationDataService.getProjects();
        final project = projects.firstWhere(
          (p) => p['id'].toString() == metadata['project_id'].toString(),
          orElse: () => {'name': 'Unknown'},
        );
        _locationNames['project'] = project['name'];
      }

      // Update UI after loading location names
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading location names: $e');
    }
  }

  void _refreshProfile() {
    final userId = SupabaseService.currentUser?.id;
    if (userId != null) {
      setState(() {
        _locationNames.clear(); // Clear cached location names
        _profileFuture = _loadProfile(userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: FutureBuilder<Profile?>(
        future: _profileFuture,
        builder: (BuildContext context, AsyncSnapshot<Profile?> snap) {
          if (SupabaseService.currentUser == null) {
            return const Center(child: Text('Not signed in'));
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final Profile? profile = snap.data;
          return RefreshIndicator(
            onRefresh: () async {
              _refreshProfile();
              // Wait for the profile to reload
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeader(context, profile: profile),
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
                        _IconKeyValueRow(
                          icon: Icons.alternate_email,
                          label: 'Mail ID',
                          value: SupabaseService.currentUser?.email ?? '-',
                        ),
                        const _DividerSpacer(),
                        _IconKeyValueRow(
                          icon: Icons.cake_outlined,
                          label: 'DOB',
                          value: profile?.metadata?['dob'] != null
                              ? ValidationUtils.formatDate(
                                  profile!.metadata!['dob'] as String,
                                )
                              : '-',
                        ),
                        const _DividerSpacer(),
                        _IconKeyValueRow(
                          icon: Icons.badge_outlined,
                          label: 'PAN Card',
                          value: profile?.metadata?['pan'] != null
                              ? ValidationUtils.formatPAN(
                                  profile!.metadata!['pan'] as String,
                                )
                              : '-',
                        ),
                        const _DividerSpacer(),
                        _IconKeyValueRow(
                          icon: Icons.credit_card,
                          label: 'Aadhar Card',
                          value: profile?.metadata?['aadhar'] != null
                              ? ValidationUtils.formatAadhar(
                                  profile!.metadata!['aadhar'] as String,
                                )
                              : '-',
                        ),
                        const _DividerSpacer(),
                        _IconKeyValueRow(
                          icon: Icons.flag_outlined,
                          label: 'Country',
                          value: _locationNames['country'] ?? '-',
                        ),
                        const _DividerSpacer(),
                        _IconKeyValueRow(
                          icon: Icons.map_outlined,
                          label: 'State',
                          value: _locationNames['state'] ?? '-',
                        ),
                        const _DividerSpacer(),
                        _IconKeyValueRow(
                          icon: Icons.location_city,
                          label: 'City',
                          value: _locationNames['city'] ?? '-',
                        ),
                        const _DividerSpacer(),
                        _IconKeyValueRow(
                          icon: Icons.home_outlined,
                          label: 'Address',
                          value:
                              profile?.metadata?['address'] as String? ?? '-',
                        ),
                        const _DividerSpacer(),
                        _IconKeyValueRow(
                          icon: Icons.local_post_office_outlined,
                          label: 'Pincode',
                          value: _locationNames['pincode'] ?? '-',
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
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        _TableSection(
                          columns: const <String>[
                            'Sr. No',
                            'IVR Name',
                            'IVR Number',
                          ],
                          rows: <List<String>>[
                            <String>[
                              '1',
                              profile?.metadata?['ivr_name'] as String? ?? '-',
                              profile?.metadata?['ivr_number'] as String? ??
                                  '-',
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Team Detail',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        _TableSection(
                          columns: const <String>['Sr. No', 'Team Name'],
                          rows: <List<String>>[
                            <String>[
                              '1',
                              profile?.metadata?['team'] as String? ?? '-',
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Group Detail',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        _TableSection(
                          columns: const <String>['Sr. No', 'Group Name'],
                          rows: <List<String>>[
                            <String>[
                              '1',
                              profile?.metadata?['group'] as String? ?? '-',
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Project Name · User Type',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        _TableSection(
                          columns: const <String>[
                            'Sr. No',
                            'Project Name',
                            'User Type',
                          ],
                          rows: <List<String>>[
                            <String>[
                              '1',
                              _locationNames['project'] ?? '-',
                              profile?.metadata?['user_type'] as String? ?? '-',
                            ],
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
                        _AboutRow(
                          label: 'Version',
                          value:
                              profile?.metadata?['app_version'] as String? ??
                              '1.0.0',
                        ),
                        _AboutRow(
                          label: 'Build',
                          value:
                              profile?.metadata?['build'] as String? ??
                              '2025.09',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final authManager = Provider.of<AuthStateManager>(
                          context,
                          listen: false,
                        );
                        // Sign out immediately - this will clear session and trigger AuthWrapper to redirect
                        await authManager.signOut();
                        // Navigate immediately to login screen, clearing all routes
                        if (context.mounted) {
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const EmailLoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Log out'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {Profile? profile}) {
    return _SectionCard(
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 34,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.12),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                profile?.avatarUrl ??
                    'https://via.placeholder.com/150/6366f1/ffffff?text=User',
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  profile?.fullName.isNotEmpty == true
                      ? profile!.fullName
                      : (SupabaseService.currentUser?.email?.split('@').first ??
                            'User'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  SupabaseService.currentUser?.email ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: profile != null
                ? () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute<bool>(
                            builder: (context) =>
                                EditProfileScreen(profile: profile),
                          ),
                        )
                        .then((result) {
                          if (result == true) {
                            // Force refresh the profile data
                            _refreshProfile();
                          }
                        });
                  }
                : null,
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
