import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/notifications_sheet.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../settings/presentation/locale_cubit.dart';
import '../cubit/employee_cubit.dart';
import '../cubit/employee_state.dart';
import '../widgets/employee_car_card.dart';
import '../widgets/status_update_sheet.dart';

class EmployeeQueuePage extends StatefulWidget {
  const EmployeeQueuePage({super.key});

  @override
  State<EmployeeQueuePage> createState() => _EmployeeQueuePageState();
}

class _EmployeeQueuePageState extends State<EmployeeQueuePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<EmployeeCubit>().loadQueue();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openStatusSheet(BuildContext context, dynamic item, bool isArabic) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatusUpdateSheet(
        item: item,
        isArabic: isArabic,
        onUpdateSpot: (spot, keyHook) {
          context.read<EmployeeCubit>().updateSpot(
                vehicleId: item.vehicleId,
                spot: spot,
                keyHook: keyHook,
              );
        },
        onUpdateStatus: (status, washStatus, notes) {
          context.read<EmployeeCubit>().updateStatus(
                vehicleId: item.vehicleId,
                status: status,
                washStatus: washStatus,
                notes: notes,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = context.watch<LocaleCubit>().isArabic;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<EmployeeCubit, EmployeeState>(
          listener: (context, state) {
            if (state is EmployeeError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.statusDanger,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is EmployeeLoading) {
              return StateViews.loading(
                message: isArabic
                    ? "جاري تحميل جدول خروج اليوم..."
                    : "Loading today's queue...",
              );
            }

            if (state is EmployeeError) {
              return StateViews.error(
                message: state.message,
                onRetry: () => context.read<EmployeeCubit>().loadQueue(),
              );
            }

            if (state is EmployeeLoaded) {
              return RefreshIndicator(
                color: AppColors.primaryCrimson,
                backgroundColor: AppColors.bgElevated,
                onRefresh: () => context.read<EmployeeCubit>().loadQueue(),
                child: CustomScrollView(
                  slivers: [
                    // Top App Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTopHeader(context, isArabic),
                            const SizedBox(height: 16),

                            // KPI Summary Row
                            _buildKpiRow(state.summary, isArabic),
                            const SizedBox(height: 16),

                            // Search Field
                            _buildSearchBar(isArabic),
                            const SizedBox(height: 14),

                            // Filter Pills
                            _buildFilterPills(state.activeFilter, isArabic),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    // Queue List
                    if (state.queue.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: StateViews.empty(
                          icon: Icons.checklist_rounded,
                          title: isArabic
                              ? "لا توجد سيارات في هذه القائمة"
                              : "No vehicles in this queue",
                          message: isArabic
                              ? "كل السيارات مجدولة تم التعامل معها أو لا توجد طلبات حالياً"
                              : "All scheduled departures are processed or no active requests today.",
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final item = state.queue[index];
                              return EmployeeCarCard(
                                item: item,
                                isArabic: isArabic,
                                onActionTap: () =>
                                    _openStatusSheet(context, item, isArabic),
                              );
                            },
                            childCount: state.queue.length,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, bool isArabic) {
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.statusReady,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'VALET OPERATIONS',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: AppColors.statusReady,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isArabic ? "جدول خروج اليوم" : "Today's Departure Queue",
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
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textSecondary,
                size: 22,
              ),
              onPressed: () =>
                  NotificationsSheet.show(context, isArabic: isArabic),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.textSecondary,
                size: 22,
              ),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiRow(dynamic summary, bool isArabic) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            label: isArabic ? "بالجراج" : "Inside",
            value: summary.totalInside.toString(),
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            label: isArabic ? "خلال ساعة" : "Next Hour",
            value: summary.leavingNextHour.toString(),
            color: AppColors.statusScheduled,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            label: isArabic ? "غسيل" : "Washes",
            value: summary.pendingWashes.toString(),
            color: AppColors.statusWashing,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            label: isArabic ? "جاهزة" : "Ready",
            value: summary.readyAtGate.toString(),
            color: AppColors.statusReady,
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard(
      {required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isArabic) {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: isArabic
            ? "بحث برقم اللوحة (أ ب ج)، اسم المالك أو الموقف..."
            : "Search by plate, owner name, or spot...",
        prefixIcon:
            const Icon(Icons.search_rounded, color: AppColors.textMuted),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  _searchController.clear();
                  context.read<EmployeeCubit>().search('');
                },
              )
            : null,
      ),
      onChanged: (val) {
        context.read<EmployeeCubit>().search(val);
      },
    );
  }

  Widget _buildFilterPills(String activeFilter, bool isArabic) {
    final filters = [
      {'key': 'all', 'ar': 'الكل', 'en': 'All'},
      {'key': 'upcoming', 'ar': 'قادمة', 'en': 'Upcoming'},
      {'key': 'washing', 'ar': 'غسيل', 'en': 'Washing'},
      {'key': 'ready', 'ar': 'عند البوابة', 'en': 'At Gate'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = activeFilter == f['key'];
          final label = isArabic ? f['ar']! : f['en']!;

          return GestureDetector(
            onTap: () => context.read<EmployeeCubit>().changeFilter(f['key']!),
            child: Container(
              margin: const EdgeInsets.only(right: 8, left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accentRoseSoft
                    : AppColors.surfaceInput,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryCrimson
                      : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.accentRoseText
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
