import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:task_management/data/models/index.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TasksLoaded extends TaskState {
  final List<Task> tasks;
  final DocumentSnapshot? lastDocument;
  final bool hasReachedMax;

  TasksLoaded({
    required this.tasks,
    this.lastDocument,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [tasks, lastDocument, hasReachedMax];

  TasksLoaded copyWith({
    List<Task>? tasks,
    DocumentSnapshot? lastDocument,
    bool? hasReachedMax,
  }) {
    return TasksLoaded(
      tasks: tasks ?? this.tasks,
      lastDocument: lastDocument ?? this.lastDocument,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class TaskOperationSuccess extends TaskState {
  final String message;

  TaskOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class TaskFailure extends TaskState {
  final String message;

  TaskFailure(this.message);

  @override
  List<Object> get props => [message];
}
