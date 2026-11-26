import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/employee_repository.dart';
import 'employee_state.dart';

class EmployeeCubit extends Cubit<EmployeeState> {
  final EmployeeRepository _repository;

  EmployeeCubit(this._repository) : super(EmployeeInitial());

  Future<void> loadQueue({String? filter, String? search, bool isInitial = false}) async {
    final currentFilter = filter ?? (state is EmployeeLoaded ? (state as EmployeeLoaded).activeFilter : 'all');
    final currentSearch = search ?? (state is EmployeeLoaded ? (state as EmployeeLoaded).searchQuery : '');

    // Only emit full loading on initial cold load to avoid wiping the UI on live updates
    if (state is EmployeeInitial || isInitial) {
      emit(EmployeeLoading());
    }
    try {
      final queue = await _repository.getQueue(filter: currentFilter, search: currentSearch);
      final summary = await _repository.getSummary();

      if (isClosed) return;
      emit(EmployeeLoaded(
        queue: queue,
        summary: summary,
        activeFilter: currentFilter,
        searchQuery: currentSearch,
      ));
    } catch (e) {
      if (isClosed) return;
      if (state is! EmployeeLoaded) {
        emit(EmployeeError(e.toString()));
      }
    }
  }

  Future<void> changeFilter(String newFilter) async {
    final search = state is EmployeeLoaded ? (state as EmployeeLoaded).searchQuery : null;
    await loadQueue(filter: newFilter, search: search, isInitial: false);
  }

  Future<void> search(String query) async {
    final filter = state is EmployeeLoaded ? (state as EmployeeLoaded).activeFilter : 'all';
    await loadQueue(filter: filter, search: query, isInitial: false);
  }

  Future<void> updateSpot({
    required int vehicleId,
    required String spot,
    String? keyHook,
  }) async {
    try {
      await _repository.updateSpot(
        vehicleId: vehicleId,
        spot: spot,
        keyHook: keyHook,
      );
      if (isClosed) return;
      await loadQueue(isInitial: false);
    } catch (e) {
      if (isClosed) return;
      if (state is! EmployeeLoaded) {
        emit(EmployeeError(e.toString()));
      }
      rethrow;
    }
  }

  Future<void> updateStatus({
    required int vehicleId,
    required String status,
    String? washStatus,
    String? notes,
  }) async {
    try {
      await _repository.updateStatus(
        vehicleId: vehicleId,
        status: status,
        washStatus: washStatus,
        notes: notes,
      );
      if (isClosed) return;
      await loadQueue(isInitial: false);
    } catch (e) {
      if (isClosed) return;
      if (state is! EmployeeLoaded) {
        emit(EmployeeError(e.toString()));
      }
      rethrow;
    }
  }
}
