import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/glass_container.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/license_plate_badge.dart';
import '../../domain/entities/vehicle_entity.dart';

class VehicleHeroCard extends StatefulWidget {
  final VehicleEntity vehicle;
  final String? ownerName;
  final bool isArabic;
  final Function(bool wantsWash, String washType, DateTime? scheduledFor, String? notes) onTakeCarOut;
  final Function(int requestId) onCancelRequest;

  const VehicleHeroCard({
    super.key,
    required this.vehicle,
    this.ownerName,
    required this.isArabic,
    required this.onTakeCarOut,
    required this.onCancelRequest,
  });

  @override
  State<VehicleHeroCard> createState() => _VehicleHeroCardState();
}

class _VehicleHeroCardState extends State<VehicleHeroCard> {
  bool _wantsWash = false;
  String _selectedWashType = 'exterior';
  bool _isScheduledDeparture = false;
  bool _isSubmitting = false;
  bool _isCanceling = false;
  TimeOfDay _selectedDepartureTime =
      TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 30)));
  int _selectedPresetMinutes = 30;

  String _formatTimeOfDay(TimeOfDay tod, bool isArabic) {
    final hour12 = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final minuteStr = tod.minute.toString().padLeft(2, '0');
    final periodStr = isArabic
        ? (tod.period == DayPeriod.am ? 'ص' : 'م')
        : (tod.period == DayPeriod.am ? 'AM' : 'PM');
    return '$hour12:$minuteStr $periodStr';
  }

  void _applyPresetMinutes(int minutes) {
    final target = DateTime.now().add(Duration(minutes: minutes));
    setState(() {
      _selectedPresetMinutes = minutes;
      _selectedDepartureTime = TimeOfDay.fromDateTime(target);
    });
  }

  Future<void> _pickCustomTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDepartureTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryCrimson,
              surface: AppColors.bgElevated,
              onSurface: Colors.white,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedPresetMinutes = -1; // custom
        _selectedDepartureTime = picked;
      });
    }
  }

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final activeReq = v.activePickupRequest;
    final carColor = _parseHex(v.colorHex);

    return Stack(
      children: [
        // Subtle ambient radial glow behind hero card
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 0.9,
                colors: [AppColors.primaryGlow, Colors.transparent],
              ),
            ),
          ),
        ),
        GlassContainer(
          enableBlur: true,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Car Title & Spot Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Car Color Swatch Dot
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(top: 4, right: 8, left: 8),
                    decoration: BoxDecoration(
                      color: carColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white70, width: 1.5),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          v.displayName,
                          style: AppTypography.getHeading3(
                                  isArabic: widget.isArabic)
                              .copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          softWrap: true,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${v.colorName} • ${v.isInsideGarage ? (widget.isArabic ? "داخل الجراج" : "Inside Garage") : (widget.isArabic ? "خارج الجراج" : "Outside")}',
                          style: AppTypography.getCaption(
                              isArabic: widget.isArabic),
                        ),
                        if (v.ownerName != null ||
                            widget.ownerName != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline_rounded,
                                size: 13,
                                color: AppColors.accentRoseText,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${widget.isArabic ? "مالك السيارة: " : "Owner: "}${v.ownerName ?? widget.ownerName}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accentRoseText,
                                  ),
                                  maxLines: 2,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (v.parkingSpot != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.accentRoseSoft,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryCrimson.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '${widget.isArabic ? "موقف" : "Spot"} ${v.parkingSpot}',
                        style: const TextStyle(
                          color: AppColors.accentRoseText,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // Center: Authentic Egyptian / GCC License Plate Display
              Center(
                child: LicensePlateBadge(
                  letters: v.plateLetters,
                  numbers: v.plateNumbers,
                ),
              ),
              const SizedBox(height: 20),

              // Status Stepper Banner
              _buildStatusStepper(v, activeReq),
              const SizedBox(height: 20),

              // Action Section: Either active request tracker OR Instant Take Out button
              if (activeReq != null) ...[
                _buildActiveRequestView(activeReq),
              ] else ...[
                _buildTakeOutControls(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusStepper(VehicleEntity v, dynamic activeReq) {
    String current = v.currentStatus;
    if (activeReq != null && activeReq.status != 'scheduled') {
      current = activeReq.status;
    }

    final steps = [
      {'key': 'parked', 'labelAr': 'في الموقف', 'labelEn': 'Parked'},
      {'key': 'washing', 'labelAr': 'في الغسيل', 'labelEn': 'Washing'},
      {'key': 'ready_at_gate', 'labelAr': 'جاهزة عند البوابة', 'labelEn': 'Ready at Gate'},
    ];

    int activeIdx = 0;
    if (current == 'washing') activeIdx = 1;
    if (current == 'ready_at_gate') activeIdx = 2;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(steps.length, (idx) {
          final isPassed = idx <= activeIdx;
          final isCurrent = idx == activeIdx;
          final label = widget.isArabic ? steps[idx]['labelAr']! : steps[idx]['labelEn']!;

          Color dotColor = const Color(0xFF4B465C);
          if (isCurrent) {
            dotColor = idx == 2 ? AppColors.statusReady : AppColors.primaryCrimson;
          } else if (isPassed) {
            dotColor = AppColors.primaryCrimson.withValues(alpha: 0.7);
          }

          return Row(
            children: [
              Column(
                children: [
                  Container(
                    width: isCurrent ? 14 : 10,
                    height: isCurrent ? 14 : 10,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: dotColor.withValues(alpha: 0.6),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                      color: isCurrent ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              if (idx < steps.length - 1)
                Container(
                  width: 24,
                  height: 1.5,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: idx < activeIdx ? AppColors.primaryCrimson : const Color(0xFF33303D),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildActiveRequestView(dynamic activeReq) {
    final bool isReady = activeReq.isReadyAtGate;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isReady ? AppColors.statusReadyBg : AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isReady ? AppColors.statusReady : AppColors.primaryCrimson.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isReady ? Icons.check_circle_rounded : Icons.schedule_rounded,
                color: isReady ? AppColors.statusReady : AppColors.statusScheduled,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isReady
                          ? (widget.isArabic ? "سيارتك جاهزة عند البوابة الآن!" : "Your car is ready at the gate!")
                          : (widget.isArabic ? "طلب الخروج قيد التنفيذ" : "Exit request in progress"),
                      style: TextStyle(
                        color: isReady ? AppColors.statusReady : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (activeReq.wantsWash)
                      Text(
                        widget.isArabic
                            ? 'غسيل: ${activeReq.washStatus == "completed" ? "تم الانتهاء" : "قيد الغسيل"}'
                            : 'Wash: ${activeReq.washStatus}',
                        style: const TextStyle(color: AppColors.statusWashing, fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (!isReady)
                _isCanceling
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.statusDanger,
                        ),
                      )
                    : IconButton(
                        onPressed: () async {
                          setState(() => _isCanceling = true);
                          try {
                            await widget.onCancelRequest(activeReq.id);
                          } finally {
                            if (mounted) setState(() => _isCanceling = false);
                          }
                        },
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.statusDanger, size: 20),
                        tooltip:
                            widget.isArabic ? "إلغاء الطلب" : "Cancel Request",
                      ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTakeOutControls() {
    final isAr = widget.isArabic;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timing Mode Switcher (Now vs Scheduled Time)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isScheduledDeparture = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !_isScheduledDeparture
                          ? AppColors.accentRoseSoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flash_on_rounded,
                            size: 15,
                            color: !_isScheduledDeparture
                                ? AppColors.accentRoseText
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isAr ? "الآن (~10 دقائق)" : "Now (~10 min)",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: !_isScheduledDeparture
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: !_isScheduledDeparture
                                  ? AppColors.accentRoseText
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isScheduledDeparture = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _isScheduledDeparture
                          ? AppColors.accentRoseSoft
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 15,
                            color: _isScheduledDeparture
                                ? AppColors.accentRoseText
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isAr ? "تحديد موعد لاحق" : "Pick Later Time",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _isScheduledDeparture
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: _isScheduledDeparture
                                  ? AppColors.accentRoseText
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scheduled Timing Details & Preset Quick-Chips
        if (_isScheduledDeparture) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceInput,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.primaryCrimson.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded,
                            color: AppColors.statusScheduled, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          isAr ? "الموعد المطلوب لتجهيز سيارتك:" : "Desired Ready Time:",
                          style: AppTypography.getCaption(isArabic: isAr),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _pickCustomTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryCrimson.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.primaryCrimson.withValues(alpha: 0.6)),
                        ),
                        child: Text(
                          _formatTimeOfDay(_selectedDepartureTime, isAr),
                          style: AppTypography.getTelemetry(
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Quick Presets Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildPresetChip(15, isAr ? "+15 دقيقة" : "+15m"),
                      const SizedBox(width: 6),
                      _buildPresetChip(30, isAr ? "+30 دقيقة" : "+30m"),
                      const SizedBox(width: 6),
                      _buildPresetChip(60, isAr ? "+ساعة" : "+1 hr"),
                      const SizedBox(width: 6),
                      _buildPresetChip(120, isAr ? "+ساعتين" : "+2 hrs"),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _pickCustomTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: _selectedPresetMinutes == -1
                                ? AppColors.accentRoseSoft
                                : AppColors.bgElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedPresetMinutes == -1
                                  ? AppColors.primaryCrimson
                                  : Colors.white12,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.edit_calendar_rounded,
                                  size: 13, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                isAr ? "تحديد يدوي..." : "Custom...",
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Wash Toggle Switch
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.local_car_wash_rounded,
                  color: AppColors.statusWashing, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.isArabic
                      ? "غسيل السيارة قبل الخروج"
                      : "Wash car before departure",
                  style: AppTypography.getBodyMedium(isArabic: widget.isArabic),
                ),
              ),
              Switch(
                value: _wantsWash,
                activeThumbColor: AppColors.primaryCrimson,
                onChanged: (val) => setState(() => _wantsWash = val),
              ),
            ],
          ),
        ),

        // Wash Type Selector if toggled
        if (_wantsWash) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildWashTypePill('exterior',
                    widget.isArabic ? "غسيل خارجي" : "Exterior Wash"),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildWashTypePill('full',
                    widget.isArabic ? "غسيل شامل داخلي/خارجي" : "Full Wash"),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),

        // Primary Tactile Button with 3 Jumping Dots
        AppButton(
          text: _isScheduledDeparture
              ? (isAr
                  ? "تأكيد طلب الخروج في (${_formatTimeOfDay(_selectedDepartureTime, true)})"
                  : "Schedule Ready at ${_formatTimeOfDay(_selectedDepartureTime, false)}")
              : (isAr ? "طلب إخراج السيارة الآن" : "Take Car Out Now"),
          icon: Icons.directions_car_rounded,
          isLoading: _isSubmitting,
          onPressed: () async {
            setState(() => _isSubmitting = true);
            try {
              DateTime? targetDateTime;
              if (_isScheduledDeparture) {
                final now = DateTime.now();
                targetDateTime = DateTime(
                  now.year,
                  now.month,
                  now.day,
                  _selectedDepartureTime.hour,
                  _selectedDepartureTime.minute,
                );
                if (targetDateTime.isBefore(now)) {
                  targetDateTime = targetDateTime.add(const Duration(days: 1));
                }
              }
              await widget.onTakeCarOut(
                _wantsWash,
                _selectedWashType,
                targetDateTime,
                null,
              );
            } finally {
              if (mounted) setState(() => _isSubmitting = false);
            }
          },
        ),
      ],
    );
  }

  Widget _buildPresetChip(int minutes, String label) {
    final isSelected = _selectedPresetMinutes == minutes;
    return GestureDetector(
      onTap: () => _applyPresetMinutes(minutes),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentRoseSoft : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primaryCrimson : Colors.white12,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.accentRoseText : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildWashTypePill(String type, String label) {
    final isSelected = _selectedWashType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedWashType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentRoseSoft : AppColors.surfaceInput,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryCrimson : Colors.transparent,
            width: 1.2,
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
