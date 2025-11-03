import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../data/services/supabase_service.dart';
import '../../data/services/location_service.dart';
import '../services/permission_manager.dart';
import '../../core/constants/constants.dart';
import 'timezone.dart';
import '../../data/services/call_service.dart';
import '../../data/services/database_service_masters.dart' as masters;

class Helpers {
  static const MethodChannel _recorderChannel = MethodChannel(
    'tigger/recorder',
  );
  static StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  static bool _callInProgress = false;

  // Launch phone dialer with given phone number. Uses tel: scheme.
  static Future<void> launchDialer(String phoneNumber) async {
    final String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri uri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // Place a call. On Android, uses native recorder channel to place and record.
  // On other platforms, falls back to opening the dialer.
  static Future<void> placeCall(String phoneNumber) async {
    final String cleaned = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (Platform.isAndroid) {
      // Require internet connectivity for call; if offline, do nothing
      final List<ConnectivityResult> current = await Connectivity()
          .checkConnectivity();
      final bool offline =
          current.isEmpty || current.contains(ConnectivityResult.none);
      if (offline) {
        return;
      }

      // Ensure required permissions only once and avoid repeated prompts
      final bool callPermsOk = await PermissionManager.ensureCallPermissions();
      if (!callPermsOk) {
        await PermissionManager.openSettingsIfPermanentlyDenied();
        return;
      }

      try {
        _callInProgress = true;
        // Start native call + foreground recording service
        await _recorderChannel.invokeMethod('startCall', <String, Object?>{
          'number': cleaned,
        });

        // Monitor connectivity; if it drops, stop recording service
        _connectivitySub?.cancel();
        _connectivitySub = Connectivity().onConnectivityChanged.listen((
          List<ConnectivityResult> results,
        ) async {
          if (!_callInProgress) return;
          final bool nowOffline =
              results.isEmpty || results.contains(ConnectivityResult.none);
          if (nowOffline) {
            try {
              await _recorderChannel.invokeMethod('endCall');
            } catch (_) {}
            _callInProgress = false;
            await _connectivitySub?.cancel();
            _connectivitySub = null;
          }
        });
      } on PlatformException {
        // Fallback to dialer if native channel fails
        await launchDialer(cleaned);
      }
    } else {
      await launchDialer(cleaned);
    }
  }

  // Should be called when app detects call ended (optional cleanup)
  static Future<void> cleanupAfterCall() async {
    _callInProgress = false;
    await _connectivitySub?.cancel();
    _connectivitySub = null;
  }

  // One-stop call flow: create calls row, place call, upload recording, update calls, and log lead activity
  static Future<void> placeCallAndLog({
    required String phone,
    String? leadId,
    String direction = 'outbound',
  }) async {
    final String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Identify current user
    final currentUser = supabase.Supabase.instance.client.auth.currentUser;
    final String initiatedBy =
        currentUser?.id ?? '00000000-0000-0000-0000-000000000000';
    final String initiatedByName =
        (currentUser?.userMetadata?['name'] as String?) ?? 'System User';

    String? callId;
    try {
      // Create a call row (RPC) so we can later attach recording/status
      callId = await CallService.logCall(
        phone: cleaned,
        direction: direction,
        leadId: leadId,
        initiatedByName: initiatedByName,
        metadata: <String, dynamic>{'initiated_by': initiatedBy},
      );
    } catch (e) {
      // Surface error but continue with placing the call so UX isn’t blocked
      // ignore: avoid_print
      print('Error creating call record: $e');
    }

    // Place native call and start recording service
    await placeCall(cleaned);

    // Ensure we only proceed after the call actually connects (OFFHOOK)
    print('Waiting for call to start (OFFHOOK)...');
    final bool started = await _waitForCallToStart();
    if (!started) {
      print('Call did not start within timeout. Skipping upload.');
    } else {
      // Wait for call to end and recording to be finalized before uploading
      print('Call connected. Waiting for call to disconnect...');
      await _waitForCallToEnd();

      // Additional small delay to ensure file is completely written
      print('Recording finalized. Adding brief delay before upload...');
      await Future<void>.delayed(const Duration(seconds: 2));

      // Try to upload any available recording
      String? recordingUrl;
      try {
        recordingUrl = await uploadLastRecordingToSupabase();
        if (recordingUrl != null) {
          print('Recording uploaded successfully: $recordingUrl');
        } else {
          print('No recording URL obtained after upload attempt');
        }
      } catch (e) {
        // ignore: avoid_print
        print('Recording upload failed: $e');
      }

      // Update calls status with optional recording
      try {
        if (callId != null) {
          await CallService.endCallWithRecording(
            callId: callId,
            status: 'completed',
            recordingUrl: recordingUrl,
            endedAt: DateTime.now(),
          );
          print(
            'Call record updated with recording URL: ${recordingUrl != null ? "Yes" : "No"}',
          );
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error updating call completion: $e');
      }

      // Log activity against lead if available
      if (leadId != null) {
        try {
          await masters.DatabaseServiceMasters.logCallInitiated(
            leadId: leadId,
            phoneNumber: cleaned,
            performedBy: initiatedBy,
            performedByName: initiatedByName,
            recordingUrl: recordingUrl,
          );
        } catch (e) {
          // ignore: avoid_print
          print('Failed to log lead activity for call: $e');
        }
      }
    }
  }

  // Wait for call to start by polling the native call state (OFFHOOK observed)
  static Future<bool> _waitForCallToStart() async {
    int attempts = 0;
    const int maxAttempts = 120; // up to ~60s

    while (attempts < maxAttempts) {
      try {
        final bool? isActive = await _recorderChannel.invokeMethod<bool>(
          'isCallActive',
        );
        if (isActive == true) {
          print('Call start detected after ${attempts * 500}ms');
          return true;
        }
      } catch (e) {
        print('Error checking call start state: $e');
      }
      attempts++;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    return false;
  }

  // Wait for call to end by polling the native call state
  // Ensures call has actually disconnected and recording is finalized
  static Future<void> _waitForCallToEnd() async {
    int attempts = 0;
    const int maxAttempts = 600; // 5 minutes max wait time (600 * 500ms)

    print('Waiting for call to disconnect...');
    bool callDisconnected = false;

    // First, wait for call to disconnect (IDLE state)
    while (attempts < maxAttempts && !callDisconnected) {
      try {
        final bool? isActive = await _recorderChannel.invokeMethod<bool>(
          'isCallActive',
        );

        if (isActive == false) {
          // Check if call has ended
          final bool? hasEnded = await _recorderChannel.invokeMethod<bool>(
            'hasCallEnded',
          );

          if (hasEnded == true) {
            callDisconnected = true;
            print('Call disconnected detected after ${attempts * 500}ms');
            break;
          }
        }

        attempts++;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        print('Error checking call disconnect state: $e');
        attempts++;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }

    if (!callDisconnected) {
      print(
        'Timeout waiting for call to disconnect after ${maxAttempts * 500}ms',
      );
      return;
    }

    // Now wait for recording to be finalized (file written to disk)
    print('Call disconnected. Waiting for recording to finalize...');
    attempts = 0;
    const int finalizeMaxAttempts = 40; // 20 seconds max for finalization

    while (attempts < finalizeMaxAttempts) {
      try {
        final bool? isFinalized = await _recorderChannel.invokeMethod<bool>(
          'isRecordingFinalized',
        );

        if (isFinalized == true) {
          print('Recording finalized confirmed after ${attempts * 500}ms');
          return;
        }

        // Also verify by checking file directly
        final String? path = await _recorderChannel.invokeMethod<String>(
          'getLastRecordingPath',
        );

        if (path != null && path.isNotEmpty) {
          final File f = File(path);
          if (await f.exists()) {
            final int size = await f.length();
            if (size > 1024) {
              // File exists and has meaningful content
              print('Recording file verified: $path ($size bytes)');
              return;
            }
          }
        }

        attempts++;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        print('Error checking recording finalization: $e');
        attempts++;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    }

    print(
      'Timeout waiting for recording to finalize. Proceeding with upload anyway...',
    );
  }

  // Call when you want to fetch the last recording and upload it to Supabase
  static Future<String?> uploadLastRecordingToSupabase() async {
    try {
      print('Starting recording upload process...');

      // Poll for a finalized recording file path and non-empty size
      String? path;
      int attempts = 0;
      const int maxAttempts =
          120; // ~60s max @ 500ms interval (increased for reliability)

      while (attempts < maxAttempts) {
        try {
          path = await _recorderChannel.invokeMethod<String>(
            'getLastRecordingPath',
          );

          if (path != null && path.isNotEmpty) {
            final File f = File(path);
            if (await f.exists()) {
              final int size = await f.length();
              print(
                'Recording file check: $path ($size bytes) - attempt ${attempts + 1}',
              );

              // Require minimum file size (e.g., 1KB) to ensure it's not just metadata
              if (size > 1024) {
                print('Recording file found and ready: $path ($size bytes)');
                break;
              } else {
                print(
                  'Recording file exists but too small ($size bytes), waiting...',
                );
              }
            } else {
              print('Recording file does not exist yet, waiting...');
            }
          } else {
            print('No recording path available yet, waiting...');
          }
        } catch (e) {
          print('Error checking recording path: $e');
        }

        attempts++;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }

      if (path == null || path.isEmpty) {
        print(
          'No recording file found after $maxAttempts attempts (${maxAttempts * 500}ms)',
        );
        return null;
      }

      // Double-check file exists and has content before upload
      final File finalFile = File(path);
      if (!await finalFile.exists()) {
        print('Recording file disappeared before upload: $path');
        return null;
      }

      final int finalSize = await finalFile.length();
      if (finalSize < 1024) {
        print('Recording file is too small or empty: $path ($finalSize bytes)');
        return null;
      }

      print('Uploading recording to Supabase: $path ($finalSize bytes)');

      // Upload with retry mechanism
      String? publicUrl;
      int uploadAttempts = 0;
      const int maxUploadAttempts = 3;

      while (uploadAttempts < maxUploadAttempts && publicUrl == null) {
        try {
          publicUrl = await SupabaseService.uploadRecording(
            bucket: AppConstants.recordingsBucket,
            filePath: path,
            destFolder: AppConstants.recordingsFolder,
          );

          if (publicUrl.isNotEmpty) {
            print('Recording uploaded successfully: $publicUrl');
            break;
          }
        } catch (e) {
          uploadAttempts++;
          print('Upload attempt ${uploadAttempts} failed: $e');
          if (uploadAttempts < maxUploadAttempts) {
            print('Retrying upload in 2 seconds...');
            await Future<void>.delayed(const Duration(seconds: 2));
          }
        }
      }

      if (publicUrl == null || publicUrl.isEmpty) {
        print('Failed to upload recording after $maxUploadAttempts attempts');
        return null;
      }

      return publicUrl;
    } catch (e, stackTrace) {
      print('Error uploading recording: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Returns a non-empty file path if a recording file exists and has size > 0
  static Future<String?> verifyLastRecordingReady({
    Duration timeout = const Duration(seconds: 20),
  }) async {
    try {
      final int maxAttempts = (timeout.inMilliseconds / 500).ceil();
      int attempts = 0;
      while (attempts < maxAttempts) {
        final String? path = await _recorderChannel.invokeMethod<String>(
          'getLastRecordingPath',
        );
        if (path != null && path.isNotEmpty) {
          final File f = File(path);
          if (await f.exists() && await f.length() > 0) {
            return path;
          }
        }
        attempts++;
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    } catch (_) {}
    return null;
  }

  // Debug helper to inspect last recorded file path from native
  static Future<String?> getLastRecordingPath() async {
    try {
      final String? path = await _recorderChannel.invokeMethod<String>(
        'getLastRecordingPath',
      );
      // ignore: avoid_print
      // CallRecord: last path: ${path ?? '(none)'}
      return path;
    } catch (_) {
      return null;
    }
  }

  // Format currency
  static String formatCurrency(double amount, {String symbol = '₹'}) {
    final formatted = _formatNumberWithCommas(amount);
    return '$symbol$formatted';
  }

  // Format number with commas
  static String formatNumber(double number) {
    return _formatNumberWithCommas(number);
  }

  // Format date
  static String formatDate(DateTime date, {String pattern = 'dd-MM-yyyy'}) {
    final DateTime ist = TimezoneUtil.toIST(date);
    return _formatDateTime(ist, pattern);
  }

  // Format date and time
  static String formatDateTime(
    DateTime dateTime, {
    String pattern = 'dd-MM-yyyy HH:mm',
  }) {
    final DateTime ist = TimezoneUtil.toIST(dateTime);
    return _formatDateTime(ist, pattern);
  }

  // Format time
  static String formatTime(DateTime time, {String pattern = 'HH:mm'}) {
    final DateTime ist = TimezoneUtil.toIST(time);
    return _formatDateTime(ist, pattern);
  }

  // Helper method to format number with commas
  static String _formatNumberWithCommas(double number) {
    final parts = number.toString().split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    final reversed = integerPart.split('').reversed.join('');
    final withCommas = reversed.replaceAllMapped(
      RegExp(r'(\d{3})'),
      (match) => '${match.group(0)},',
    );

    return withCommas
            .split('')
            .reversed
            .join('')
            .replaceFirst(RegExp(r'^,'), '') +
        decimalPart;
  }

  // Helper method to format date and time
  static String _formatDateTime(DateTime dateTime, String pattern) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');

    return pattern
        .replaceAll('dd', day)
        .replaceAll('MM', month)
        .replaceAll('yyyy', year)
        .replaceAll('HH', hour)
        .replaceAll('mm', minute)
        .replaceAll('ss', second);
  }

  // Get relative time (e.g., "2 hours ago", "3 days ago")
  static String getRelativeTime(DateTime dateTime) {
    final DateTime nowIst = TimezoneUtil.nowIST();
    final DateTime dtIst = TimezoneUtil.toIST(dateTime);
    final difference = nowIst.difference(dtIst);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Get initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '?';

    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else {
      return '${words[0][0]}${words[words.length - 1][0]}'.toUpperCase();
    }
  }

  // Show a standard success dialog
  static Future<void> showSuccessDialog(
    BuildContext context, {
    required String title,
    String? message,
  }) async {
    if (!context.mounted) return;
    return showDialog<void>(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(child: Text(title)),
            ],
          ),
          content: message != null ? Text(message) : null,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;

    return text
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : word,
        )
        .join(' ');
  }

  // Truncate text
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Check if email is valid
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Check if phone number is valid
  static bool isValidPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    return cleanPhone.length >= 10 && cleanPhone.length <= 15;
  }

  // Format phone number
  static String formatPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.length == 10) {
      return '${cleanPhone.substring(0, 5)} ${cleanPhone.substring(5)}';
    } else if (cleanPhone.length == 11 && cleanPhone.startsWith('0')) {
      return '${cleanPhone.substring(0, 5)} ${cleanPhone.substring(5)}';
    } else if (cleanPhone.length == 12 && cleanPhone.startsWith('91')) {
      return '+91 ${cleanPhone.substring(2, 7)} ${cleanPhone.substring(7)}';
    }

    return phone;
  }

  // Generate random string
  static String generateRandomString(int length) {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      buffer.write(chars[(random + i) % chars.length]);
    }

    return buffer.toString();
  }

  // Generate unique ID
  static String generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return '${timestamp}_$random';
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  // Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  // Check if date is this month
  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // Get start of day
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get end of day
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  // Get start of week
  static DateTime getStartOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // Get end of week
  static DateTime getEndOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }

  // Get start of month
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end of month
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // Calculate age
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }

