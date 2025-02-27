import 'package:equatable/equatable.dart';

abstract class DashboardState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;

  DashboardLoaded({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
  });

  @override
  List<Object> get props => [totalTasks, completedTasks, pendingTasks];
}

class DashboardFailure extends DashboardState {
  final String message;

  DashboardFailure(this.message);

  @override
  List<Object> get props => [message];
}
