import '../../domain/entities/garage_summary_entity.dart';

class GarageSummaryModel extends GarageSummaryEntity {
  const GarageSummaryModel({
    required super.totalInside,
    required super.leavingNextHour,
    required super.pendingWashes,
    required super.readyAtGate,
  });

  factory GarageSummaryModel.fromJson(Map<String, dynamic> json) {
    return GarageSummaryModel(
      totalInside: json['total_inside'] as int? ?? 0,
      leavingNextHour: json['leaving_next_hour'] as int? ?? 0,
      pendingWashes: json['pending_washes'] as int? ?? 0,
      readyAtGate: json['ready_at_gate'] as int? ?? 0,
    );
  }
}
