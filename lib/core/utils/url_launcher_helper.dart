import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'url_launcher_helper_stub.dart'
    if (dart.library.js_interop) 'url_launcher_helper_web.dart';

/// Opens the given [url] in an external window/browser or triggers direct download.
///
/// On web: Uses native DOM anchor click navigation for zero dependency on
/// method-channel plugins, ensuring popup-blocker immunity and instant download.
///
/// On native platforms (Android, iOS, desktop): Uses [url_launcher] with
/// [LaunchMode.externalApplication].
Future<bool> safeLaunchUrl(String url) async {
  if (kIsWeb) {
    final opened = openPlatformWebUrl(url);
    if (opened) return true;
  }

  try {
    final Uri uri = Uri.parse(url);
    return await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  } catch (e) {
    debugPrint('safeLaunchUrl error: $e');
    try {
      final Uri uri = Uri.parse(url);
      return await launchUrl(uri);
    } catch (_) {
      return false;
    }
  }
}
