import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habispace/features/auth/presentation/logic/auth_bloc.dart';
import 'package:habispace/features/auth/presentation/logic/auth_state.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/shared/custom_svg.dart';
import '../../../../core/shared/custom_textformfield.dart';
import '../../../../core/shared/snakbar.dart';
import '../../../../core/utils/app_color.dart';
import '../../../../core/utils/app_sizes.dart';
import '../../../../core/utils/app_validation.dart';

class SignupScreen extends StatelessWidget {
  SignupScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: SingleChildScrollView(
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: AppSizes.h80),

                  CustomSvgImage(
                    path: "assets/images/logo2.svg",
                    height: AppSizes.h50,
                    width: AppSizes.w170,
                  ),
                  SizedBox(height: AppSizes.h24),
                  Text(
                    "Create Account",
                    style: GoogleFonts.poppins(
                      fontSize: AppSizes.h20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondBlack,
                    ),
                  ),
                  SizedBox(height: AppSizes.h24),

                  CustomTextformfeild(
                    keyboardType: TextInputType.name,
                    hintText: "Full Name",
                    controller: _nameController,
                    validator: AppValidators.name,
                    formFieldKey: const Key("name"),
                    labelText: "Full Name",
                    labelcolor: AppColors.secondBlack,
                    borderRadius: AppSizes.r10,
                  ),
                  SizedBox(height: AppSizes.h16),

                  CustomTextformfeild(
                    keyboardType: TextInputType.emailAddress,
                    hintText: "Email",
                    controller: _emailController,
                    validator: AppValidators.email,
                    formFieldKey: const Key("signup_email"),
                    labelText: "Email",
                    labelcolor: AppColors.secondBlack,
                    borderRadius: AppSizes.r10,
                  ),
                  SizedBox(height: AppSizes.h16),

                  CustomTextformfeild(
                    keyboardType: TextInputType.visiblePassword,
                    hintText: "Password",
                    controller: _passwordController,
                    validator: AppValidators.password,
                    formFieldKey: const Key("signup_password"),
                    labelText: "Password",
                    isPassword: true,
                    labelcolor: AppColors.secondBlack,
                    borderRadius: AppSizes.r10,
                  ),
                  SizedBox(height: AppSizes.h16),

                  CustomTextformfeild(
                    keyboardType: TextInputType.visiblePassword,
                    hintText: "Confirm Password",
                    controller: _confirmPasswordController,
                    validator: (value) =>
                        AppValidators.confirmPassword(value, _passwordController.text),
                    formFieldKey: const Key("confirm_password"),
                    labelText: "Confirm Password",
                    isPassword: true,
                    labelcolor: AppColors.secondBlack,
                    borderRadius: AppSizes.r10,
                  ),
                  SizedBox(height: AppSizes.h24),

                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is SignUpSuccess) {
                        CustomSnackBar().successBar(
                          context,
                          "Account created successfully!",
                        );
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.go(AppRoutes.login);
                        });
                      } else if (state is AuthError) {
                        CustomSnackBar().errorBar(context, state.message);
                      }
                    },
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                    SignUpWithEmailEvent(
                                      name: _nameController.text.trim(),
                                      email: _emailController.text.trim(),
                                      password: _passwordController.text,
                                      passwordConfirmation:
                                          _confirmPasswordController.text,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: Size(double.infinity, AppSizes.h40),
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
                                "Sign Up",
                                style: GoogleFonts.poppins(
                                  fontSize: AppSizes.sp12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.light,
                                ),
                              ),
                      );
                    },
                  ),
                  SizedBox(height: AppSizes.h24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: GoogleFonts.poppins(
                          fontSize: AppSizes.sp12,
                          color: AppColors.secondBlack,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Sign In",
                          style: GoogleFonts.poppins(
                            fontSize: AppSizes.sp12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSizes.h24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
