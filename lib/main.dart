import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:alphabet_adventure/app.dart';
import 'package:alphabet_adventure/core/di/locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fredoka is bundled in assets/fonts/ and declared in pubspec.yaml, so the app
  // never requests it over the network. This keeps the app genuinely
  // offline-only, which the store listing claims and the Play Data safety
  // declaration depends on.
  // LicenseRegistry.addLicense(() async* {
  //   final license = await rootBundle.loadString('assets/fonts/OFL.txt');
  //   yield LicenseEntryWithLineBreaks(const ['Fredoka'], license);
  // });

  // The 3D objects in the letter example overlay are third-party models
  // (CC0 / CC BY 4.0 / SCEA); surface their credits on the licence page. The
  // file is only read when that page is opened.
  // LicenseRegistry.addLicense(() async* {
  //   final credits = await rootBundle.loadString('assets/models/LICENSES.txt');
  //   yield LicenseEntryWithLineBreaks(const ['3D models'], credits);
  // });

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

  // Initialize service locator
  await setupLocator();

  runApp(const AlphabetAdventureApp());
}
