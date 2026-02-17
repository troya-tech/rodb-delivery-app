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
    
    // Google Maps Search URL using coordinates for precision
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
    
    // Apple Maps Search URL using coordinates
    // Using ll (lat,long) puts a pin at the location, q (label) labels it
    final appleMapsUrl = Uri.parse('https://maps.apple.com/?ll=$latitude,$longitude&q=$encodedAddress');

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to coordinates
        final geoUrl = Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude');
        
        if (await canLaunchUrl(geoUrl)) {
          await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
        } else {
          throw 'No maps application found';
        }
      }
    } catch (e) {
      debugPrint('Error launching maps: $e');
      // If all else fails, try to launch the browser version
      await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
    }
  }
}
