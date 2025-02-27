import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/index.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;
  final uuid = const Uuid();

  TaskRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _tasksCollection => _firestore.collection('tasks');

  Future<Task> createTask({
    required String title,
    required String description,
    required DateTime deadline,
    required String userId,
  }) async {
    final String id = uuid.v4();
    final Task task = Task(
      id: id,
      title: title,
      description: description,
      deadline: deadline,
      isCompleted: false,
      createdAt: DateTime.now(),
      userId: userId,
    );

    await _tasksCollection.doc(id).set(task.toMap());
    return task;
  }

  Future<List<Task>> getTasks({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCompleted,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    Query query = _tasksCollection.where('userId', isEqualTo: userId);

    if (startDate != null) {
      query = query.where(
        'deadline',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      query = query.where(
        'deadline',
        isLessThanOrEqualTo: Timestamp.fromDate(
          endDate.add(const Duration(days: 1)),
        ),
      );
    }

    if (isCompleted != null) {
      query = query.where('isCompleted', isEqualTo: isCompleted);
    }

    query = query.orderBy('createdAt', descending: true);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    query = query.limit(limit);

    final QuerySnapshot snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, int>> getTaskCounts(String userId) async {
    final QuerySnapshot totalSnapshot =
        await _tasksCollection.where('userId', isEqualTo: userId).get();

    final QuerySnapshot completedSnapshot =
        await _tasksCollection
            .where('userId', isEqualTo: userId)
            .where('isCompleted', isEqualTo: true)
            .get();

    final int total = totalSnapshot.docs.length;
    final int completed = completedSnapshot.docs.length;
    final int pending = total - completed;

    return {'total': total, 'completed': completed, 'pending': pending};
  }

  Future<Task?> getTask(String taskId) async {
    final DocumentSnapshot doc = await _tasksCollection.doc(taskId).get();
    if (!doc.exists) {
      return null;
    }
    return Task.fromMap(doc.data() as Map<String, dynamic>);
  }

  Future<Task> updateTask(Task task) async {
    await _tasksCollection.doc(task.id).update(task.toMap());
    return task;
  }

  Future<Task> completeTask({
    required String taskId,
    required String remarks,
  }) async {
    final DocumentSnapshot doc = await _tasksCollection.doc(taskId).get();
    if (!doc.exists) {
      throw Exception('Task not found');
    }

    final Task task = Task.fromMap(doc.data() as Map<String, dynamic>);
    final Task updatedTask = task.copyWith(isCompleted: true, remarks: remarks);

    await _tasksCollection.doc(taskId).update(updatedTask.toMap());
    return updatedTask;
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksCollection.doc(taskId).delete();
  }
}
