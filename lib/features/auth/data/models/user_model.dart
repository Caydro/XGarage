import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
    required super.role,
    super.locale = 'ar',
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'owner',
      locale: json['locale'] as String? ?? 'ar',
      avatarUrl: json['avatar_url'] as String? ?? json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'locale': locale,
      'avatar_url': avatarUrl,
    };
  }
}
