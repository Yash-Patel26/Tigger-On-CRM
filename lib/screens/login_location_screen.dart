import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

class LoginLocationScreen extends StatefulWidget {
  const LoginLocationScreen({super.key});

  @override
  State<LoginLocationScreen> createState() => _LoginLocationScreenState();
}

class _LoginLocationScreenState extends State<LoginLocationScreen> {
  List<UserLoginLocation> _loginHistory = [];
  Map<String, dynamic> _loginStats = {};
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadLoginData();
  }

  Future<void> _loadLoginData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final history = await AuthService.getUserLoginHistory(limit: 20);
      final stats = await AuthService.getUserLoginStats();

      setState(() {
        _loginHistory = history;
        _loginStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Locations'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading login data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadLoginData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _buildStatsCard(),
                const SizedBox(height: 16),
                Expanded(child: _buildLoginHistory()),
              ],
            ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Login Statistics',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Logins',
                    '${_loginStats['totalLogins'] ?? 0}',
                    Icons.login,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Success Rate',
                    '${_loginStats['successRate'] ?? 0}%',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Countries',
                    '${(_loginStats['countries'] as List?)?.length ?? 0}',
                    Icons.public,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Cities',
                    '${(_loginStats['cities'] as List?)?.length ?? 0}',
                    Icons.location_city,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            if (_loginStats['lastLogin'] != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Last Login: ${_formatDateTime(_loginStats['lastLogin'])}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginHistory() {
    if (_loginHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No login history found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _loginHistory.length,
      itemBuilder: (context, index) {
        final login = _loginHistory[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: login.isSuccessful ? Colors.green : Colors.red,
              child: Icon(
                login.isSuccessful ? Icons.check : Icons.close,
                color: Colors.white,
              ),
            ),
            title: Text(
              login.city ?? login.country ?? 'Unknown Location',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (login.country != null) Text('Country: ${login.country}'),
                if (login.state != null) Text('State: ${login.state}'),
                if (login.deviceType != null)
                  Text('Device: ${login.deviceType}'),
                if (login.deviceOs != null) Text('OS: ${login.deviceOs}'),
                if (login.ipAddress != null) Text('IP: ${login.ipAddress}'),
                Text(
                  'Time: ${_formatDateTime(login.loginTimestamp.toIso8601String())}',
                ),
                if (!login.isSuccessful && login.failureReason != null)
                  Text(
                    'Failed: ${login.failureReason}',
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
            isThreeLine: true,
            trailing: Icon(
              _getDeviceIcon(login.deviceType),
              color: Colors.grey[600],
            ),
          ),
        );
      },
    );
  }

  IconData _getDeviceIcon(String? deviceType) {
    switch (deviceType?.toLowerCase()) {
      case 'mobile':
        return Icons.phone_android;
      case 'desktop':
        return Icons.desktop_windows;
      case 'web':
        return Icons.web;
      case 'tablet':
        return Icons.tablet;
      default:
        return Icons.device_unknown;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }
}
