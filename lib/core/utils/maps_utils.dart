import 'package:url_launcher/url_launcher.dart';

/// Normalizes user input for Google Maps.
/// Accepts:
/// - Full Google Maps URL (https://maps.app.goo.gl/xxx or https://www.google.com/maps/...)
/// - "lat,lng" format like "13.7563,100.5018"
/// Returns a clean Google Maps URL, or null if invalid.
String? normalizeMapsInput(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  // Already a URL
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    // Clean common tracking params if needed, but keep it simple
    return trimmed;
  }

  // Try to parse as lat,lng
  final parts = trimmed.split(',');
  if (parts.length == 2) {
    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());

    if (lat != null && lng != null) {
      return 'https://www.google.com/maps?q=$lat,$lng';
    }
  }

  // Fallback: treat as search query
  final encoded = Uri.encodeComponent(trimmed);
  return 'https://www.google.com/maps/search/?api=1&query=$encoded';
}

/// Opens Google Maps in external app/browser so user can search and copy link.
Future<void> openGoogleMapsForSearch() async {
  const url = 'https://www.google.com/maps';
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Opens a specific mapsUrl (used when user taps the button on a Place card).
Future<void> openMapsUrl(String mapsUrl) async {
  final uri = Uri.parse(mapsUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}