import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/common/index.dart';
import 'package:task_management/data/models/index.dart';
import 'package:task_management/features/blocs/auth/index.dart';
import 'package:task_management/features/blocs/dashboard/index.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    _loadDashboardData();
    super.initState();
  }

  void _loadDashboardData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<DashboardBloc>().add(FetchDashboardStats(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Dashboard",
        actions: [
          IconButton(
            onPressed: () async {
              context.read<AuthBloc>().add(SignOutRequested());
              NavigationHelper.goTo(context, login);
            },
            icon: Icon(Icons.logout, color: Colors.red),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              final UserModel user = authState.user;
              return BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is DashboardLoaded) {
                    return _buildDashboard(context, user, state);
                  } else if (state is DashboardFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${state.message}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadDashboardData,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Welcome to Task Manager'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadDashboardData,
                            child: const Text('Load Dashboard'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    UserModel user,
    DashboardLoaded state,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadDashboardData();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          user.photoUrl != null
                              ? NetworkImage(user.photoUrl!)
                              : null,
                      child:
                          user.photoUrl == null
                              ? const Icon(Icons.person, size: 30)
                              : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName ?? 'User',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Task Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TaskCountCard(
                    title: 'Total Tasks',
                    count: state.totalTasks,
                    icon: Icons.assignment,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TaskCountCard(
                    title: 'Completed',
                    count: state.completedTasks,
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TaskCountCard(
                    title: 'Pending',
                    count: state.pendingTasks,
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => NavigationHelper.pushTo(context, tasks),
                    child: const TaskCountCard(
                      title: 'View All',
                      count: null,
                      icon: Icons.arrow_forward,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => NavigationHelper.pushTo(context, addTasks),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Add New Task'),
            ),
          ],
        ),
      ),
    );
  }
}