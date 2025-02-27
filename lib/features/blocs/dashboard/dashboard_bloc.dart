import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:task_management/data/repositories/task_repository.dart';
import 'package:task_management/features/blocs/dashboard/dashboard_events.dart';
import 'package:task_management/features/blocs/dashboard/dashboard_states.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TaskRepository _taskRepository;

  DashboardBloc({required TaskRepository taskRepository})
    : _taskRepository = taskRepository,
      super(DashboardInitial()) {
    on<FetchDashboardStats>(_onFetchDashboardStats);
  }

  Future<void> _onFetchDashboardStats(
    FetchDashboardStats event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final counts = await _taskRepository.getTaskCounts(event.userId);
      emit(
        DashboardLoaded(
          totalTasks: counts['total'] ?? 0,
          completedTasks: counts['completed'] ?? 0,
          pendingTasks: counts['pending'] ?? 0,
        ),
      );
    } catch (e) {
      emit(DashboardFailure(e.toString()));
    }
  }
}
