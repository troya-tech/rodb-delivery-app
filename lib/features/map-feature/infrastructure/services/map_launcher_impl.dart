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
    
    // Google Maps Search URL using address
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedAddress');
    
    // Apple Maps Search URL using address
    final appleMapsUrl = Uri.parse('https://maps.apple.com/?q=$encodedAddress');

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(appleMapsUrl)) {
        await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to coordinates if address search fails (unlikely)
        final geoUrl = Uri.parse('geo:$latitude,$longitude?q=$encodedAddress');
        
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
