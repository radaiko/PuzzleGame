import 'package:get_it/get_it.dart';
import 'package:puzzle_game/services/settings_service.dart';

/// Global service locator instance
final GetIt serviceLocator = GetIt.instance;

/// Initialize all services
Future<void> initializeServices() async {
  serviceLocator.registerSingleton<SettingsService>(SettingsService());

  final settingsService = serviceLocator<SettingsService>();
  await settingsService.initialize();
}

SettingsService get settings => serviceLocator<SettingsService>();
