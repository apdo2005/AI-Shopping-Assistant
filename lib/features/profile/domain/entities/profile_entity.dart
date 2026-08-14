class ProfileEntity {
  final ProfileUserEntity user;
  final List<ActiveSessionEntity> activeSessions;
  final bool canChangePassword;
  final bool canChangeUsername;
  final int addressCount;
  final int orderCount;
  final int inProgressOrderCount;
  final int wishlistCount;
  final List<ProfileOrderEntity> orderHistory;
  final List<ProfileOrderEntity> inProgressOrders;
  final List<Map<String, dynamic>> wishlist;

  const ProfileEntity({
    required this.user,
    required this.activeSessions,
    required this.canChangePassword,
    required this.canChangeUsername,
    required this.addressCount,
    required this.orderCount,
    required this.inProgressOrderCount,
    required this.wishlistCount,
    required this.orderHistory,
    required this.inProgressOrders,
    required this.wishlist,
  });
}

class ProfileOrderEntity {
  final Map<String, dynamic> data;
  final String? orderedAt;

  const ProfileOrderEntity({required this.data, this.orderedAt});
}

class ProfileUserEntity {
  final int id;
  final String? profileImageUrl;
  final String? name;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? gender;
  final String? birthday;
  final String email;
  final bool emailVerified;
  final String? phone;
  final bool phoneVerified;
  final String? countryCode;
  final List<String> preferredLanguages;

  const ProfileUserEntity({
    required this.id,
    required this.profileImageUrl,
    required this.name,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.birthday,
    required this.email,
    required this.emailVerified,
    required this.phone,
    required this.phoneVerified,
    required this.countryCode,
    required this.preferredLanguages,
  });

  String get displayName {
    final fullName = [firstName, lastName]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .join(' ');
    final fallbackName = name?.trim();
    return fullName.isNotEmpty
        ? fullName
        : (fallbackName?.isNotEmpty ?? false ? fallbackName! : username);
  }
}

class ActiveSessionEntity {
  final int id;
  final String name;
  final String? lastUsedAt;
  final bool isCurrent;

  const ActiveSessionEntity({
    required this.id,
    required this.name,
    required this.lastUsedAt,
    required this.isCurrent,
  });
}
