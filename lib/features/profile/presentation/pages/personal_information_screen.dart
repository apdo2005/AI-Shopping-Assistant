import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ai_shopping_assistant/features/profile/domain/entities/profile_entity.dart';
import 'package:ai_shopping_assistant/features/profile/presentation/bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_ui.dart';
import 'edit_profile_screen.dart';

class PersonalInformationScreen extends StatelessWidget {
  final ProfileEntity profile;

  const PersonalInformationScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    // Reads the live cubit state (not just the snapshot passed in) so that
    // saving from Edit Profile is reflected here the moment the user pops
    // back — this screen never shows stale data after an update.
    final cubitState = context.watch<ProfileCubit>().state;
    final profile = cubitState is ProfileLoaded ? cubitState.profile : this.profile;
    final user = profile.user;

    return ProfilePageScaffold(
      title: 'Personal Information',
      actions: [
        IconButton(
          tooltip: 'Edit profile',
          icon: const Icon(Icons.edit_outlined),
          onPressed: () => _openEditProfile(context, profile),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
        children: [
          Center(
            child: _AvatarPreview(imageUrl: user.profileImageUrl, initials: _initials(user.displayName)),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              user.displayName,
              style: ProfileTheme.font(size: 17, weight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 26),
          const ProfileSectionLabel('CONTACT'),
          ProfileCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _InfoRow(label: 'Email', value: user.email, verified: user.emailVerified),
                const Divider(height: 1, color: ProfileTheme.divider),
                _InfoRow(
                  label: 'Phone',
                  value: _phone(user.countryCode, user.phone),
                  verified: user.phoneVerified,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const ProfileSectionLabel('ACCOUNT'),
          ProfileCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _InfoRow(label: 'First name', value: user.firstName),
                const Divider(height: 1, color: ProfileTheme.divider),
                _InfoRow(label: 'Last name', value: user.lastName),
                const Divider(height: 1, color: ProfileTheme.divider),
                _InfoRow(label: 'Username', value: user.username),
                const Divider(height: 1, color: ProfileTheme.divider),
                _InfoRow(label: 'Gender', value: user.gender),
                const Divider(height: 1, color: ProfileTheme.divider),
                _InfoRow(label: 'Birthday', value: user.birthday),
                const Divider(height: 1, color: ProfileTheme.divider),
                _InfoRow(
                  label: 'Preferred languages',
                  value: user.preferredLanguages.isEmpty ? null : user.preferredLanguages.join(', '),
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _openEditProfile(context, profile),
              icon: const Icon(Icons.edit_outlined, size: 17, color: ProfileTheme.primary),
              label: Text(
                'Edit Profile',
                style: ProfileTheme.font(size: 13.5, weight: FontWeight.w600, color: ProfileTheme.primary),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: ProfileTheme.cardBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openEditProfile(BuildContext context, ProfileEntity profile) {
    final profileCubit = context.read<ProfileCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: profileCubit,
          child: EditProfileScreen(profile: profile),
        ),
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  final String? imageUrl;
  final String initials;

  const _AvatarPreview({required this.imageUrl, required this.initials});

  @override
  Widget build(BuildContext context) {
    final hasUrl = imageUrl != null && imageUrl!.trim().isNotEmpty;
    const size = 84.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: ProfileTheme.primary.withValues(alpha: 0.18), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: ProfileTheme.iconBackground,
              alignment: Alignment.center,
              child: Text(
                initials,
                style: ProfileTheme.font(size: size * 0.32, weight: FontWeight.w700, color: ProfileTheme.primary),
              ),
            ),
            if (hasUrl)
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const ProfileShimmerBox(width: double.infinity, height: double.infinity, radius: 0),
                errorBuilder: (context, error, stack) => const SizedBox.shrink(),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool? verified;
  final bool isLast;

  const _InfoRow({required this.label, required this.value, this.verified, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final hasValue = value?.trim().isNotEmpty == true;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(label, style: ProfileTheme.font(size: 13.5, color: ProfileTheme.textSecondary)),
                if (verified != null) ...[
                  const SizedBox(width: 8),
                  _VerifiedBadge(verified: verified!),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              hasValue ? value! : 'Not set',
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: ProfileTheme.font(
                size: 13.5,
                weight: FontWeight.w600,
                color: hasValue ? ProfileTheme.text : ProfileTheme.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  final bool verified;

  const _VerifiedBadge({required this.verified});

  @override
  Widget build(BuildContext context) {
    final color = verified ? ProfileTheme.success : ProfileTheme.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(
        verified ? 'Verified' : 'Unverified',
        style: ProfileTheme.font(size: 9.5, weight: FontWeight.w700, color: color),
      ),
    );
  }
}

String _phone(String? code, String? phone) =>
    phone?.trim().isNotEmpty == true ? '${code ?? ''}$phone' : '';

String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
  return words.take(2).map((word) => word[0]).join().toUpperCase();
}
