import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habispace/features/auth/presentation/logic/auth_bloc.dart';

import 'package:habispace/features/auth/presentation/logic/auth_state.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/shared/custom_textformfield.dart';
import '../../../../core/utils/app_color.dart';
import '../../../../core/utils/app_sizes.dart';
import '../../../../core/utils/app_texts.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String otp;
  final String email;

  ResetPasswordScreen({
    super.key,
    required this.otp,
    required this.email,
  });

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTexts.resetPasswordAppBar.tr())),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is PasswordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppTexts.passwordResetSuccess.tr()),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go(AppRoutes.login);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppSizes.h24),
                  Text(
                    '${AppTexts.createNewPasswordFor.tr()}\n$email',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  SizedBox(height: AppSizes.h24),

                  CustomTextformfeild(
                    keyboardType: TextInputType.visiblePassword,
                    hintText: AppTexts.newPasswordLabel.tr(),
                    controller: _passwordController,
                    isPassword: true,
                    formFieldKey: const Key("new_password"),
                    labelText: AppTexts.newPasswordLabel.tr(),
                    labelcolor: AppColors.secondBlack,
                    borderRadius: AppSizes.r10,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppTexts.pleaseEnterAPassword.tr();
                      }
                      if (value.length < 8) {
                        return AppTexts.passwordMinEightChars.tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppSizes.h16),
                  CustomTextformfeild(
                    keyboardType: TextInputType.visiblePassword,
                    hintText: AppTexts.confirmPasswordLabel.tr(),
                    controller: _confirmController,
                    isPassword: true,
                    formFieldKey: const Key("confirm_password"),
                    labelText: AppTexts.confirmPasswordLabel.tr(),
                    labelcolor: AppColors.secondBlack,
                    borderRadius: AppSizes.r10,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return AppTexts.passwordsDoNotMatch.tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: AppSizes.h24),
                  ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                          ResetPasswordEvent(
                            email: email,
                            otp: otp,
                            password: _passwordController.text,
                            passwordConfirmation: _confirmController.text,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, AppSizes.h50),
                      backgroundColor: AppColors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.r8),
                      ),
                    ),
                    child: state is AuthLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      AppTexts.resetPasswordButton.tr(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}