import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/license_plate_badge.dart';

class AddVehicleSheet extends StatefulWidget {
  final bool isArabic;
  final Function({
    required String make,
    required String model,
    int? year,
    required String colorName,
    required String colorHex,
    required String plateLetters,
    required String plateNumbers,
    String? specialNotes,
  }) onAdd;

  const AddVehicleSheet({
    super.key,
    required this.isArabic,
    required this.onAdd,
  });

  @override
  State<AddVehicleSheet> createState() => _AddVehicleSheetState();
}

class _AddVehicleSheetState extends State<AddVehicleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController(text: '2024');
  final _plateLettersController = TextEditingController(text: 'أ ب ج');
  final _plateNumbersController = TextEditingController(text: '١٢٣٤');
  final _notesController = TextEditingController();

  String _selectedColorName = 'Obsidian Black';
  String _selectedColorHex = '#0F0E13';

  final List<Map<String, String>> _colors = [
    {'name': 'Obsidian Black', 'hex': '#0F0E13'},
    {'name': 'Pearl White', 'hex': '#F8FAFC'},
    {'name': 'Daytona Gray', 'hex': '#4B5563'},
    {'name': 'Crimson Ruby', 'hex': '#991B1B'},
    {'name': 'Deep Navy', 'hex': '#1E3A8A'},
    {'name': 'Emerald Green', 'hex': '#065F46'},
  ];

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateLettersController.dispose();
    _plateNumbersController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Color _parseHex(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return Colors.black;
    }
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
      child: Form(
        key: _formKey,
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
              const SizedBox(height: 18),
              Text(
                widget.isArabic ? "إضافة سيارة جديدة للجراج" : "Add New Vehicle",
                style: AppTypography.getHeading2(isArabic: widget.isArabic),
              ),
              const SizedBox(height: 16),

              // Live Plate Preview
              Center(
                child: ValueListenableBuilder(
                  valueListenable: _plateLettersController,
                  builder: (context, _, __) {
                    return ValueListenableBuilder(
                      valueListenable: _plateNumbersController,
                      builder: (context, _, __) {
                        return LicensePlateBadge(
                          letters: _plateLettersController.text.isEmpty ? 'أ ب ج' : _plateLettersController.text,
                          numbers: _plateNumbersController.text.isEmpty ? '١٢٣٤' : _plateNumbersController.text,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Make & Model Row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _makeController,
                      decoration: InputDecoration(
                        labelText: widget.isArabic ? "الماركة (مثل Mercedes)" : "Make (e.g. Mercedes)",
                      ),
                      validator: (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _modelController,
                      decoration: InputDecoration(
                        labelText: widget.isArabic ? "الموديل (مثل C200)" : "Model (e.g. C200)",
                      ),
                      validator: (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: widget.isArabic ? "السنة" : "Year",
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Plate letters & numbers Row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _plateLettersController,
                      decoration: InputDecoration(
                        labelText: widget.isArabic ? "حروف اللوحة (أ ب ج)" : "Plate Letters",
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _plateNumbersController,
                      decoration: InputDecoration(
                        labelText: widget.isArabic ? "أرقام اللوحة (١٢٣٤)" : "Plate Numbers",
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (v) => v == null || v.isEmpty ? "Required" : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Color Swatches
              Text(
                widget.isArabic ? "لون السيارة للتعرف السريع" : "Vehicle Color",
                style: AppTypography.getHeading3(isArabic: widget.isArabic),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _colors.map((c) {
                  final isSelected = _selectedColorHex == c['hex'];
                  final col = _parseHex(c['hex']!);
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedColorName = c['name']!;
                      _selectedColorHex = c['hex']!;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceInput,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryCrimson : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: col,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white70),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            c['name']!,
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Special Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: widget.isArabic
                      ? "ملاحظات هامة للسايس (مثل: ممتص الصدمات منخفض، طي المرايات)"
                      : "Valet handling notes (e.g. low bumper, fold mirrors)",
                ),
              ),
              const SizedBox(height: 24),

              AppButton(
                text: widget.isArabic ? "حفظ السيارة" : "Save Vehicle",
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onAdd(
                      make: _makeController.text.trim(),
                      model: _modelController.text.trim(),
                      year: int.tryParse(_yearController.text.trim()),
                      colorName: _selectedColorName,
                      colorHex: _selectedColorHex,
                      plateLetters: _plateLettersController.text.trim(),
                      plateNumbers: _plateNumbersController.text.trim(),
                      specialNotes: _notesController.text.trim(),
                    );
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
