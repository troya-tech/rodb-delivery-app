import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/interfaces/map_launcher.dart';

class MapLauncherImpl implements MapLauncher {
  @override
  Future<void> launchMap({
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    final encodedAddress = Uri.encodeComponent(address);

    try {
      if (!kIsWeb && Platform.isAndroid) {
        // Android: geo: intent with address as query + coordinates as hint.
        // This lets the default maps app geocode the address text, snapping
        // to the correct building instead of a raw lat/lng pin.
        final geoUrl = Uri.parse(
          'geo:$latitude,$longitude?q=$encodedAddress',
        );

        if (await canLaunchUrl(geoUrl)) {
          await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
          return;
        }
      } else if (!kIsWeb && Platform.isIOS) {
        // iOS: Apple Maps with ll (pin location) + q (label).
        final appleMapsUrl = Uri.parse(
          'https://maps.apple.com/?ll=$latitude,$longitude&q=$encodedAddress',
        );

        if (await canLaunchUrl(appleMapsUrl)) {
          await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
          return;
        }
      }

      // Fallback (web or if native intents fail): Google Maps search by
      // address text so it geocodes to the right place.
      final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress',
      );
      await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
    } catch (e) {
      debugPrint('Error launching maps: $e');
      // Last-resort: open Google Maps with raw coordinates.
      final fallbackUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );
      await launchUrl(fallbackUrl, mode: LaunchMode.platformDefault);
    }
  }
}

