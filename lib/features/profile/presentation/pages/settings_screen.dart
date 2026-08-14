import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ai_shopping_assistant/features/profile/domain/entities/profile_entity.dart';
import 'package:ai_shopping_assistant/features/profile/presentation/bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';

import '../widgets/profile_ui.dart';
import 'active_sessions_screen.dart';
import 'change_password_screen.dart';
import 'change_username_screen.dart';
import 'language_screen.dart';
import 'personal_information_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ProfileEntity profile;

  const SettingsScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    // Watches the live cubit state so returning here after changing the
    // language (or username) reflects the update immediately, instead of
    // showing the stale snapshot this screen was first pushed with.
    final cubitState = context.watch<ProfileCubit>().state;
    final profile = cubitState is ProfileLoaded ? cubitState.profile : this.profile;

    return ProfilePageScaffold(
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
        children: [
          const ProfileSectionLabel('ACCOUNT'),
          ProfileCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ProfileMenuTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Personal Information',
                  subtitle: 'Manage your personal details',
                  onTap: () => _pushWithProfileCubit(context, PersonalInformationScreen(profile: profile)),
                ),
                const Divider(height: 1, color: ProfileTheme.divider),
                ProfileMenuTile(
                  icon: Icons.alternate_email_rounded,
                  title: 'Change Username',
                  subtitle: profile.canChangeUsername ? 'Available' : 'Unavailable',
                  onTap: profile.canChangeUsername
                      ? () => _pushWithProfileCubit(context, ChangeUsernameScreen(profile: profile))
                      : null,
                ),
                const Divider(height: 1, color: ProfileTheme.divider),
                ProfileMenuTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  subtitle: profile.canChangePassword ? 'Available' : 'Unavailable',
                  onTap: profile.canChangePassword
                      ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()))
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const ProfileSectionLabel('PRIVACY & SECURITY'),
          ProfileCard(
            padding: EdgeInsets.zero,
            child: ProfileMenuTile(
              icon: Icons.devices_other_outlined,
              title: 'Active Sessions',
              subtitle: '${profile.activeSessions.length} session${profile.activeSessions.length == 1 ? '' : 's'}',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ActiveSessionsScreen(sessions: profile.activeSessions)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const ProfileSectionLabel('PREFERENCES'),
          ProfileCard(
            padding: EdgeInsets.zero,
            child: ProfileMenuTile(
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: profile.user.preferredLanguages.isEmpty
                  ? 'Not set'
                  : profile.user.preferredLanguages.map(_languageName).join(', '),
              onTap: () => _pushWithProfileCubit(context, LanguageScreen(profile: profile)),
            ),
          ),
          const SizedBox(height: 22),
          _SecurityInfoCard(
            canChangeUsername: profile.canChangeUsername,
            canChangePassword: profile.canChangePassword,
            activeSessions: profile.activeSessions.length,
          ),
        ],
      ),
    );
  }

  void _pushWithProfileCubit(BuildContext context, Widget page) {
    final profileCubit = context.read<ProfileCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => BlocProvider.value(value: profileCubit, child: page)),
    );
  }

  static String _languageName(String code) {
    switch (code.toLowerCase()) {
      case 'ar':
        return 'العربية';
      case 'en':
        return 'English';
      default:
        return code.toUpperCase();
    }
  }
}

class _SecurityInfoCard extends StatelessWidget {
  final bool canChangeUsername;
  final bool canChangePassword;
  final int activeSessions;

  const _SecurityInfoCard({
    required this.canChangeUsername,
    required this.canChangePassword,
    required this.activeSessions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProfileTheme.iconBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ProfileTheme.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: ProfileTheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account security', style: ProfileTheme.font(size: 14, weight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(
                  '$activeSessions active session${activeSessions == 1 ? '' : 's'}',
                  style: ProfileTheme.font(size: 12, color: ProfileTheme.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  canChangeUsername ? 'Username changes are available.' : 'Username changes are unavailable.',
                  style: ProfileTheme.font(size: 12, color: ProfileTheme.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  canChangePassword ? 'Password changes are available.' : 'Password changes are unavailable.',
                  style: ProfileTheme.font(size: 12, color: ProfileTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
