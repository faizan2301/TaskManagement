import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/common/index.dart';
import 'package:task_management/data/models/index.dart';
import 'package:task_management/features/blocs/auth/index.dart';
import 'package:task_management/features/blocs/task/index.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final _scrollController = ScrollController();
  String? _userId;
  bool? _filterCompleted;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTasks();
  }

  void _onScroll() {
    if (_isBottom) _loadMoreTasks();
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _loadTasks() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _userId = authState.user.id;
      context.read<TaskBloc>().add(
        FetchTasks(userId: _userId!, isCompleted: _filterCompleted),
      );
    }
  }

  void _loadMoreTasks() {
    final taskState = context.read<TaskBloc>().state;
    if (taskState is TasksLoaded &&
        !taskState.hasReachedMax &&
        _userId != null) {
      context.read<TaskBloc>().add(
        FetchTasks(
          userId: _userId!,
          isCompleted: _filterCompleted,
          lastDocument: taskState.lastDocument,
        ),
      );
    }
  }

  void _onFilterChanged(bool? completed) {
    setState(() {
      _filterCompleted = completed;
    });
    _loadTasks();
  }

  void _completeTask(String taskId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Complete Task'),
            content: TextField(
              decoration: const InputDecoration(
                labelText: 'Remarks (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onSubmitted: (remarks) {
                context.read<TaskBloc>().add(
                  CompleteTask(taskId: taskId, remarks: remarks),
                );
                Navigator.pop(context);
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final renderBox = context.findRenderObject() as RenderBox;
                  final ancestorRenderBox =
                      context
                          .findAncestorRenderObjectOfType<
                            RenderBox
                          >(); // usually from your TextField
                  final remarksOffset = renderBox.localToGlobal(
                    Offset.zero,
                    ancestor: ancestorRenderBox,
                  );
                  context.read<TaskBloc>().add(
                    CompleteTask(
                      taskId: taskId,
                      remarks: remarksOffset.toString(),
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Complete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Tasks",
        actions: [
          PopupMenuButton<bool?>(
            icon: const Icon(Icons.filter_list),
            onSelected: _onFilterChanged,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: null, child: Text('All Tasks')),
                  const PopupMenuItem(
                    value: false,
                    child: Text('Pending Tasks'),
                  ),
                  const PopupMenuItem(
                    value: true,
                    child: Text('Completed Tasks'),
                  ),
                ],
          ),
        ],
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            // Reload tasks after successful operation
            _loadTasks();
          } else if (state is TaskFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskLoading &&
              (context.read<TaskBloc>().state is! TasksLoaded)) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TasksLoaded ||
              (state is TaskLoading &&
                  context.read<TaskBloc>().state is TasksLoaded)) {
            final loadedState =
                (state is TasksLoaded)
                    ? state
                    : context.read<TaskBloc>().state as TasksLoaded;

            if (loadedState.tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No tasks found'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => NavigationHelper.pushTo(context, addTasks),
                      child: const Text('Create New Task'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadTasks();
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount:
                    loadedState.tasks.length +
                    (loadedState.hasReachedMax ? 0 : 1),
                itemBuilder: (context, index) {
                  if (index >= loadedState.tasks.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final task = loadedState.tasks[index];
                  return _buildTaskItem(context, task);
                },
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Something went wrong'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTasks,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => NavigationHelper.pushTo(context, addTasks),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    return Dismissible(
      key: Key(task.id),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.check, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd && !task.isCompleted) {
          // Complete task
          _completeTask(task.id);
          return false; // Don't dismiss yet, wait for confirmation
        } else if (direction == DismissDirection.endToStart) {
          // Delete task
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Delete Task"),
                content: const Text(
                  "Are you sure you want to delete this task?",
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      "Delete",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          context.read<TaskBloc>().add(DeleteTask(task.id));
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: _isTaskOverdue(task) ? Colors.red : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.deadline.day}/${task.deadline.month}/${task.deadline.year}',
                    style: TextStyle(
                      color: _isTaskOverdue(task) ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
              if (task.isCompleted && task.remarks != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'Remarks: ${task.remarks}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ),
          trailing:
              task.isCompleted
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed:
                        () => NavigationHelper.pushTo(
                          context,
                          editTask,
                          extra: task.id,
                        ),
                  ),
          onTap: () => NavigationHelper.pushTo(context, taskDetail, extra: task.id,),
        ),
      ),
    );
  }

  bool _isTaskOverdue(Task task) {
    return !task.isCompleted &&
        task.deadline.isBefore(
          DateTime.now().subtract(const Duration(days: 1)),
        );
  }
}