  // Get file extension
  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  // Get file size in human readable format
  static String getFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  // Deep copy of a map
  static Map<String, dynamic> deepCopyMap(Map<String, dynamic> map) {
    final newMap = <String, dynamic>{};
    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        newMap[key] = deepCopyMap(value);
      } else if (value is List) {
        newMap[key] = List.from(value);
      } else {
        newMap[key] = value;
      }
    });
    return newMap;
  }

  // Check if string is null or empty
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  // Check if list is null or empty
  static bool isListNullOrEmpty(List? list) {
    return list == null || list.isEmpty;
  }

  // Get first non-null value
  static T? firstNonNull<T>(List<T?> values) {
    for (final value in values) {
      if (value != null) return value;
    }
    return null;
  }

  // Safe string conversion
  static String safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  // Safe int conversion
  static int safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  // Safe double conversion
  static double safeDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  // Safe bool conversion
  static bool safeBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return defaultValue;
  }

  /// Get current location coordinates
  static Future<String?> getCurrentLocation() async {
    try {
      final String? location = await LocationService.getLocationString();
      if (location != null) {
        // Location: Current location: $location
      }
      return location;
    } catch (e) {
      // Location: Error getting current location: $e
      return null;
    }
  }

  /// Check if location services are available
  static Future<bool> isLocationAvailable() async {
    try {
      return await LocationService.isLocationAvailable();
    } catch (e) {
      // Location: Error checking location availability: $e
      return false;
    }
  }

  /// Request location permissions
  static Future<bool> requestLocationPermission() async {
    try {
      return await LocationService.requestLocationPermission();
    } catch (e) {
      // Location: Error requesting location permission: $e
      return false;
    }
  }

  /// Get current user name from authentication and profile data
  static Future<String> getCurrentUserName() async {
    try {
      final currentUser = supabase.Supabase.instance.client.auth.currentUser;
      if (currentUser?.id != null) {
        // Try to get name from user metadata first
        final String? metadataName =
            currentUser?.userMetadata?['name'] as String?;
        if (metadataName != null && metadataName.isNotEmpty) {
          return metadataName;
        }

        // Fallback to getting from profiles table
        final profile = await SupabaseService.getProfile(currentUser!.id);
        if (profile != null) {
          final String? fullName = profile['full_name'] as String?;
          if (fullName != null && fullName.isNotEmpty) {
            return fullName;
          }
        }
      }
      return 'System User';
    } catch (e) {
      return 'System User';
    }
  }

  /// Get current user ID from authentication
  static String? getCurrentUserId() {
    return supabase.Supabase.instance.client.auth.currentUser?.id;
  }

  /// Get current user role from public.users table
  static Future<String?> getCurrentUserRole() async {
    try {
      final currentUser = supabase.Supabase.instance.client.auth.currentUser;
      if (currentUser?.id != null) {
        final response = await supabase.Supabase.instance.client
            .from('users')
            .select('role')
            .eq('id', currentUser!.id)
            .eq('is_active', true)
            .maybeSingle();

        return response?['role'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Check if current user has admin or head role
  static Future<bool> isAdminOrHead() async {
    final role = await getCurrentUserRole();
    return role == 'admin' || role == 'head';
  }

  /// Check if current user can assign leads (admin or head only)
  static Future<bool> canAssignLeads() async {
    return await isAdminOrHead();
  }
}
