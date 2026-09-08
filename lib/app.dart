import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/repositories/content_repository.dart';
import 'package:alphabet_adventure/data/repositories/progress_repository.dart';
import 'package:alphabet_adventure/data/repositories/settings_repository.dart';
import 'package:alphabet_adventure/data/services/analytics_service.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/domain/engines/lesson_controller.dart';
import 'package:alphabet_adventure/domain/engines/mastery_engine.dart';
import 'package:alphabet_adventure/domain/engines/question_engine.dart';
import 'package:alphabet_adventure/domain/engines/reward_engine.dart';
import 'package:alphabet_adventure/ui/core/app_theme.dart';
import 'package:alphabet_adventure/ui/features/game/views/game_screen.dart';
import 'package:alphabet_adventure/ui/features/lesson_complete/views/lesson_complete_screen.dart';
import 'package:alphabet_adventure/ui/features/parent/views/parent_dashboard_screen.dart';
import 'package:alphabet_adventure/ui/features/profile/view_models/profile_view_model.dart';
import 'package:alphabet_adventure/ui/features/profile/views/profile_screen.dart';
import 'package:alphabet_adventure/ui/features/settings/views/settings_screen.dart';
import 'package:alphabet_adventure/ui/features/splash/views/splash_screen.dart';
import 'package:alphabet_adventure/ui/features/world_map/view_models/world_map_view_model.dart';
import 'package:alphabet_adventure/ui/features/world_map/views/world_map_screen.dart';

/// Top-level application widget configuring providers, declarative routing, and themes.
class AlphabetAdventureApp extends StatefulWidget {
  final AudioService audioService;
  final AnalyticsService analyticsService;
  final ContentRepository contentRepository;
  final ProgressRepository progressRepository;
  final SettingsRepository settingsRepository;

  const AlphabetAdventureApp({
    super.key,
    required this.audioService,
    required this.analyticsService,
    required this.contentRepository,
    required this.progressRepository,
    required this.settingsRepository,
  });

  @override
  State<AlphabetAdventureApp> createState() => _AlphabetAdventureAppState();
}

class _AlphabetAdventureAppState extends State<AlphabetAdventureApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/world_map',
          builder: (context, state) => const WorldMapScreen(),
        ),
        GoRoute(
          path: '/game',
          builder: (context, state) => const GameScreen(),
        ),
        GoRoute(
          path: '/lesson_complete',
          builder: (context, state) => const LessonCompleteScreen(),
        ),
        GoRoute(
          path: '/parent',
          builder: (context, state) => const ParentDashboardScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionEngine = QuestionEngine();
    const masteryEngine = MasteryEngine();
    const rewardEngine = RewardEngine();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.audioService),
        ChangeNotifierProvider.value(value: widget.progressRepository),
        ChangeNotifierProvider.value(value: widget.settingsRepository),
        Provider.value(value: widget.analyticsService),
        Provider.value(value: widget.contentRepository),
        Provider.value(value: questionEngine),
        Provider.value(value: masteryEngine),
        Provider.value(value: rewardEngine),
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(
            progressRepository: widget.progressRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WorldMapViewModel(
            contentRepository: widget.contentRepository,
            progressRepository: widget.progressRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LessonController(
            questionEngine: questionEngine,
            masteryEngine: masteryEngine,
            rewardEngine: rewardEngine,
            progressRepository: widget.progressRepository,
            audioService: widget.audioService,
            analyticsService: widget.analyticsService,
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Letterlands 3D',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
