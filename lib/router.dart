import 'package:go_router/go_router.dart';
import 'package:task_management/features/screens/dashboard_screen.dart';
import 'package:task_management/features/screens/index.dart';

const String splashScreen = "/";
const String dashboard = "/dashboard";
const String login = "/login";
const String signup = "/signup";
const String tasks = "/tasks";
const String addTasks = "/addTasks";
const String taskDetail = "/taskDetails";
const String editTask = "/editTask";
final router = GoRouter(
  routerNeglect: false,
  initialLocation: splashScreen,

  routes: [
    GoRoute(
      path: splashScreen,
      builder: (context, state) => SplashScreen(),
      name: splashScreen,
    ),
    GoRoute(
      path: login,
      builder: (context, state) => LoginScreen(),
      name: login,
    ),
    GoRoute(
      path: signup,
      builder: (context, state) => SignupScreen(),
      name: signup,
    ),
    GoRoute(
      path: dashboard,
      builder: (context, state) => DashboardScreen(),
      name: dashboard,
    ),
    GoRoute(
      path: tasks,
      builder: (context, state) => TaskListScreen(),
      name: tasks,
    ),
    GoRoute(
      path: taskDetail,
      builder: (context, state) {
        String? taskId = state.extra.toString();
        return TaskDetailScreen(taskId: taskId);
      },
      name: taskDetail,
    ),
    GoRoute(
      path: addTasks,
      builder: (context, state) {
        return CreateEditTaskScreen();
      },
      name: addTasks,
    ),
    GoRoute(
      path: editTask,
      builder: (context, state) {
        String? taskId = state.extra.toString();
        return CreateEditTaskScreen(taskId: taskId);
      },
      name: editTask,
    ),
  ],
);