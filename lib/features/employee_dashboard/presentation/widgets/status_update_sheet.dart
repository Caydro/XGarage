import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/queue_item_entity.dart';

class StatusUpdateSheet extends StatefulWidget {
  final QueueItemEntity item;
  final bool isArabic;
  final Function(String status, String? washStatus, String? notes) onUpdateStatus;
  final Function(String spot, String? keyHook) onUpdateSpot;

  const StatusUpdateSheet({
    super.key,
    required this.item,
    required this.isArabic,
    required this.onUpdateStatus,
    required this.onUpdateSpot,
  });

  @override
  State<StatusUpdateSheet> createState() => _StatusUpdateSheetState();
}

class _StatusUpdateSheetState extends State<StatusUpdateSheet> {
  late TextEditingController _spotController;
  late TextEditingController _keyHookController;
  late TextEditingController _notesController;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _spotController = TextEditingController(text: widget.item.parkingSpot ?? '');
    _keyHookController = TextEditingController(text: widget.item.keyHookNumber ?? '');
    _notesController = TextEditingController();
    _currentStatus = widget.item.currentStatus;
  }

  @override
  void dispose() {
    _spotController.dispose();
    _keyHookController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 16),
            Text(
              widget.isArabic
                  ? "تحديث حالة السيارة وموقع الركن"
                  : "Update Vehicle Status & Parking Spot",
              style: AppTypography.getHeading2(isArabic: widget.isArabic),
            ),
            Text(
              '${widget.item.vehicleTitle} • ${widget.item.plateLetters} ${widget.item.plateNumbers}',
              style: AppTypography.getCaption(isArabic: widget.isArabic),
            ),
            const SizedBox(height: 20),

            // Spot & Key Hook Inputs
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _spotController,
                    decoration: InputDecoration(
                      labelText: widget.isArabic ? "رقم الموقف (مثل B2-14)" : "Parking Spot (e.g. B2-14)",
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _keyHookController,
                    decoration: InputDecoration(
                      labelText: widget.isArabic ? "علاقة المفتاح (Hook #12)" : "Key Hook #",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  widget.onUpdateSpot(
                    _spotController.text.trim(),
                    _keyHookController.text.trim().isEmpty ? null : _keyHookController.text.trim(),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(widget.isArabic ? "تم تحديث الموقف" : "Spot updated"),
                      backgroundColor: AppColors.statusReady,
                    ),
                  );
                },
                child: Text(
                  widget.isArabic ? "حفظ الموقف والمفتاح" : "Save Spot & Key",
                  style: const TextStyle(color: AppColors.accentRoseText, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const Divider(color: Colors.white12, height: 24),

            // Status Progression Buttons
            Text(
              widget.isArabic ? "تغيير مرحلة السيارة:" : "Progress Vehicle Status:",
              style: AppTypography.getHeading3(isArabic: widget.isArabic),
            ),
            const SizedBox(height: 12),

            _buildStatusOption(
              status: 'parked',
              label: widget.isArabic ? "متوقفة في الموقف" : "Parked in Spot",
              icon: Icons.local_parking_rounded,
              color: Colors.white70,
            ),
            const SizedBox(height: 8),

            _buildStatusOption(
              status: 'washing',
              label: widget.isArabic ? "بدء الغسيل في المحطة" : "Start Washing in Bay",
              icon: Icons.local_car_wash_rounded,
              color: AppColors.statusWashing,
            ),
            const SizedBox(height: 8),

            _buildStatusOption(
              status: 'ready_at_gate',
              label: widget.isArabic ? "جاهزة عند بوابة الخروج" : "Ready at Exit Gate",
              icon: Icons.check_circle_rounded,
              color: AppColors.statusReady,
            ),
            const SizedBox(height: 8),

            _buildStatusOption(
              status: 'checked_out',
              label: widget.isArabic ? "خرجت من الجراج (تسليم العميل)" : "Checked Out / Left Garage",
              icon: Icons.exit_to_app_rounded,
              color: AppColors.statusScheduled,
            ),
            const SizedBox(height: 20),

            // Optional Notes
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: widget.isArabic ? "ملاحظة تدقيق (اختياري)" : "Audit note (optional)",
              ),
            ),
            const SizedBox(height: 20),

            AppButton(
              text: widget.isArabic ? "تطبيق الحالة الجديدة" : "Apply New Status",
              onPressed: () {
                String? washStatus;
                if (_currentStatus == 'washing') washStatus = 'in_progress';
                if (_currentStatus == 'ready_at_gate') washStatus = 'completed';

                widget.onUpdateStatus(
                  _currentStatus,
                  washStatus,
                  _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                );
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption({
    required String status,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _currentStatus == status;

    return GestureDetector(
      onTap: () => setState(() => _currentStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentRoseSoft : AppColors.surfaceInput,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryCrimson : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, color: AppColors.primaryCrimson, size: 20),
          ],
        ),
      ),
    );
  }
}
