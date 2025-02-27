import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/common/index.dart';
import 'package:task_management/features/blocs/auth/auth_bloc.dart';
import 'package:task_management/features/blocs/auth/auth_events.dart';
import 'package:task_management/features/blocs/dashboard/dashboard_bloc.dart';
import 'package:task_management/features/blocs/task/index.dart';
import 'package:task_management/firebase_options.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserPreferences.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final taskRepository = TaskRepository();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: taskRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) =>
                    AuthBloc(authRepository: authRepository)..add(AppStarted()),
          ),
          BlocProvider(
            create: (context) => TaskBloc(taskRepository: taskRepository),
          ),
          BlocProvider(
            create: (context) => DashboardBloc(taskRepository: taskRepository),
          ),
        ],
        child: TaskManagerApp(),
      ),
    );
  }
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Task management',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
