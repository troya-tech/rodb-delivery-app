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
    final hasCoordinates = latitude != 0.0 || longitude != 0.0;

    try {
      if (!kIsWeb && Platform.isAndroid) {
        // Android: When we have real coordinates, pin them directly using
        // the geo:0,0?q=lat,lng(label) format. This places a pin at the
        // exact coordinate instead of searching by address text (which
        // can land on the wrong spot for Turkish addresses).
        // Fall back to address-text search when coordinates are missing.
        final geoUrl = hasCoordinates
            ? Uri.parse(
                'geo:0,0?q=$latitude,$longitude($encodedAddress)',
              )
            : Uri.parse(
                'geo:0,0?q=$encodedAddress',
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

      // Fallback (web or if native intents fail): prefer coordinates so the
      // pin lands on the exact spot; fall back to address text.
      final query = hasCoordinates ? '$latitude,$longitude' : encodedAddress;
      final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$query',
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

