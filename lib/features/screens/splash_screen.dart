import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/common/index.dart';
import 'package:task_management/features/blocs/auth/index.dart';
import 'package:task_management/utility/navigation_helper.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {

        if (state is Authenticated) {
          NavigationHelper.goTo(context, dashboard);
        } else if (state is Unauthenticated) {
          NavigationHelper.goTo(context, login);
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            spacing: 24,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                logo,
                width: 100,
                height: 100,
                errorBuilder:
                    (context, error, stackTrace) => const Icon(
                      Icons.task_alt,
                      size: 100,
                      color: Colors.blue,
                    ),
              ),

              Text(
                'Task Manager',
                style: AppTextStyle.titleLarge(
                  context,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
