import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityHelper {
  static final Connectivity _connectivity = Connectivity();

  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      final List<ConnectivityResult> connectivityResults = await _connectivity
          .checkConnectivity();

      // If no connectivity results or contains 'none', device is offline
      if (connectivityResults.isEmpty ||
          connectivityResults.contains(ConnectivityResult.none)) {
        return false;
      }

      // Device has some form of connectivity (mobile, wifi, ethernet, etc.)
      return true;
    } catch (e) {
      // If there's an error checking connectivity, assume no internet
      return false;
    }
  }

  /// Show internet connectivity error dialog
  static void showNoInternetDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              Icon(Icons.wifi_off, color: Colors.red, size: 24),
              const SizedBox(width: 8),
              const Text('No Internet Connection'),
            ],
          ),
          content: const Text(
            'Please connect to the internet to continue using the app.\n\n'
            'Check your Wi-Fi or mobile data connection and try again.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show internet connectivity error snackbar
  static void showNoInternetSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: <Widget>[
            Icon(Icons.wifi_off, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text('Please connect to the internet'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            // You can add retry logic here if needed
          },
        ),
      ),
    );
  }

  /// Stream of connectivity changes
  static Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  /// Check if device is currently online (synchronous check)
  static Future<bool> isOnline() async {
    return await hasInternetConnection();
  }
}
