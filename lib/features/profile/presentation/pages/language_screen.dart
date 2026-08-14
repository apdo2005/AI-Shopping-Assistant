import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ai_shopping_assistant/features/profile/domain/entities/profile_entity.dart';
import 'package:ai_shopping_assistant/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:ai_shopping_assistant/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ai_shopping_assistant/shared/snakbar.dart';
import '../widgets/profile_ui.dart';

/// Language changes now actually save.
///
/// Bug fix: this screen previously always showed a disabled Save button
/// with the message "Language changes cannot be saved until the profile
/// update API contract is provided." That contract already exists —
/// `preferred_languages[0]` is part of the same confirmed `PUT
/// /profile/info` request EditProfileScreen already sends successfully.
/// This screen now calls that same ProfileCubit.updateProfile with every
/// other field preserved and only the language changed. No new endpoint,
/// no new request field.
class LanguageScreen extends StatefulWidget {
  final ProfileEntity profile;

  const LanguageScreen({super.key, required this.profile});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selected;
  bool _isSubmitting = false;

  static const _languages = [
    (code: 'ar', label: 'العربية', native: 'Arabic'),
    (code: 'en', label: 'English', native: 'English'),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.profile.user.preferredLanguages.contains('ar') ? 'ar' : 'en';
  }

  Future<void> _save() async {
    if (_isSubmitting) return;

    final current = widget.profile.user.preferredLanguages.isEmpty
        ? null
        : widget.profile.user.preferredLanguages.first;
    if (current == _selected) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSubmitting = true);

    final user = widget.profile.user;
    final params = UpdateProfileParams(
      username: user.username,
      firstName: user.firstName ?? '',
      lastName: user.lastName ?? '',
      email: user.email,
      phone: user.phone ?? '',
      countryCode: user.countryCode ?? '',
      preferredLanguage: _selected,
    );

    final result = await context.read<ProfileCubit>().updateProfile(params);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (message) => CustomSnackBar().errorBar(context, message),
      (_) {
        CustomSnackBar().successBar(context, 'Language updated successfully');
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePageScaffold(
      title: 'Language',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
        children: [
          const ProfileSectionLabel('SELECT A LANGUAGE'),
          ProfileCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < _languages.length; i++) ...[
                  _LanguageOption(
                    label: _languages[i].label,
                    subtitle: _languages[i].native,
                    selected: _selected == _languages[i].code,
                    enabled: !_isSubmitting,
                    onTap: () => setState(() => _selected = _languages[i].code),
                  ),
                  if (i != _languages.length - 1) const Divider(height: 1, color: ProfileTheme.divider),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          ProfilePrimaryButton(
            label: 'Save language',
            isLoading: _isSubmitting,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                color: selected ? ProfileTheme.primary : ProfileTheme.textMuted,
                size: 21,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: ProfileTheme.font(size: 14, weight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: ProfileTheme.font(size: 11.5, color: ProfileTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
