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

  // Keep the child experience in portrait orientation.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
