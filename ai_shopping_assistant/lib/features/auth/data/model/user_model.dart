import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.role,
    super.location,
    super.phone,
    super.token,
    required super.createdAt,
  });

  factory UserModel.fromFirebaseUser(firebase.User user, {String? token}) {
    return UserModel(
      id: user.uid,
      username: user.displayName ?? user.email?.split('@').first ?? 'User',
      email: user.email ?? '',
      role: 'user',
      location: null,
      phone: user.phoneNumber,
      token: token,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    final userData = data['user'] ?? data;

    return UserModel(
      id: userData['id']?.toString() ?? '',
      username: userData['username'] ?? userData['name'] ?? '',
      email: userData['email'] ?? '',
      role: userData['role'] ?? 'user',
      location: userData['location'],
      phone: userData['phone'],
      token: data['token'] ??
    json['token'] ??
    json['access_token'] ??
    userData['token'],
      createdAt: userData['created_at'] != null
          ? DateTime.tryParse(userData['created_at'].toString()) ??
                DateTime.now()
          : DateTime.now(),
    );
  }
}
