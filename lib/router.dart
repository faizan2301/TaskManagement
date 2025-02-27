import 'package:go_router/go_router.dart';
import 'package:task_management/features/screens/index.dart';

const String splashScreen = "/";
const String dashboard = "/dashboard";
const String login = "/login";
const String signup = "/signup";
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
      name: login,
    ),
  ],
);
