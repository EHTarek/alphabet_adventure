import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:alphabet_adventure/data/models/child_profile.dart';
import 'package:alphabet_adventure/data/services/audio_service.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';
import 'package:alphabet_adventure/ui/core/wood/wood.dart';
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
    final navigator = Navigator.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            WoodHeader(
              title: 'Who is Playing?',
              onBack: navigator.canPop() ? () => navigator.maybePop() : null,
              trailing: [
                // Parental Gate icon leading to Parents Dashboard
                WoodIconButton(
                  icon: Icons.family_restroom_rounded,
                  tooltip: 'Parents Section',
                  size: 48,
                  onPressed: () => context.push('/parent'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
              child: WoodPanel(
                colors: _calloutColors,
                radius: 22,
                depth: 4,
                rimWidth: 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                child: Text(
                  'Choose your explorer profile to start your journey!',
                  textAlign: TextAlign.center,
                  style: WoodText.heading(fontSize: 17, color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 24),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.82,
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
              ),
            ),
          ],
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
    final isActive = viewModel.activeProfile?.id == profile.id;

    return WoodButton(
      onPressed: () async {
        final audio = context.read<AudioService>();
        audio.playSuccessSound();
        await viewModel.selectProfile(profile.id);
        if (context.mounted) {
          context.go('/world_map');
        }
      },
      radius: 26,
      depth: 8,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      semanticLabel: profile.name,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: FittedBox(
                    child: _AvatarBlock(avatar: avatar, size: 78),
                  ),
                ),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: WoodText.button(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _StarsBadge(stars: profile.totalStars),
              ],
            ),
          ),
          if (isActive)
            const Positioned(
              top: -4,
              right: -2,
              child: CandyBlock(
                size: 28,
                colors: WoodColors.candyGreen,
                child: Icon(Icons.check_rounded, size: 20, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddProfileCard(
    BuildContext context,
    ProfileViewModel viewModel,
  ) {
    return WoodButton(
      onPressed: () => _showCreateProfileDialog(context, viewModel),
      tone: WoodTone.dark,
      radius: 26,
      depth: 8,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      semanticLabel: 'New Explorer',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Flexible(
            child: FittedBox(
              child: CandyBlock(
                size: 72,
                colors: WoodColors.candyGreen,
                child: Icon(Icons.add_rounded, size: 52, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: WoodTitle('New Explorer', fontSize: 22, maxLines: 1),
          ),
        ],
      ),
    );
  }

  void _showCreateProfileDialog(
    BuildContext context,
    ProfileViewModel viewModel,
  ) {
    String name = '';
    String selectedAvatarId = ProfileViewModel.avatarPresets.first.id;
    int age = 5;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return WoodDialog(
              title: 'Create Your Explorer',
              onClose: () => Navigator.pop(dialogContext),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ParchmentTextField(onChanged: (val) => name = val),
                  const SizedBox(height: 18),
                  Text(
                    'Choose Avatar',
                    textAlign: TextAlign.center,
                    style: WoodText.heading(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: ProfileViewModel.avatarPresets.map((avatar) {
                      final isSelected = avatar.id == selectedAvatarId;
                      return _AvatarChoice(
                        avatar: avatar,
                        selected: isSelected,
                        onTap: () {
                          setDialogState(() {
                            selectedAvatarId = avatar.id;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                WoodButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Cancel', style: WoodText.button(fontSize: 20)),
                ),
                WoodButton(
                  tone: WoodTone.green,
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
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
                    style: WoodText.button(fontSize: 20, color: Colors.white),
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

/// The glossy green of [WoodPill], for a callout that needs two lines.
const WoodToneColors _calloutColors = WoodToneColors(
  top: Color(0xFF4CC792),
  bottom: WoodColors.pill,
  rim: WoodColors.pillShade,
  bevel: Color(0xFF166843),
  highlight: Color(0xFFBDF2D8),
  ink: Color(0xFFFFFFFF),
);

/// Candy colours for an avatar preset.
WoodToneColors _avatarColors(AvatarPreset avatar) {
  final base = Color(avatar.colorHex);
  return WoodToneColors.fromColor(base, Color.lerp(base, Colors.black, 0.35)!);
}

/// A candy block in the avatar's colour with a friendly face.
class _AvatarBlock extends StatelessWidget {
  const _AvatarBlock({required this.avatar, required this.size});

  final AvatarPreset avatar;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CandyBlock(
      size: size,
      colors: _avatarColors(avatar),
      child: Icon(Icons.face_rounded, size: size * 0.66, color: Colors.white),
    );
  }
}

/// Star total on a small recessed parchment strip.
class _StarsBadge extends StatelessWidget {
  const _StarsBadge({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: WoodColors.parchment.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WoodColors.parchmentEdge, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            color: WoodColors.goldBottom,
            size: 20,
            shadows: [Shadow(color: WoodColors.goldOutline, blurRadius: 1)],
          ),
          const SizedBox(width: 4),
          Text(
            '$stars stars',
            style: WoodText.body(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// An avatar option in the create dialog: a wooden tile holding the avatar's
/// candy block, glowing gold when selected.
class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.avatar,
    required this.selected,
    required this.onTap,
  });

  final AvatarPreset avatar;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      scale: selected ? 1.08 : 1,
      child: WoodButton(
        onPressed: onTap,
        tone: selected ? WoodTone.gold : WoodTone.dark,
        width: 64,
        height: 68,
        radius: 16,
        depth: 5,
        padding: EdgeInsets.zero,
        semanticLabel: avatar.label,
        child: _AvatarBlock(avatar: avatar, size: 40),
      ),
    );
  }
}

/// A name field inset into the dialog like a parchment label.
class _ParchmentTextField extends StatelessWidget {
  const _ParchmentTextField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
    return TextField(
      autofocus: true,
      textCapitalization: TextCapitalization.words,
      cursorColor: WoodColors.ink,
      decoration: InputDecoration(
        labelText: 'Explorer Name',
        hintText: 'e.g. Leo, Mia, Sam',
        labelStyle: WoodText.body(color: WoodColors.inkSoft),
        floatingLabelStyle: WoodText.heading(fontSize: 16),
        hintStyle: WoodText.body(
          color: WoodColors.inkSoft.withValues(alpha: 0.7),
        ),
        prefixIcon: const Icon(Icons.edit_rounded, color: WoodColors.inkSoft),
        filled: true,
        fillColor: WoodColors.parchment,
        border: border(WoodColors.parchmentEdge, 2),
        enabledBorder: border(WoodColors.parchmentEdge, 2),
        focusedBorder: border(WoodColors.goldOutline, 2.5),
      ),
      style: AppFonts.fredoka(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: WoodColors.ink,
      ),
      onChanged: onChanged,
    );
  }
}
