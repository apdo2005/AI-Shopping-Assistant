import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ai_shopping_assistant/features/profile/domain/entities/profile_entity.dart';
import 'package:ai_shopping_assistant/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:ai_shopping_assistant/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:ai_shopping_assistant/shared/snakbar.dart';
import '../widgets/profile_ui.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileEntity profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _countryCode;

  // Gender and birthday are shown for context but are NOT part of the
  // confirmed PUT /profile/info contract, so they stay read-only and are
  // never sent in the update request — unchanged from before this pass.
  String? _gender;
  String? _birthday;
  String? _language;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = widget.profile.user;
    _firstName = TextEditingController(text: user.firstName ?? '');
    _lastName = TextEditingController(text: user.lastName ?? '');
    _username = TextEditingController(text: user.username);
    _email = TextEditingController(text: user.email);
    _phone = TextEditingController(text: user.phone ?? '');
    _countryCode = TextEditingController(text: user.countryCode ?? '');
    _gender = user.gender;
    _birthday = user.birthday;
    _language = user.preferredLanguages.isEmpty ? null : user.preferredLanguages.first;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _countryCode.dispose();
    super.dispose();
  }

  // Same request shape as before: username, firstname, lastname, email,
  // phone, country_code, preferred_languages[0] via PUT /profile/info.
  // Guarded against double submission and only pops on a confirmed success.
  Future<void> _save() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final params = UpdateProfileParams(
      username: _username.text.trim(),
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      countryCode: _countryCode.text.trim(),
      preferredLanguage: _language,
    );

    final result = await context.read<ProfileCubit>().updateProfile(params);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.fold(
      (message) => CustomSnackBar().errorBar(context, message),
      (_) {
        CustomSnackBar().successBar(context, 'Profile updated successfully');
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials('${_firstName.text} ${_lastName.text}'.trim().isEmpty
        ? widget.profile.user.displayName
        : '${_firstName.text} ${_lastName.text}');

    return ProfilePageScaffold(
      title: 'Edit Profile',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
        children: [
          Center(
            child: Container(
              width: 78,
              height: 78,
              decoration: const BoxDecoration(color: ProfileTheme.iconBackground, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(initials, style: ProfileTheme.font(size: 26, weight: FontWeight.w700, color: ProfileTheme.primary)),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Change your photo from the Profile screen',
              style: ProfileTheme.font(size: 11.5, color: ProfileTheme.textMuted),
            ),
          ),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                const ProfileSectionLabel('CONTACT'),
                ProfileCard(
                  child: Column(
                    children: [
                      _field(_email, 'Email', email: true, requiredValue: true),
                      const SizedBox(height: 12),
                      _field(_phone, 'Phone'),
                      const SizedBox(height: 12),
                      _field(_countryCode, 'Country code'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const ProfileSectionLabel('ACCOUNT'),
                ProfileCard(
                  child: Column(
                    children: [
                      _field(_firstName, 'First name'),
                      const SizedBox(height: 12),
                      _field(_lastName, 'Last name'),
                      const SizedBox(height: 12),
                      _field(_username, 'Username', requiredValue: true),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: (_gender == 'male' || _gender == 'female') ? _gender : null,
                        decoration: ProfileTheme.inputDecoration(
                          label: 'Gender',
                          hint: (_gender != null && _gender != 'male' && _gender != 'female') ? _gender : null,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'male', child: Text('Male')),
                          DropdownMenuItem(value: 'female', child: Text('Female')),
                        ],
                        onChanged: null,
                      ),
                      const SizedBox(height: 12),
                      Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: ProfileTheme.cardBorder),
                          ),
                          tileColor: Colors.white,
                          title: Text('Birthday', style: ProfileTheme.font(size: 13, color: ProfileTheme.textSecondary)),
                          subtitle: Text(_birthday ?? 'Not set', style: ProfileTheme.font(size: 13.5, weight: FontWeight.w600)),
                          trailing: const Icon(Icons.calendar_today_outlined, color: ProfileTheme.textMuted, size: 18),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gender and birthday are not part of the confirmed update contract yet, so they are read-only here.',
                        style: ProfileTheme.font(size: 11, color: ProfileTheme.textMuted, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const ProfileSectionLabel('PREFERENCES'),
                ProfileCard(
                  child: DropdownButtonFormField<String>(
                    value: (_language == 'ar' || _language == 'en') ? _language : null,
                    decoration: ProfileTheme.inputDecoration(
                      label: 'Preferred language',
                      hint: (_language != null && _language != 'ar' && _language != 'en') ? _language : null,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'ar', child: Text('العربية')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: _isSubmitting ? null : (value) => setState(() => _language = value),
                  ),
                ),
                const SizedBox(height: 26),
                ProfilePrimaryButton(
                  label: 'Save changes',
                  isLoading: _isSubmitting,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {bool requiredValue = false, bool email = false}) {
    return TextFormField(
      controller: controller,
      enabled: !_isSubmitting,
      keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
      style: ProfileTheme.font(size: 13.5, weight: FontWeight.w500),
      decoration: ProfileTheme.inputDecoration(label: label),
      validator: (value) {
        if (requiredValue && (value == null || value.trim().isEmpty)) return '$label is required';
        if (email && value != null && value.isNotEmpty && !value.contains('@')) return 'Enter a valid email';
        return null;
      },
    );
  }
}

String _initials(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
  final initials = words.take(2).map((word) => word[0]).join();
  return initials.isEmpty ? '?' : initials.toUpperCase();
}
