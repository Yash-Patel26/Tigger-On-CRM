// Only compiled on web thanks to conditional import
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

String? getWebOrigin() {
  try {
    return html.window.location.origin;
  } catch (_) {
    return null;
  }
}
