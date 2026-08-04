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
import '../../../../core/utils/app_validation.dart';

class ForgetPasswordScreen extends StatelessWidget {
  ForgetPasswordScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppTexts.forgotPasswordTitle.tr())),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordEmailSent) {
            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                 duration: const Duration(seconds: 3),
              ),
            );
            context.push(AppRoutes.otp, extra: state.email);
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
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppSizes.h24),
                  Text(
                    AppTexts.forgotPasswordBody.tr(),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  SizedBox(height: AppSizes.h24),
                  CustomTextformfeild(
                    keyboardType: TextInputType.emailAddress,
                    hintText: AppTexts.emailLabel.tr(),
                    controller: _emailController,
                    validator: AppValidators.email,
                    formFieldKey: const Key("forgot_email"),
                    labelText: AppTexts.emailLabel.tr(),
                    labelcolor: AppColors.secondBlack,
                    borderRadius: AppSizes.r10,
                  ),
                  SizedBox(height: AppSizes.h24),
                  ElevatedButton(
                    onPressed: state is AuthLoading
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        context.read<AuthBloc>().add(
                          ForgotPasswordEvent(
                            email: _emailController.text.trim(),
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
                      AppTexts.sendOtp.tr(),
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