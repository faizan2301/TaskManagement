import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchDashboardStats extends DashboardEvent {
  final String userId;

  FetchDashboardStats(this.userId);

  @override
  List<Object> get props => [userId];
}
