import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_management/common/index.dart';
import 'package:task_management/data/models/index.dart';
import 'package:task_management/features/blocs/task/index.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Task? _task;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = context.read<TaskRepository>();
      final task = await repository.getTask(widget.taskId);

      setState(() {
        _task = task;
      });
    } catch (e) {
      if(context.mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading task: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _completeTask() {
    showDialog(
      context: context,
      builder: (context) {
        String remarks = '';
        return AlertDialog(
          title: const Text('Complete Task'),
          content: TextField(
            decoration: const InputDecoration(
              labelText: 'Remarks (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) {
              remarks = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<TaskBloc>().add(CompleteTask(
                  taskId: widget.taskId,
                  remarks: remarks,
                ));
                Navigator.pop(context);
              },
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Task"),
        content: const Text("Are you sure you want to delete this task?"),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<TaskBloc>().add(DeleteTask(widget.taskId));
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Task Details",
        actions: [
          if (_task != null && !_task!.isCompleted)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => NavigationHelper.pushTo(context, editTask,extra: widget.taskId),
            ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteTask,
          ),
        ],
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            if (state.message.contains('deleted')) {
              NavigationHelper.goTo(context, tasks);
            } else {
              _loadTask(); // Reload task after update
            }
          } else if (state is TaskFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _task == null
            ? const Center(child: Text('Task not found'))
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _task!.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _task!.isCompleted
                                  ? Colors.green
                                  : _isTaskOverdue(_task!)
                                  ? Colors.red
                                  : Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _task!.isCompleted
                                  ? 'Completed'
                                  : _isTaskOverdue(_task!)
                                  ? 'Overdue'
                                  : 'Pending',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Description:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _task!.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(
                            'Deadline: ${DateFormat('dd MMM yyyy').format(_task!.deadline)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: _isTaskOverdue(_task!) && !_task!.isCompleted
                                  ? Colors.red
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 8),
                          Text(
                            'Created: ${DateFormat('dd MMM yyyy').format(_task!.createdAt)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      if (_task!.isCompleted && _task!.remarks != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Completion Remarks:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _task!.remarks!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (!_task!.isCompleted)
                ElevatedButton(
                  onPressed: _completeTask,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Mark as Completed'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isTaskOverdue(Task task) {
    return !task.isCompleted &&
        task.deadline.isBefore(DateTime.now().subtract(const Duration(days: 1)));
  }
}