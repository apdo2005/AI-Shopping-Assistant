import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habispace/features/auth/domain/repository/auth_repository.dart';

import 'auth_state.dart';

part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<SignInWithEmailEvent>(_onSignInWithEmailEvent);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPasswordWithToken);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<SignUpWithEmailEvent>(_onSignUp);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
  }

  FutureOr<void> _onSignInWithEmailEvent(
    SignInWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.signInWithEmail(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(AuthSuccess(user: user)),
    );
  }

  FutureOr<void> _onForgotPassword(
    ForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.forgotPassword(email: event.email);
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (message) => emit(ForgotPasswordEmailSent(email: event.email, message: message)),
    );
  }

  FutureOr<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.verifyOtp(email: event.email, otp: event.otp);
    result.fold(
          (f) => emit(AuthError(message: f.message)),
          (_) => emit(OtpVerified(email: event.email, otp: event.otp)),
    );
  }

  FutureOr<void> _onResetPasswordWithToken(
    ResetPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await authRepository.resetPassword(
      otp: event.otp,
      email: event.email,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (_) => emit(PasswordResetSuccess()),
    );
  }

  FutureOr<void> _onSignUp(SignUpWithEmailEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.signUpWithEmail(
      name: event.name,
      email: event.email,
      password: event.password,
      passwordConfirmation: event.passwordConfirmation,
    );
    result.fold(
      (failure) => emit(AuthError(message: failure.message)),
      (user) => emit(SignUpSuccess(user: user)),
    );
  }

  FutureOr<void> _onSignInWithGoogle(
      SignInWithGoogleEvent event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    final result = await authRepository.signInWithGoogle();
    result.fold(
          (failure) => emit(AuthError(message: failure.message)),
          (user) => emit(AuthSuccess(user: user)),
    );
  }
}
