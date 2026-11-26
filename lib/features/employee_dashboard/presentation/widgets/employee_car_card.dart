import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/glass_container.dart';
import '../../../../core/widgets/license_plate_badge.dart';
import '../../domain/entities/queue_item_entity.dart';

class EmployeeCarCard extends StatelessWidget {
  final QueueItemEntity item;
  final bool isArabic;
  final VoidCallback onActionTap;

  const EmployeeCarCard({
    super.key,
    required this.item,
    required this.isArabic,
    required this.onActionTap,
  });

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
    final carColor = _parseHex(item.colorHex);
    final isReady = item.isReadyAtGate;
    final isWashing = item.isWashing;

    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Time Countdown Badge & Wash Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusScheduledBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color:
                            AppColors.statusScheduled.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 14, color: AppColors.statusScheduled),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '${item.scheduledTime} • ${item.isFromSchedule ? (isArabic ? "موعد دوري" : "Daily Routine") : (isArabic ? "طلب فوري" : "On-Demand")}',
                          style: const TextStyle(
                            color: AppColors.statusScheduled,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (item.wantsWash) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusWashingBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.statusWashing.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.water_drop_rounded,
                          size: 12, color: AppColors.statusWashing),
                      const SizedBox(width: 4),
                      Text(
                        isArabic ? "مطلوب غسيل" : "WASH REQUIRED",
                        style: const TextStyle(
                          color: AppColors.statusWashing,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Plate Badge + Car Details + Spot
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              LicensePlateBadge(
                letters: item.plateLetters,
                numbers: item.plateNumbers,
                isCompact: true,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: carColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.vehicleTitle,
                            style:
                                AppTypography.getHeading3(isArabic: isArabic),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${isArabic ? "المالك:" : "Owner:"} ${item.ownerName}',
                      style: AppTypography.getCaption(isArabic: isArabic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Spot & Hook Pill (Wrapped for responsive safety)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceInput,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.parkingSpot != null
                                ? '${isArabic ? "موقف" : "Spot"} ${item.parkingSpot}'
                                : (isArabic ? "بدون موقف" : "No spot"),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white70),
                          ),
                        ),
                        if (item.keyHookNumber != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentRoseSoft,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.keyHookNumber!,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.accentRoseText),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 3: Status Progression Tactile Action Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isReady
                    ? AppColors.statusReady
                    : (isWashing
                        ? AppColors.statusWashing
                        : AppColors.primaryCrimson),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: onActionTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isReady
                        ? Icons.check_circle_outline_rounded
                        : (isWashing
                            ? Icons.local_car_wash_rounded
                            : Icons.tune_rounded),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getActionTitle(isArabic),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getActionTitle(bool isArabic) {
    if (item.isReadyAtGate) {
      return isArabic
          ? "جاهزة عند البوابة • تأكيد الخروج"
          : "Ready at Gate • Confirm Exit";
    }
    if (item.isWashing) {
      return isArabic
          ? "قيد الغسيل • نقل إلى البوابة"
          : "Washing • Move to Gate";
    }
    if (item.wantsWash) {
      return isArabic
          ? "بدء الغسيل أو تحديث الحالة"
          : "Start Wash / Update Status";
    }
    return isArabic ? "تحديث الحالة وتعيين الموقف" : "Update Status & Spot";
  }
}
