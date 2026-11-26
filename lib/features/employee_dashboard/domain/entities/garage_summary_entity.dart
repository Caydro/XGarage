import 'package:equatable/equatable.dart';

class GarageSummaryEntity extends Equatable {
  final int totalInside;
  final int leavingNextHour;
  final int pendingWashes;
  final int readyAtGate;

  const GarageSummaryEntity({
    required this.totalInside,
    required this.leavingNextHour,
    required this.pendingWashes,
    required this.readyAtGate,
  });

  @override
  List<Object?> get props => [
        totalInside,
        leavingNextHour,
        pendingWashes,
        readyAtGate,
      ];
}
