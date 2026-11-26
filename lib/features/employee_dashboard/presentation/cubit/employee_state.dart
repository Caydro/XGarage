import 'package:equatable/equatable.dart';
import '../../domain/entities/garage_summary_entity.dart';
import '../../domain/entities/queue_item_entity.dart';

sealed class EmployeeState extends Equatable {
  const EmployeeState();

  @override
  List<Object?> get props => [];
}

class EmployeeInitial extends EmployeeState {}

class EmployeeLoading extends EmployeeState {}

class EmployeeLoaded extends EmployeeState {
  final List<QueueItemEntity> queue;
  final GarageSummaryEntity summary;
  final String activeFilter; // all, upcoming, washing, ready
  final String searchQuery;

  const EmployeeLoaded({
    required this.queue,
    required this.summary,
    this.activeFilter = 'all',
    this.searchQuery = '',
  });

  EmployeeLoaded copyWith({
    List<QueueItemEntity>? queue,
    GarageSummaryEntity? summary,
    String? activeFilter,
    String? searchQuery,
  }) {
    return EmployeeLoaded(
      queue: queue ?? this.queue,
      summary: summary ?? this.summary,
      activeFilter: activeFilter ?? this.activeFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [queue, summary, activeFilter, searchQuery];
}

class EmployeeError extends EmployeeState {
  final String message;

  const EmployeeError(this.message);

  @override
  List<Object?> get props => [message];
}
