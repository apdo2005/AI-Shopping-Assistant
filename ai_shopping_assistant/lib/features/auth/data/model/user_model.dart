import 'package:habispace/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.role,
    required super.createdAt,
    super.location,
    super.phone,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] as Map<String, dynamic>;
    final user = data["user"] as Map<String, dynamic>;

    return UserModel(
      id: (user["id"] ??0).toInt(),
      username: user["name"] as String? ?? "Unknown",
      email: user["email"] as String? ?? "",
      role: user["role"] as String? ?? "user",
      location: user["location"] as String?,
      phone: user["phone"] ,
      token: data["token"] as String?,
      createdAt: user["created_at"] != null
          ? DateTime.parse(user["created_at"])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": username,
      "email": email,
      "role": role,
      "location": location,
      "phone": phone,
      "token": token,
      "created_at": createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? role,
    String? location,
    String? phone,
    String? token,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      token: token ?? this.token,
      createdAt: createdAt ?? this.createdAt,
    );
  }

}
