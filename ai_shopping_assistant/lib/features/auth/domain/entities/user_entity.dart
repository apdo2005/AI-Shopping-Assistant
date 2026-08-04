import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String username;
  final String email;
  final String role;
  final String? location;
  final String? phone;
  final String? token;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.location,
    this.phone,
    this.token,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, username, email, role, location, phone, token, createdAt];
}
