import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:task_management/common/index.dart';
import 'package:task_management/data/models/index.dart';
import 'package:task_management/features/blocs/auth/index.dart';
import 'package:task_management/features/blocs/task/index.dart';
class CreateEditTaskScreen extends StatefulWidget {
  final String? taskId;

  const CreateEditTaskScreen({super.key,    this.taskId,});

  @override
  State<CreateEditTaskScreen> createState() => _CreateEditTaskScreenState();
}

class _CreateEditTaskScreenState extends State<CreateEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isLoading = false;
  Task? _task;
  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      _loadTask();
    }
  }
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadTask() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = context.read<TaskRepository>();
      var task = await repository.getTask(widget.taskId!);

      if (task != null) {
        setState(() {
          _task = task;
          _titleController.text = task.title;
          _descriptionController.text = task.description;
          _selectedDate = task.deadline;
        });
      }
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthBloc>().state;

      if (authState is Authenticated) {
        if (_task != null) {
          // Update existing task
          final updatedTask = _task!.copyWith(
            title: _titleController.text,
            description: _descriptionController.text,
            deadline: _selectedDate,
          );

          context.read<TaskBloc>().add(UpdateTask(updatedTask));
        } else {
          // Create new task
          context.read<TaskBloc>().add(CreateTask(
            title: _titleController.text,
            description: _descriptionController.text,
            deadline: _selectedDate,
            userId: authState.user.id,
          ));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.taskId != null ? "Edit Task" : "Create Task",
      ),
      body: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            NavigationHelper.goTo(context, tasks);
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
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Deadline',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: state is TaskLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: state is TaskLoading
                          ? const CircularProgressIndicator()
                          : Text(
                        widget.taskId != null ? "Update Task" : "Create Task",
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}