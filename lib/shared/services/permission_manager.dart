import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionManager {
  static const String _requestedOnceKey = 'permissions_requested_once';

  static Future<bool> ensureCorePermissions() async {
    // On web, permissions APIs below are unsupported; no-op
    if (kIsWeb) return true;
    if (!Platform.isAndroid) return true;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool requestedOnce = prefs.getBool(_requestedOnceKey) ?? false;

    final bool micOk = await _ensurePermission(Permission.microphone);
    final bool phoneOk = await _ensurePermission(Permission.phone);
    final bool notifOk = await _ensurePermission(Permission.notification);

    // Location via Geolocator to avoid duplicate dialogs with permission_handler
    bool locationOk = true;
    final LocationPermission locStatus = await Geolocator.checkPermission();
    if (locStatus == LocationPermission.denied) {
      final LocationPermission after = await Geolocator.requestPermission();
      locationOk =
          after == LocationPermission.always ||
          after == LocationPermission.whileInUse;
    } else if (locStatus == LocationPermission.deniedForever) {
      locationOk = false;
    }

    // Mark that we have attempted at least once to avoid redundant flows
    if (!requestedOnce) {
      await prefs.setBool(_requestedOnceKey, true);
    }

    return micOk && phoneOk && notifOk && locationOk;
  }

  static Future<bool> ensureCallPermissions() async {
    if (kIsWeb) return true;
    if (!Platform.isAndroid) return true;

    final bool micOk = await _ensurePermission(Permission.microphone);
    final bool phoneOk = await _ensurePermission(Permission.phone);
    final bool notifOk = await _ensurePermission(Permission.notification);
    return micOk && phoneOk && notifOk;
  }

  static Future<bool> _ensurePermission(Permission permission) async {
    final PermissionStatus status = await permission.status;
    if (status.isGranted || status.isLimited) return true;
    if (status.isPermanentlyDenied) return false;
    final PermissionStatus after = await permission.request();
    return after.isGranted || after.isLimited;
  }

  static Future<void> openSettingsIfPermanentlyDenied() async {
    if (kIsWeb) return;
    if (!Platform.isAndroid) return;
    final List<Permission> perms = <Permission>[
      Permission.microphone,
      Permission.phone,
      Permission.notification,
    ];
    for (final Permission p in perms) {
      final PermissionStatus s = await p.status;
      if (s.isPermanentlyDenied) {
        await openAppSettings();
        break;
      }
    }
  }
}
