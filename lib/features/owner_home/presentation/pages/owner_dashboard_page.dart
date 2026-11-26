import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/glass_container.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/notifications_sheet.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../settings/presentation/locale_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/owner_cubit.dart';
import '../cubit/owner_state.dart';
import '../widgets/add_vehicle_sheet.dart';
import '../widgets/daily_schedule_sheet.dart';
import '../widgets/vehicle_hero_card.dart';

class OwnerDashboardPage extends StatefulWidget {
  const OwnerDashboardPage({super.key});

  @override
  State<OwnerDashboardPage> createState() => _OwnerDashboardPageState();
}

class _OwnerDashboardPageState extends State<OwnerDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<OwnerCubit>().loadDashboard();
  }

  void _openScheduleSheet(
      BuildContext context, dynamic vehicle, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DailyScheduleSheet(
        vehicle: vehicle,
        isArabic: isArabic,
        onSave: ({
          required vehicleId,
          required pickupTime,
          required excludedDays,
          required includeWash,
          required washType,
          required isActive,
          skipDate,
        }) {
          context.read<OwnerCubit>().saveSchedule(
                vehicleId: vehicleId,
                pickupTime: pickupTime,
                excludedDays: excludedDays,
                includeWash: includeWash,
                washType: washType,
                isActive: isActive,
                skipDate: skipDate,
              );
        },
      ),
    );
  }

  void _openAddVehicleSheet(BuildContext context, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddVehicleSheet(
        isArabic: isArabic,
        onAdd: ({
          required make,
          required model,
          year,
          required colorName,
          required colorHex,
          required plateLetters,
          required plateNumbers,
          specialNotes,
        }) {
          context.read<OwnerCubit>().addNewVehicle(
                make: make,
                model: model,
                year: year,
                colorName: colorName,
                colorHex: colorHex,
                plateLetters: plateLetters,
                plateNumbers: plateNumbers,
                specialNotes: specialNotes,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;
    final authState = context.watch<AuthCubit>().state;
    final userName = authState is Authenticated ? authState.user.name : null;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<OwnerCubit, OwnerState>(
          listener: (context, state) {
            if (state is OwnerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.statusDanger,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is OwnerLoading) {
              return StateViews.loading(
                message: isArabic
                    ? "جاري تحميل بيانات سيارتك..."
                    : "Loading vehicle details...",
              );
            }

            if (state is OwnerError) {
              return StateViews.error(
                message: state.message,
                onRetry: () => context.read<OwnerCubit>().loadDashboard(),
              );
            }

            if (state is OwnerLoaded) {
              final vehicle = state.primaryVehicle;

              return RefreshIndicator(
                color: AppColors.primaryCrimson,
                backgroundColor: AppColors.bgElevated,
                onRefresh: () => context.read<OwnerCubit>().loadDashboard(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Navigation Bar
                      _buildTopBar(context, isArabic),
                      const SizedBox(height: 16),

                      // Multi-car selector pills if multiple cars exist
                      if (state.vehicles.isNotEmpty) ...[
                        _buildVehiclePillSelector(context, state, isArabic),
                        const SizedBox(height: 16),
                      ],

                      // Recurring Schedule Summary Card
                      if (vehicle != null) ...[
                        _buildScheduleSummaryCard(
                            context, vehicle, state, isArabic),
                        const SizedBox(height: 18),
                      ],

                      // Hero Vehicle Card or Empty State
                      if (vehicle != null)
                        VehicleHeroCard(
                          vehicle: vehicle,
                          ownerName: vehicle.ownerName ?? userName,
                          isArabic: isArabic,
                          onTakeCarOut:
                              (wantsWash, washType, scheduledFor, notes) {
                            context.read<OwnerCubit>().requestImmediatePickup(
                                  vehicleId: vehicle.id,
                                  scheduledFor: scheduledFor,
                                  wantsWash: wantsWash,
                                  washType: washType,
                                  notes: notes,
                                );
                          },
                          onCancelRequest: (requestId) {
                            context
                                .read<OwnerCubit>()
                                .cancelActiveRequest(requestId);
                          },
                        )
                      else
                        StateViews.empty(
                          icon: Icons.directions_car_rounded,
                          title: isArabic
                              ? "لا توجد سيارات مسجلة"
                              : "No Vehicles Registered",
                          message: isArabic
                              ? "أضف سيارتك الأولى لبدء جدولة الخروج والغسيل"
                              : "Add your first vehicle to start scheduling departures and valet wash.",
                          buttonText:
                              isArabic ? "إضافة سيارة الآن" : "Add Vehicle Now",
                          onAction: () =>
                              _openAddVehicleSheet(context, isArabic),
                        ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isArabic) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              const AppLogo.emblem(size: 38, showGlow: true),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLogo.wordmark(
                        size: 14, showSubtitle: false, isItalic: true),
                    const SizedBox(height: 2),
                    Text(
                      isArabic ? "مرحباً بك في جراجك" : "Welcome Back",
                      style: AppTypography.getHeading3(isArabic: isArabic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Language Switcher Pill
            GestureDetector(
              onTap: () => context.read<LocaleCubit>().toggleLocale(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceInput,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  isArabic ? 'EN' : 'العربية',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 11),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Notifications Center
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(Icons.notifications_none_rounded,
                  color: AppColors.textSecondary, size: 22),
              onPressed: () =>
                  NotificationsSheet.show(context, isArabic: isArabic),
            ),
            // Settings / Logout
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(Icons.settings_outlined,
                  color: AppColors.textSecondary, size: 22),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehiclePillSelector(
      BuildContext context, OwnerLoaded state, bool isArabic) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...state.vehicles.map((v) {
            final isSelected = v.id == state.primaryVehicle?.id;
            return GestureDetector(
              onTap: () => context.read<OwnerCubit>().selectPrimaryVehicle(v),
              child: Container(
                margin: const EdgeInsets.only(right: 8, left: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentRoseSoft
                      : AppColors.surfaceInput,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryCrimson
                        : Colors.transparent,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_car_rounded,
                      size: 16,
                      color: isSelected
                          ? AppColors.accentRoseText
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${v.make} ${v.model}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          GestureDetector(
            onTap: () => _openAddVehicleSheet(context, isArabic),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: Colors.white24, style: BorderStyle.solid),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add, size: 16, color: Colors.white70),
                  const SizedBox(width: 4),
                  Text(
                    isArabic ? "إضافة سيارة" : "Add Car",
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSummaryCard(
      BuildContext context, dynamic vehicle, OwnerLoaded state, bool isArabic) {
    final sched = vehicle.dailySchedule;
    final bool hasSched = sched != null && sched.isActive;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  hasSched ? AppColors.accentRoseSoft : AppColors.surfaceInput,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.alarm_on_rounded,
              color: hasSched ? AppColors.primaryCrimson : AppColors.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isArabic ? "موعد الخروج اليومي:" : "Daily Departure:",
                      style: AppTypography.getCaption(isArabic: isArabic),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasSched
                          ? sched.pickupTime
                          : (isArabic ? "غير مفعل" : "Inactive"),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  hasSched
                      ? (isArabic
                          ? "إجازة: الجمعة • ${sched.includeWash ? 'مع غسيل دوري' : 'بدون غسيل'}"
                          : "Friday Off • ${sched.includeWash ? 'With auto-wash' : 'No wash'}")
                      : (isArabic
                          ? "اضغط لضبط روتينك الصباحي"
                          : "Tap to configure morning routine"),
                  style: TextStyle(
                    fontSize: 11,
                    color: hasSched
                        ? AppColors.textSecondary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _openScheduleSheet(context, vehicle, isArabic),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              backgroundColor: AppColors.surfaceInput,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isArabic ? "ضبط" : "Edit",
              style: const TextStyle(
                color: AppColors.accentRoseText,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
