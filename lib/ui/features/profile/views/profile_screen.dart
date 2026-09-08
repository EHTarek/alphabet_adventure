import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/models/child_profile.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/animations/bounce_animation.dart';
import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/features/profile/view_models/profile_view_model.dart';

/// Screen allowing children to select their explorer profile or create a new one.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final profiles = viewModel.profiles;

    return Scaffold(
      backgroundColor: AppColors.bgSky,
      appBar: AppBar(
        title: Text(
          'Who is Playing?',
          style: AppFonts.fredoka(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          // Parental Gate icon leading to Parents Dashboard
          IconButton(
            icon: const Icon(Icons.family_restroom_rounded, size: 32),
            tooltip: 'Parents Section',
            onPressed: () => context.push('/parent'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Text(
                'Choose your explorer profile to start your journey!',
                textAlign: TextAlign.center,
                style: AppFonts.fredoka(
                  fontSize: 18,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: profiles.length + 1, // +1 for "Create New" card
                  itemBuilder: (context, index) {
                    if (index < profiles.length) {
                      final profile = profiles[index];
                      return _buildProfileCard(context, profile, viewModel);
                    } else {
                      return _buildAddProfileCard(context, viewModel);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    ChildProfile profile,
    ProfileViewModel viewModel,
  ) {
    final avatar = ProfileViewModel.avatarPresets.firstWhere(
      (a) => a.id == profile.avatarId,
      orElse: () => ProfileViewModel.avatarPresets.first,
    );

    return BounceAnimation(
      onTap: () async {
        final audio = context.read<AudioService>();
        audio.playSuccessSound();
        await viewModel.selectProfile(profile.id);
        if (context.mounted) {
          context.go('/world_map');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Color(avatar.colorHex),
            width: 3.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(avatar.colorHex).withValues(alpha: 0.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Color(avatar.colorHex).withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: Center(
                child: Icon(
                  Icons.face_rounded,
                  size: 48,
                  color: Color(avatar.colorHex),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              profile.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.fredoka(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: AppColors.accentYellowDark,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${profile.totalStars} stars',
                  style: AppFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProfileCard(
    BuildContext context,
    ProfileViewModel viewModel,
  ) {
    return BounceAnimation(
      onTap: () => _showCreateProfileDialog(context, viewModel),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.secondaryDark.withValues(alpha: 0.5),
            width: 3,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 44,
                color: AppColors.secondaryDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'New Explorer',
              style: AppFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateProfileDialog(BuildContext context, ProfileViewModel viewModel) {
    String name = '';
    String selectedAvatarId = ProfileViewModel.avatarPresets.first.id;
    int age = 5;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              title: Text(
                'Create Your Explorer',
                textAlign: TextAlign.center,
                style: AppFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Explorer Name',
                        hintText: 'e.g. Leo, Mia, Sam',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: AppColors.bgSky,
                      ),
                      style: AppFonts.fredoka(fontSize: 18),
                      onChanged: (val) => name = val,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Choose Avatar',
                      style: AppFonts.fredoka(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: ProfileViewModel.avatarPresets.map((avatar) {
                        final isSelected = avatar.id == selectedAvatarId;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedAvatarId = avatar.id;
                            });
                          },
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Color(avatar.colorHex).withValues(alpha: 0.25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Color(avatar.colorHex)
                                    : Colors.transparent,
                                width: 3.5,
                              ),
                            ),
                            child: Icon(
                              Icons.face_rounded,
                              color: Color(avatar.colorHex),
                              size: 32,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    'Cancel',
                    style: AppFonts.fredoka(
                      fontSize: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (name.trim().isEmpty) {
                      name = 'Explorer';
                    }
                    Navigator.pop(dialogContext);
                    await viewModel.createProfile(
                      name: name,
                      avatarId: selectedAvatarId,
                      age: age,
                    );
                    if (context.mounted) {
                      context.go('/world_map');
                    }
                  },
                  child: Text(
                    'Let’s Go!',
                    style: AppFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
