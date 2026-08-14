import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.user,
    required super.activeSessions,
    required super.canChangePassword,
    required super.canChangeUsername,
    required super.addressCount,
    required super.orderCount,
    required super.inProgressOrderCount,
    required super.wishlistCount,
    required super.orderHistory,
    required super.inProgressOrders,
    required super.wishlist,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final me = _map(json['me']);
    final settings = _map(json['settings']);
    final privacy = _map(settings['privacy_and_security']);
    final orderHistory = _map(json['order_history']);

    final orders = _list(orderHistory['orders']);
    final orderedAt = _list(orderHistory['ordered_at']);
    return ProfileModel(
      user: ProfileUserModel.fromJson(me),
      activeSessions: _list(privacy['active_sessions'])
          .map((session) => ActiveSessionModel.fromJson(_map(session)))
          .toList(),
      canChangePassword: _map(privacy['change_password'])['available'] == true,
      canChangeUsername: _map(privacy['change_username'])['available'] == true,
      addressCount: _list(json['addresses']).length,
      orderCount: orders.length,
      inProgressOrderCount: _list(json['in_progress_orders']).length,
      wishlistCount: _list(json['wishlist']).length,
      orderHistory: List.generate(
        orders.length,
        (index) => ProfileOrderModel(
          data: _map(orders[index]),
          orderedAt: index < orderedAt.length ? _nullableString(orderedAt[index]) : null,
        ),
      ),
      inProgressOrders: _list(json['in_progress_orders'])
          .map((order) => ProfileOrderModel(data: _map(order)))
          .toList(),
      wishlist: _list(json['wishlist']).map(_map).toList(),
    );
  }
}

class ProfileUserModel extends ProfileUserEntity {
  const ProfileUserModel({
    required super.id,
    required super.profileImageUrl,
    required super.name,
    required super.username,
    required super.firstName,
    required super.lastName,
    required super.gender,
    required super.birthday,
    required super.email,
    required super.emailVerified,
    required super.phone,
    required super.phoneVerified,
    required super.countryCode,
    required super.preferredLanguages,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      profileImageUrl: _nullableString(json['profile_picture']) ??
          _nullableString(json['profile_image_url']),
      name: _nullableString(json['name']),
      username: json['username']?.toString() ?? '',
      firstName: _nullableString(json['firstname']),
      lastName: _nullableString(json['lastname']),
      gender: _nullableString(json['gender']),
      birthday: _nullableString(json['birthday']),
      email: json['email']?.toString() ?? '',
      emailVerified: json['email_verified'] == true,
      phone: _nullableString(json['phone']),
      phoneVerified: json['phone_verified'] == true,
      countryCode: _nullableString(json['country_code']),
      preferredLanguages: _list(json['preferred_languages'])
          .map((language) => language.toString())
          .toList(),
    );
  }
}

class ProfileOrderModel extends ProfileOrderEntity {
  const ProfileOrderModel({required super.data, super.orderedAt});
}

class ActiveSessionModel extends ActiveSessionEntity {
  const ActiveSessionModel({
    required super.id,
    required super.name,
    required super.lastUsedAt,
    required super.isCurrent,
  });

  factory ActiveSessionModel.fromJson(Map<String, dynamic> json) {
    return ActiveSessionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? 'Session',
      lastUsedAt: _nullableString(json['last_used_at']),
      isCurrent: json['is_current'] == true,
    );
  }
}

Map<String, dynamic> _map(dynamic value) => value is Map<String, dynamic>
    ? value
    : value is Map
    ? Map<String, dynamic>.from(value)
    : <String, dynamic>{};

List<dynamic> _list(dynamic value) => value is List ? value : const [];

String? _nullableString(dynamic value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}
