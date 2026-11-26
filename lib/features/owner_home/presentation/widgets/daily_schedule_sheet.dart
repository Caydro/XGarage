import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/vehicle_entity.dart';

class DailyScheduleSheet extends StatefulWidget {
  final VehicleEntity vehicle;
  final bool isArabic;
  final Function({
    required int vehicleId,
    required String pickupTime,
    required List<int> excludedDays,
    required bool includeWash,
    required String washType,
    required bool isActive,
    String? skipDate,
  }) onSave;

  const DailyScheduleSheet({
    super.key,
    required this.vehicle,
    required this.isArabic,
    required this.onSave,
  });

  @override
  State<DailyScheduleSheet> createState() => _DailyScheduleSheetState();
}

class _DailyScheduleSheetState extends State<DailyScheduleSheet> {
  late TimeOfDay _pickupTime;
  late List<int> _excludedDays;
  late bool _includeWash;
  late String _washType;
  late bool _isActive;
  bool _skipTomorrow = false;

  final List<Map<String, dynamic>> _weekdays = [
    {'day': 6, 'ar': 'السبت', 'en': 'Sat'},
    {'day': 0, 'ar': 'الأحد', 'en': 'Sun'},
    {'day': 1, 'ar': 'الاثنين', 'en': 'Mon'},
    {'day': 2, 'ar': 'الثلاثاء', 'en': 'Tue'},
    {'day': 3, 'ar': 'الأربعاء', 'en': 'Wed'},
    {'day': 4, 'ar': 'الخميس', 'en': 'Thu'},
    {'day': 5, 'ar': 'الجمعة', 'en': 'Fri'},
  ];

  @override
  void initState() {
    super.initState();
    final sched = widget.vehicle.dailySchedule;

    if (sched != null) {
      final parts = sched.pickupTime.split(':');
      _pickupTime = TimeOfDay(
        hour: int.tryParse(parts[0]) ?? 9,
        minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
      );
      _excludedDays = List<int>.from(sched.excludedDays);
      _includeWash = sched.includeWash;
      _washType = sched.washType;
      _isActive = sched.isActive;
    } else {
      _pickupTime = const TimeOfDay(hour: 9, minute: 0);
      _excludedDays = [5]; // Default Friday excluded
      _includeWash = false;
      _washType = 'none';
      _isActive = true;
    }
  }

  void _toggleDay(int dayIndex) {
    setState(() {
      if (_excludedDays.contains(dayIndex)) {
        _excludedDays.remove(dayIndex);
      } else {
        _excludedDays.add(dayIndex);
      }
    });
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickupTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryCrimson,
              surface: AppColors.bgElevated,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _pickupTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeFormatted =
        '${_pickupTime.hour.toString().padLeft(2, '0')}:${_pickupTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.isArabic ? "جدول الخروج اليومي المتكرر" : "Daily Recurring Departure",
                  style: AppTypography.getHeading2(isArabic: widget.isArabic),
                ),
                Switch(
                  value: _isActive,
                  activeThumbColor: AppColors.primaryCrimson,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
              ],
            ),
            Text(
              widget.isArabic
                  ? "حدد موعد خروجك اليومي وأيام الإجازة لتجهيز السيارة وغسيلها مسبقاً"
                  : "Set your daily departure time & rest days so your car is ready and washed on time.",
              style: AppTypography.getCaption(isArabic: widget.isArabic),
            ),
            const SizedBox(height: 20),

            // Time Selector Card
            GestureDetector(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceInput,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorderHighlight.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: AppColors.primaryCrimson, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isArabic ? "موعد الخروج الصباحي" : "Morning Departure Time",
                            style: AppTypography.getCaption(isArabic: widget.isArabic),
                          ),
                          Text(
                            timeFormatted,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.accentRoseSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.isArabic ? "تعديل" : "Change",
                        style: const TextStyle(color: AppColors.accentRoseText, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Weekday Off-Days Selector
            Text(
              widget.isArabic ? "أيام الإجازة الأسبوعية (تكون السيارة متوقفة)" : "Weekly Off-Days (Car will not leave)",
              style: AppTypography.getHeading3(isArabic: widget.isArabic),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _weekdays.map((item) {
                final int day = item['day'] as int;
                final bool isOff = _excludedDays.contains(day);
                final label = widget.isArabic ? item['ar'] as String : item['en'] as String;

                return GestureDetector(
                  onTap: () => _toggleDay(day),
                  child: Container(
                    width: 44,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isOff ? AppColors.accentRoseSoft : AppColors.surfaceInput,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isOff ? AppColors.primaryCrimson : Colors.white10,
                        width: isOff ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isOff ? AppColors.accentRoseText : Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Icon(
                          isOff ? Icons.beach_access_rounded : Icons.check_circle_outline_rounded,
                          size: 14,
                          color: isOff ? AppColors.primaryCrimson : AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Auto-wash switch
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceInput,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.wash_rounded, color: AppColors.statusWashing, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.isArabic ? "غسيل تلقائي دوري مع الموعد" : "Auto-wash before scheduled exit",
                          style: AppTypography.getBodyMedium(isArabic: widget.isArabic),
                        ),
                      ),
                      Switch(
                        value: _includeWash,
                        activeThumbColor: AppColors.primaryCrimson,
                        onChanged: (val) {
                          setState(() {
                            _includeWash = val;
                            if (val && _washType == 'none') _washType = 'exterior';
                          });
                        },
                      ),
                    ],
                  ),
                  if (_includeWash) ...[
                    const Divider(color: Colors.white12, height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildWashPill('exterior', widget.isArabic ? "خارجي سريع" : "Quick Exterior"),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildWashPill('full', widget.isArabic ? "شامل كامل" : "Full Clean"),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // One-tap Skip Tomorrow quick action
            GestureDetector(
              onTap: () => setState(() => _skipTomorrow = !_skipTomorrow),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _skipTomorrow ? AppColors.statusScheduledBg : AppColors.surfaceInput,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _skipTomorrow ? AppColors.statusScheduled : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _skipTomorrow ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      color: _skipTomorrow ? AppColors.statusScheduled : AppColors.textMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.isArabic ? "إجازة غداً (تخطي موعد الغد فقط)" : "Skip tomorrow's pickup only",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _skipTomorrow ? AppColors.statusScheduled : Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Action Button
            AppButton(
              text: widget.isArabic ? "حفظ إعدادات الموعد" : "Save Schedule",
              onPressed: () {
                final tomorrow = DateTime.now().add(const Duration(days: 1));
                final tomorrowFormatted =
                    '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

                widget.onSave(
                  vehicleId: widget.vehicle.id,
                  pickupTime: timeFormatted,
                  excludedDays: _excludedDays,
                  includeWash: _includeWash,
                  washType: _includeWash ? _washType : 'none',
                  isActive: _isActive,
                  skipDate: _skipTomorrow ? tomorrowFormatted : null,
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWashPill(String type, String label) {
    final isSelected = _washType == type;
    return GestureDetector(
      onTap: () => setState(() => _washType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentRoseSoft : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryCrimson : Colors.transparent,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.accentRoseText : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
