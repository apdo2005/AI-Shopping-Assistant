import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habispace/features/auth/presentation/logic/auth_bloc.dart';
import 'package:habispace/features/auth/presentation/logic/auth_state.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/app_color.dart';
import '../../../../core/utils/app_sizes.dart';
import '../../../../core/utils/app_texts.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String get _otp => _controllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.secondBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppTexts.verifyOtpAppBar.tr(),
          style: GoogleFonts.poppins(
            fontSize: AppSizes.sp16,
            fontWeight: FontWeight.w600,
            color: AppColors.secondBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpVerified) {
            context.pushReplacement(
              AppRoutes.resetPassword,
              extra: {'email': state.email, 'otp': state.otp},
            );
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
            padding: EdgeInsets.symmetric(horizontal: AppSizes.w24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: AppSizes.h40),
                Icon(Icons.mark_email_read_outlined,
                    size: 64, color: AppColors.blue),
                SizedBox(height: AppSizes.h24),
                Text(
                  AppTexts.checkYourEmail.tr(),
                  style: GoogleFonts.poppins(
                    fontSize: AppSizes.sp20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondBlack,
                  ),
                ),
                SizedBox(height: AppSizes.h8),
                Text(
                  "${AppTexts.weSentCodeTo.tr()}\n${widget.email}",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: AppSizes.sp12,
                    color: AppColors.secondBlack.withValues(alpha: 0.6),
                    height: 1.6,
                  ),
                ),
                SizedBox(height: AppSizes.h40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) => _buildOtpField(i, context)),
                ),
                SizedBox(height: AppSizes.h40),

                ElevatedButton(
                  onPressed: state is AuthLoading
                      ? null
                      : () {
                    if (_otp.length == 6) {
                      context.read<AuthBloc>().add(
                        VerifyOtpEvent(
                          email: widget.email,
                          otp: _otp,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppTexts.pleaseEnterCompleteCode.tr()),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    minimumSize: Size(double.infinity, AppSizes.h50),
                    backgroundColor: AppColors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r8),
                    ),
                  ),
                  child: state is AuthLoading
                      ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : Text(
                    AppTexts.verifyCode.tr(),
                    style: GoogleFonts.poppins(
                      fontSize: AppSizes.sp14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.h24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${AppTexts.didntReceiveCode.tr()} ",
                      style: GoogleFonts.poppins(
                        fontSize: AppSizes.sp12,
                        color: AppColors.secondBlack.withValues(alpha: 0.6),
                      ),
                    ),
                    GestureDetector(
                      onTap: state is AuthLoading
                          ? null
                          : () {
                        context.read<AuthBloc>().add(
                          ForgotPasswordEvent(email: widget.email),
                        );
                      },
                      child: Text(
                        AppTexts.resend.tr(),
                        style: GoogleFonts.poppins(
                          fontSize: AppSizes.sp12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOtpField(int index, BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.poppins(
          fontSize: AppSizes.sp20,
          fontWeight: FontWeight.w600,
          color: AppColors.secondBlack,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.r10),
            borderSide: BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSizes.r10),
            borderSide: BorderSide(color: AppColors.blue, width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          setState(() {});
        },
      ),
    );
  }
}