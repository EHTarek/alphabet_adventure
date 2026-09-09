import 'package:get_it/get_it.dart';

import 'package:alphabet_adventure/data/repositories/content_repository.dart';
import 'package:alphabet_adventure/data/repositories/progress_repository.dart';
import 'package:alphabet_adventure/data/repositories/settings_repository.dart';
import 'package:alphabet_adventure/data/services/analytics_service.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/data/services/storage_service.dart';
import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/mastery_engine.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/domain/engines/reward_engine.dart';
import 'package:alphabet_adventure/ui/features/profile/view_models/profile_view_model.dart';
import 'package:alphabet_adventure/ui/features/world_map/view_models/world_map_view_model.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Services
  final storageService = await StorageService.create();
  locator.registerSingleton<StorageService>(storageService);
  
  final audioService = AudioService();
  await audioService.init();
  locator.registerSingleton<AudioService>(audioService);
  
  locator.registerLazySingleton<AnalyticsService>(() => AnalyticsService());

  // Repositories
  locator.registerLazySingleton<ContentRepository>(() => ContentRepository());
  
  final progressRepository = ProgressRepository(storageService: locator());
  await progressRepository.init();
  locator.registerSingleton<ProgressRepository>(progressRepository);

  final settingsRepository = SettingsRepository(
    storageService: locator(),
    audioService: locator(),
  );
  await settingsRepository.init();
  locator.registerSingleton<SettingsRepository>(settingsRepository);

  // Engines
  locator.registerLazySingleton<QuestionEngine>(() => QuestionEngine());
  locator.registerLazySingleton<MasteryEngine>(() => const MasteryEngine());
  locator.registerLazySingleton<RewardEngine>(() => const RewardEngine());

  // ViewModels & Controllers
  locator.registerFactory<ProfileViewModel>(() => ProfileViewModel(
        progressRepository: locator(),
      ));
  locator.registerFactory<WorldMapViewModel>(() => WorldMapViewModel(
        contentRepository: locator(),
        progressRepository: locator(),
      ));
  locator.registerFactory<LessonController>(() => LessonController(
        questionEngine: locator(),
        masteryEngine: locator(),
        rewardEngine: locator(),
        progressRepository: locator(),
        audioService: locator(),
        analyticsService: locator(),
      ));
}
