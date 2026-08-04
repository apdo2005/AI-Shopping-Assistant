part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignInWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];
}
class VerifyOtpEvent extends AuthEvent {
  final String email;
  final String otp;
  const VerifyOtpEvent({required this.email, required this.otp});
  @override
  List<Object> get props => [email, otp];
}

class ResetPasswordEvent  extends AuthEvent {
  final String otp;
  final String email;
  final String password;
  final String passwordConfirmation;

  const ResetPasswordEvent({
    required this.otp,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object> get props => [otp, email, password, passwordConfirmation];
}

class SignUpWithEmailEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  const SignUpWithEmailEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object> get props => [name, email, password];
}
class SignInWithGoogleEvent extends AuthEvent {
  const SignInWithGoogleEvent();
}