import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:alphabet_adventure/app.dart';
import 'package:alphabet_adventure/data/repositories/content_repository.dart';
import 'package:alphabet_adventure/data/repositories/progress_repository.dart';
import 'package:alphabet_adventure/data/repositories/settings_repository.dart';
import 'package:alphabet_adventure/data/services/analytics_service.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/data/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fredoka is bundled in assets/fonts/ and declared in pubspec.yaml, so the app
  // never requests it over the network. This keeps the app genuinely
  // offline-only, which the store listing claims and the Play Data safety
  // declaration depends on.
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(const ['Fredoka'], license);
  });

  // Keep the child experience in portrait orientation.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hide the status bar while keeping Android navigation buttons visible over
  // the app's transparent bottom navigation area.
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.bottom],
  );
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  // Initialize storage service
  final storageService = await StorageService.create();

  // Initialize services
  final audioService = AudioService();
  await audioService.init();
  final analyticsService = AnalyticsService();

  // Initialize repositories
  final contentRepository = ContentRepository();
  final progressRepository = ProgressRepository(storageService: storageService);
  await progressRepository.init();

  final settingsRepository = SettingsRepository(
    storageService: storageService,
    audioService: audioService,
  );
  await settingsRepository.init();

  runApp(
    AlphabetAdventureApp(
      audioService: audioService,
      analyticsService: analyticsService,
      contentRepository: contentRepository,
      progressRepository: progressRepository,
      settingsRepository: settingsRepository,
    ),
  );
}
