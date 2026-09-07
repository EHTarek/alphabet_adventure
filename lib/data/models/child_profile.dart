/// A child's profile for saving progress independently (PRS Section 14).
class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.name,
    this.avatarId = 'avatar_parrot',
    this.avatarIndex = 0,
    this.age = 5,
    this.createdAt,
    this.totalStars = 0,
    this.currentStreak = 0,
    this.lastPlayedDate,
    this.unlockedStickerIds = const [],
    this.unlockedWorldIds = const ['world_jungle', 'forest'],
  });

  /// Unique profile ID.
  final String id;

  /// Child's display name or nickname.
  final String name;

  /// Selected avatar ID.
  final String avatarId;

  /// Selected avatar index.
  final int avatarIndex;

  /// Child's age.
  final int age;

  /// When the profile was created.
  final DateTime? createdAt;

  /// Total stars earned.
  final int totalStars;

  /// Current consecutive day streak.
  final int currentStreak;

  /// Last played timestamp.
  final DateTime? lastPlayedDate;

  /// Unlocked sticker & achievement IDs.
  final List<String> unlockedStickerIds;

  /// Unlocked world IDs.
  final List<String> unlockedWorldIds;

  /// Create from JSON map (for persistence).
  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    return ChildProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarId: json['avatarId'] as String? ?? 'avatar_parrot',
      avatarIndex: json['avatarIndex'] as int? ?? 0,
      age: json['age'] as int? ?? 5,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      totalStars: json['totalStars'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      lastPlayedDate: json['lastPlayedDate'] != null
          ? DateTime.parse(json['lastPlayedDate'] as String)
          : null,
      unlockedStickerIds: (json['unlockedStickerIds'] as List<dynamic>?)
              ?.cast<String>() ??
          const [],
      unlockedWorldIds: (json['unlockedWorldIds'] as List<dynamic>?)
              ?.cast<String>() ??
          const ['world_jungle', 'forest'],
    );
  }

  /// Convert to JSON map (for persistence).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarId': avatarId,
      'avatarIndex': avatarIndex,
      'age': age,
      'createdAt': createdAt?.toIso8601String(),
      'totalStars': totalStars,
      'currentStreak': currentStreak,
      'lastPlayedDate': lastPlayedDate?.toIso8601String(),
      'unlockedStickerIds': unlockedStickerIds,
      'unlockedWorldIds': unlockedWorldIds,
    };
  }

  /// Create a copy with optional overrides.
  ChildProfile copyWith({
    String? id,
    String? name,
    String? avatarId,
    int? avatarIndex,
    int? age,
    DateTime? createdAt,
    int? totalStars,
    int? currentStreak,
    DateTime? lastPlayedDate,
    List<String>? unlockedStickerIds,
    List<String>? unlockedWorldIds,
  }) {
    return ChildProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarId: avatarId ?? this.avatarId,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      age: age ?? this.age,
      createdAt: createdAt ?? this.createdAt,
      totalStars: totalStars ?? this.totalStars,
      currentStreak: currentStreak ?? this.currentStreak,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      unlockedStickerIds: unlockedStickerIds ?? this.unlockedStickerIds,
      unlockedWorldIds: unlockedWorldIds ?? this.unlockedWorldIds,
    );
  }
}
