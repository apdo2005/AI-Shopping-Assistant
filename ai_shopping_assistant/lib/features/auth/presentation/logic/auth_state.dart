import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  final UserEntity user;

  const AuthSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

final class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
class PasswordResetOtpSent extends AuthState {
final String message;
final String email;

const PasswordResetOtpSent({required this.message, required this.email});

@override
List<Object> get props => [message, email];
}

final class ForgotPasswordEmailSent extends AuthState {
  final String email;
  final String message;

  const ForgotPasswordEmailSent({required this.email , required this.message});

  @override
  List<Object> get props => [email, message];
}
final class OtpVerified extends AuthState {
  final String email;
  final String otp;
  const OtpVerified({required this.email, required this.otp});
  @override
  List<Object> get props => [email, otp];
}
final class PasswordResetSuccess extends AuthState {}
final class SignUpSuccess extends AuthState {
  final UserEntity user;

  const SignUpSuccess({required this.user});

  @override
  List<Object> get props => [user];
}
