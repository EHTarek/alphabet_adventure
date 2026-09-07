import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:alphabet_adventure/data/models/child_profile.dart';
import 'package:alphabet_adventure/data/repositories/progress_repository.dart';

/// Available avatar choices for child profiles.
class AvatarPreset {
  final String id;
  final String label;
  final String assetPath;
  final int colorHex;

  const AvatarPreset({
    required this.id,
    required this.label,
    required this.assetPath,
    required this.colorHex,
  });
}

/// View model managing child profile creation, selection, and multi-profile switching (PRS Section 14).
class ProfileViewModel extends ChangeNotifier {
  final ProgressRepository _progressRepository;
  static const _uuid = Uuid();

  ProfileViewModel({
    required this._progressRepository,
  });

  List<ChildProfile> get profiles => _progressRepository.profiles;
  ChildProfile? get activeProfile => _progressRepository.activeProfile;

  static const List<AvatarPreset> avatarPresets = [
    AvatarPreset(
      id: 'avatar_parrot',
      label: 'Pip Parrot',
      assetPath: 'assets/images/avatars/avatar_parrot.png',
      colorHex: 0xFF4ECDC4,
    ),
    AvatarPreset(
      id: 'avatar_lion',
      label: 'Leo Lion',
      assetPath: 'assets/images/avatars/avatar_lion.png',
      colorHex: 0xFFFFD166,
    ),
    AvatarPreset(
      id: 'avatar_fox',
      label: 'Felix Fox',
      assetPath: 'assets/images/avatars/avatar_fox.png',
      colorHex: 0xFFFF8811,
    ),
    AvatarPreset(
      id: 'avatar_bear',
      label: 'Barnaby Bear',
      assetPath: 'assets/images/avatars/avatar_bear.png',
      colorHex: 0xFFFF6B6B,
    ),
    AvatarPreset(
      id: 'avatar_bunny',
      label: 'Bella Bunny',
      assetPath: 'assets/images/avatars/avatar_bunny.png',
      colorHex: 0xFFA56CF4,
    ),
    AvatarPreset(
      id: 'avatar_panda',
      label: 'Penny Panda',
      assetPath: 'assets/images/avatars/avatar_panda.png',
      colorHex: 0xFF06D6A0,
    ),
  ];

  /// Creates and activates a new child profile.
  Future<ChildProfile> createProfile({
    required String name,
    required String avatarId,
    int age = 5,
  }) async {
    final newProfile = ChildProfile(
      id: _uuid.v4(),
      name: name.trim().isEmpty ? 'Explorer' : name.trim(),
      avatarId: avatarId,
      age: age,
      createdAt: DateTime.now(),
      totalStars: 0,
      currentStreak: 0,
      lastPlayedDate: DateTime.now(),
      unlockedStickerIds: const [],
      unlockedWorldIds: const ['world_jungle', 'forest'],
    );

    await _progressRepository.saveProfile(newProfile);
    await _progressRepository.setActiveProfile(newProfile.id);
    notifyListeners();
    return newProfile;
  }

  /// Selects an existing profile as active.
  Future<void> selectProfile(String profileId) async {
    await _progressRepository.setActiveProfile(profileId);
    notifyListeners();
  }

  /// Deletes a profile and clears associated progress.
  Future<void> deleteProfile(String profileId) async {
    await _progressRepository.deleteProfile(profileId);
    notifyListeners();
  }
}
