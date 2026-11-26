import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String role;
  final String locale;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.locale = 'ar',
    this.avatarUrl,
  });

  bool get isOwner => role == 'owner';
  bool get isEmployee => role == 'employee' || role == 'admin';

  @override
  List<Object?> get props => [id, name, phone, email, role, locale, avatarUrl];
}
