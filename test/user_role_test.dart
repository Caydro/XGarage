import 'package:flutter_test/flutter_test.dart';
import 'package:garage/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity Role Checks', () {
    test('correctly identifies owner role', () {
      const owner = UserEntity(
        id: 1,
        name: 'Tarek Mansour',
        phone: '01011111111',
        role: 'owner',
      );

      expect(owner.isOwner, isTrue);
      expect(owner.isEmployee, isFalse);
    });

    test('correctly identifies employee and admin roles', () {
      const employee = UserEntity(
        id: 2,
        name: 'Ahmed Staff',
        phone: '01000000001',
        role: 'employee',
      );

      const admin = UserEntity(
        id: 3,
        name: 'Admin User',
        phone: '01099999999',
        role: 'admin',
      );

      expect(employee.isEmployee, isTrue);
      expect(employee.isOwner, isFalse);

      expect(admin.isEmployee, isTrue);
      expect(admin.isOwner, isFalse);
    });
  });
}
