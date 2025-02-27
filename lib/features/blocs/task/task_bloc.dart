import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:task_management/data/repositories/task_repository.dart';
import 'package:task_management/features/blocs/task/task_events.dart';
import 'package:task_management/features/blocs/task/task_states.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _taskRepository;

  TaskBloc({required TaskRepository taskRepository})
    : _taskRepository = taskRepository,
      super(TaskInitial()) {
    on<FetchTasks>(_onFetchTasks);
    on<CreateTask>(_onCreateTask);
    on<UpdateTask>(_onUpdateTask);
    on<CompleteTask>(_onCompleteTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _onFetchTasks(FetchTasks event, Emitter<TaskState> emit) async {
    try {
      if (event.lastDocument == null) {
        emit(TaskLoading());
      }
      final int fetchLimit = 10;
      final tasks = await _taskRepository.getTasks(
        userId: event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
        isCompleted: event.isCompleted,
        lastDocument: event.lastDocument,
      );

      DocumentSnapshot? lastDoc;
      if (tasks.isNotEmpty) {
        final QuerySnapshot snapshot =
            await _taskRepository.tasksCollection
                .where('id', isEqualTo: tasks.last.id)
                .limit(1)
                .get();

        if (snapshot.docs.isNotEmpty) {
          lastDoc = snapshot.docs.first;
        }
      }
      bool hasReachedMax = tasks.isEmpty || tasks.length < fetchLimit;
      if (state is TasksLoaded && event.lastDocument != null) {
        final currentState = state as TasksLoaded;
        emit(
          currentState.copyWith(
            tasks: [...currentState.tasks, ...tasks],
            lastDocument: tasks.isEmpty ? null : lastDoc,
            hasReachedMax: hasReachedMax,
          ),
        );
      } else {
        emit(
          TasksLoaded(
            tasks: tasks,
            lastDocument: tasks.isEmpty ? null : lastDoc,
            hasReachedMax: hasReachedMax,
          ),
        );
      }
    } catch (e) {
      emit(TaskFailure(e.toString()));
    }
  }

  Future<void> _onCreateTask(CreateTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await _taskRepository.createTask(
        title: event.title,
        description: event.description,
        deadline: event.deadline,
        userId: event.userId,
      );
      emit(TaskOperationSuccess('Task created successfully'));
    } catch (e) {
      emit(TaskFailure(e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await _taskRepository.updateTask(event.task);
      emit(TaskOperationSuccess('Task updated successfully'));
    } catch (e) {
      emit(TaskFailure(e.toString()));
    }
  }

  Future<void> _onCompleteTask(
    CompleteTask event,
    Emitter<TaskState> emit,
  ) async {
    emit(TaskLoading());
    try {
      await _taskRepository.completeTask(
        taskId: event.taskId,
        remarks: event.remarks,
      );
      emit(TaskOperationSuccess('Task marked as completed'));
    } catch (e) {
      emit(TaskFailure(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      await _taskRepository.deleteTask(event.taskId);
      emit(TaskOperationSuccess('Task deleted successfully'));
    } catch (e) {
      emit(TaskFailure(e.toString()));
    }
  }
}