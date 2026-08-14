import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ai_shopping_assistant/features/profile/domain/entities/profile_entity.dart';
import 'package:ai_shopping_assistant/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:ai_shopping_assistant/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ai_shopping_assistant/shared/snakbar.dart';
import '../widgets/profile_ui.dart';

/// Change Username now actually saves.
///
/// Bug fix: this screen previously took just a `username` string and its
/// Save button was permanently disabled with a "not connected yet" note.
/// But `username` IS part of the confirmed `PUT /profile/info` contract —
/// EditProfileScreen already sends it successfully via the same
/// ProfileCubit.updateProfile call. This screen now takes the full
/// [ProfileEntity] (like EditProfileScreen does) so it can send that same
/// request with every other field preserved and only the username changed.
/// No new endpoint, no new request field — just wiring this screen to the
/// update call that already exists and already works.
class ChangeUsernameScreen extends StatefulWidget {
  final ProfileEntity profile;

  const ChangeUsernameScreen({super.key, required this.profile});

  @override
  State<ChangeUsernameScreen> createState() => _ChangeUsernameScreenState();
}

class _ChangeUsernameScreenState extends State<ChangeUsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.user.username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final newUsername = _usernameController.text.trim();
    if (newUsername == widget.profile.user.username) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSubmitting = true);

    final user = widget.profile.user;
    final params = UpdateProfileParams(
      username: newUsername,
      firstName: user.firstName ?? '',
      lastName: user.lastName ?? '',
      email: user.email,
      phone: user.phone ?? '',
      countryCode: user.countryCode ?? '',
      preferredLanguage: user.preferredLanguages.isEmpty ? null : user.preferredLanguages.first,
    );

    final result = await context.read<ProfileCubit>().updateProfile(params);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (message) => CustomSnackBar().errorBar(context, message),
      (_) {
        CustomSnackBar().successBar(context, 'Username updated successfully');
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePageScaffold(
      title: 'Change Username',
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
        child: ProfileCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Change your username', style: ProfileTheme.font(size: 18, weight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(
                  'Your username is used to identify your account.',
                  style: ProfileTheme.font(size: 12.5, color: ProfileTheme.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _usernameController,
                  enabled: !_isSubmitting,
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  style: ProfileTheme.font(size: 13.5, weight: FontWeight.w500),
                  decoration: ProfileTheme.inputDecoration(
                    label: 'Username',
                    hint: 'Enter username',
                    prefixIcon: const Icon(Icons.alternate_email_rounded, size: 19),
                  ),
                  validator: (value) {
                    final username = value?.trim() ?? '';
                    if (username.isEmpty) return 'Enter a username';
                    if (username.length < 3) return 'Use at least 3 characters';
                    if (username.length > 30) return 'Username cannot exceed 30 characters';
                    if (!RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(username)) {
                      return 'Use only letters, numbers, underscores or dots';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ProfilePrimaryButton(
                  label: 'Save changes',
                  isLoading: _isSubmitting,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
