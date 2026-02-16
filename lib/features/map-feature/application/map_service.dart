import '../domain/interfaces/map_launcher.dart';
import '../../map-feature/domain/address.dart';

class MapService {
  final MapLauncher _mapLauncher;

  MapService(this._mapLauncher);

  Future<void> launchMapForAddress(Address address) async {
    await _mapLauncher.launchMap(
      address: address.address,
      latitude: address.latitude,
      longitude: address.longitude,
    );
  }
}
