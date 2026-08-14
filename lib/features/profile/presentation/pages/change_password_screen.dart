import 'package:flutter/material.dart';

import '../widgets/profile_ui.dart';

/// UI-only pass. Unlike Change Username / Language, there is genuinely no
/// authenticated "change password" endpoint in this project's API
/// constants — only the separate forgot-password/OTP/reset-password flow,
/// which is a different feature. So the Save button stays intentionally
/// disabled here rather than guessing at a request shape; see the final
/// report for details.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _currentHidden = true;
  bool _newPasswordHidden = true;
  bool _confirmHidden = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePageScaffold(
      title: 'Change Password',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
        children: [
          ProfileCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Change your password', style: ProfileTheme.font(size: 18, weight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a strong password that you do not use elsewhere.',
                    style: ProfileTheme.font(size: 12.5, color: ProfileTheme.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 22),
                  _PasswordField(
                    controller: _currentPasswordController,
                    label: 'Current password',
                    obscureText: _currentHidden,
                    onToggle: () => setState(() => _currentHidden = !_currentHidden),
                  ),
                  const SizedBox(height: 14),
                  _PasswordField(
                    controller: _newPasswordController,
                    label: 'New password',
                    obscureText: _newPasswordHidden,
                    onToggle: () => setState(() => _newPasswordHidden = !_newPasswordHidden),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Required';
                      if (value.length < 8) return 'Use at least 8 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  _PasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm new password',
                    obscureText: _confirmHidden,
                    onToggle: () => setState(() => _confirmHidden = !_confirmHidden),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Required';
                      if (value != _newPasswordController.text) return 'Passwords do not match';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ProfileTheme.iconBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 18, color: ProfileTheme.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Password updates will be connected once a change-password API request is available.',
                            style: ProfileTheme.font(size: 11.5, color: ProfileTheme.textSecondary, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const ProfilePrimaryButton(label: 'Save changes', onPressed: null),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.onToggle,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: ProfileTheme.font(size: 13.5, weight: FontWeight.w500),
      validator: validator ??
          (value) {
            if (value == null || value.trim().isEmpty) return 'Required';
            return null;
          },
      decoration: ProfileTheme.inputDecoration(
        label: label,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: ProfileTheme.textMuted,
            size: 20,
          ),
        ),
      ),
    );
  }
}
