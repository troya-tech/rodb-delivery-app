import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/interfaces/map_launcher.dart';
import '../infrastructure/services/map_launcher_impl.dart';
import 'map_service.dart';

/// Provider for the MapLauncher implementation
final mapLauncherProvider = Provider<MapLauncher>((ref) {
  return MapLauncherImpl();
});

/// Provider for the MapService
final mapServiceProvider = Provider<MapService>((ref) {
  final mapLauncher = ref.watch(mapLauncherProvider);
  return MapService(mapLauncher);
});
