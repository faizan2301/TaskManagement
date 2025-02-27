import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
      appBar: CustomAppBar(title: "Dashboard", showBackButton: true),
      body: SafeArea(child: BlocBuilder<AuthBloc, AuthState>(builder: (context, authState) {
        // final UserModel user = authState.user;
        return BlocBuilder<DashboardBloc, DashboardState>(builder: (context, state) {

        },)
      },),),
    );
  }
}
