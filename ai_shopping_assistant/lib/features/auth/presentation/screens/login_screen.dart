import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habispace/features/auth/presentation/logic/auth_bloc.dart';
import 'package:habispace/features/auth/presentation/logic/auth_state.dart';
import 'package:habispace/features/auth/presentation/screens/terms_and_conditions_screen.dart';
import '../../../../core/di/get_it.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/shared/custom_svg.dart';
import '../../../../core/shared/custom_textformfield.dart';
import '../../../../core/shared/snakbar.dart';
import '../../../../core/utils/app_color.dart';
import '../../../../core/utils/app_sizes.dart';
import '../../../../core/utils/app_validation.dart';
import 'in_our_privacy_policy_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _getErrorMessage(String apiMessage) {
    final msg = apiMessage.toLowerCase();
    if (msg.contains('invalid credentials') || msg.contains('unauthorized')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (msg.contains('email')) return 'Please check your email address.';
    if (msg.contains('password')) return 'Incorrect password. Please try again.';
    if (msg.contains('not found') || msg.contains('no account')) {
      return 'No account found with this email.';
    }
    if (msg.contains('server') || msg.contains('500')) {
      return 'Server error. Please try again later.';
    }
    return apiMessage;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: Scaffold(
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
                      "Sign In Account",
                      style: GoogleFonts.poppins(
                        fontSize: AppSizes.h20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondBlack,
                      ),
                    ),
                    SizedBox(height: AppSizes.h24),
                    CustomTextformfeild(
                      keyboardType: TextInputType.emailAddress,
                      hintText: "Email",
                      controller: _emailController,
                      validator: AppValidators.email,
                      formFieldKey: const Key("email"),
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
                      formFieldKey: const Key("password"),
                      labelText: "Password",
                      isPassword: true,
                      labelcolor: AppColors.secondBlack,
                      borderRadius: AppSizes.r10,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push(AppRoutes.forgotPassword),

                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.poppins(
                            fontSize: AppSizes.h12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.blue,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.h24),
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthSuccess) {
                          CustomSnackBar().successBar(
                            context,
                            "Welcome back, ${state.user.username}!",
                          );
                          context.go(AppRoutes.home);
                        } else if (state is AuthError) {
                          CustomSnackBar().errorBar(
                            context,
                            _getErrorMessage(state.message),
                          );
                        }
                      },
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    context.read<AuthBloc>().add(
                                      SignInWithEmailEvent(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
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
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  "Login",
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
                    FittedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(height: 2, width: AppSizes.w120, color: AppColors.borderColor),
                          Text(
                            "or login with",
                            style: GoogleFonts.inter(
                              fontSize: AppSizes.sp16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.secondBlack,
                            ),
                          ),
                          Container(height: 2, width: AppSizes.w120, color: AppColors.borderColor),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSizes.h18),
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthSuccess) {
                          CustomSnackBar().successBar(
                            context,
                            "Welcome back, ${state.user.username}!",
                          );
                          context.go(AppRoutes.home);
                        } else if (state is AuthError) {
                          CustomSnackBar().errorBar(
                            context,
                            _getErrorMessage(state.message),
                          );
                        }
                      },
                      builder: (context, state) {
                        return ElevatedButton.icon(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  context.read<AuthBloc>().add(SignInWithGoogleEvent());
                                },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            minimumSize: Size(double.infinity, AppSizes.h50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSizes.r16),
                            ),
                          ),
                          icon: FaIcon(
                            FontAwesomeIcons.google,
                            color: AppColors.blue,
                            size: AppSizes.r20,
                          ),
                          label: Text(
                            "Continue with Google",
                            style: GoogleFonts.poppins(
                              fontSize: AppSizes.sp16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
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
                          "Don't have an account?",
                          style: GoogleFonts.poppins(
                            fontSize: AppSizes.sp12,
                            color: AppColors.secondBlack,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.signup),
                          child: Text(
                            "Sign Up",
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "By signing in, you agree to our ",
                          style: GoogleFonts.poppins(
                            fontSize: AppSizes.sp12,
                            color: AppColors.secondBlack,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(

                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TermsAndConditionsScreen(),
                            ),
                          ),
                          child: SizedBox(
                            width: AppSizes.w120,
                            child: Text(
                              "Terms and Conditions.",
                              style: GoogleFonts.poppins(
                                fontSize: AppSizes.sp12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.blue,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Learn how we use your data ",
                          style: GoogleFonts.poppins(
                            fontSize: AppSizes.sp12,
                            color: AppColors.secondBlack,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(

                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyScreen(),
                            ),
                          ),
                          child: SizedBox(
                            width: AppSizes.w120,
                            child: Text(
                              "in our Privacy Policy.",
                              style: GoogleFonts.poppins(
                                fontSize: AppSizes.sp12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.blue,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
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
      ),
    );
  }
}
