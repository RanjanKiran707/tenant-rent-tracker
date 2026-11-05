import 'package:web/web.dart' as web;

/// Web implementation using native DOM navigation for reliable file downloads and links.
bool openPlatformWebUrl(String url) {
  try {
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.target = '_blank';
    anchor.rel = 'noopener noreferrer';
    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    return true;
  } catch (_) {
    try {
      web.window.open(url, '_blank');
      return true;
    } catch (_) {
      return false;
    }
  }
}
