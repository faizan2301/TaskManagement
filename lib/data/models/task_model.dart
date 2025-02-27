import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final bool isCompleted;
  final DateTime createdAt;
  final String? remarks;
  final String userId;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.isCompleted,
    required this.createdAt,
    this.remarks,
    required this.userId,
  });

  // Copy with method for easy cloning with changes
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    bool? isCompleted,
    DateTime? createdAt,
    String? remarks,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      remarks: remarks ?? this.remarks,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'remarks': remarks,
      'userId': userId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      deadline: (map['deadline'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      remarks: map['remarks'],
      userId: map['userId'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    deadline,
    isCompleted,
    createdAt,
    remarks,
    userId,
  ];
}
