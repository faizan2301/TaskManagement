import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:task_management/data/models/index.dart';
abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchTasks extends TaskEvent {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isCompleted;
  final DocumentSnapshot? lastDocument;

  FetchTasks({
    required this.userId,
    this.startDate,
    this.endDate,
    this.isCompleted,
    this.lastDocument,
  });

  @override
  List<Object?> get props => [
    userId,
    startDate,
    endDate,
    isCompleted,
    lastDocument,
  ];
}

class CreateTask extends TaskEvent {
  final String title;
  final String description;
  final DateTime deadline;
  final String userId;

  CreateTask({
    required this.title,
    required this.description,
    required this.deadline,
    required this.userId,
  });

  @override
  List<Object> get props => [title, description, deadline, userId];
}

class UpdateTask extends TaskEvent {
  final Task task;

  UpdateTask(this.task);

  @override
  List<Object> get props => [task];
}

class CompleteTask extends TaskEvent {
  final String taskId;
  final String remarks;

  CompleteTask({
    required this.taskId,
    required this.remarks,
  });

  @override
  List<Object> get props => [taskId, remarks];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  DeleteTask(this.taskId);

  @override
  List<Object> get props => [taskId];
}