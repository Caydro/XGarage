import 'package:flutter_test/flutter_test.dart';
import 'package:garage/features/owner_home/domain/entities/daily_schedule_entity.dart';

void main() {
  group('DailyScheduleEntity Tests', () {
    test('isExcluded correctly identifies excluded days like Friday (5)', () {
      const schedule = DailyScheduleEntity(
        id: 1,
        vehicleId: 10,
        pickupTime: '09:00',
        excludedDays: [5], // Friday off
        includeWash: true,
        washType: 'exterior',
        isActive: true,
      );

      // Friday is day 5
      expect(schedule.isExcluded(5), isTrue);
      // Sunday (0), Monday (1), Thursday (4) are active
      expect(schedule.isExcluded(0), isFalse);
      expect(schedule.isExcluded(1), isFalse);
      expect(schedule.isExcluded(4), isFalse);
    });

    test('supports custom weekend exclusion (Friday 5 and Saturday 6)', () {
      const schedule = DailyScheduleEntity(
        id: 2,
        vehicleId: 11,
        pickupTime: '08:30',
        excludedDays: [5, 6],
        includeWash: false,
        washType: 'none',
        isActive: true,
      );

      expect(schedule.isExcluded(5), isTrue);
      expect(schedule.isExcluded(6), isTrue);
      expect(schedule.isExcluded(2), isFalse);
    });
  });
}
