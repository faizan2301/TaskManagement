import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_management/common/index.dart';
import 'package:task_management/features/blocs/auth/index.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        SignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Login"),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });

            if (state is Authenticated) {
              NavigationHelper.goTo(context, dashboard);
            } else if (state is AuthFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 32,
                      children: [
                        Text(
                          'Task Manager',
                          textAlign: TextAlign.center,
                          style: AppTextStyle.displayLarge(context),
                        ),
                        AppTextFormField(
                          label: "Email",
                          controller: _emailController,
                          validator: (value) => validateEmail(value!),
                          textCapitalization: TextCapitalization.none,
                          keyboardType: TextInputType.emailAddress,
                          autoFillHints: [AutofillHints.email],
                        ),
                        AppTextFormField(
                          label: "Password",
                          controller: _passwordController,
                          validator: (value) => validatePassword(value!),
                          obscureText: true,
                          autoFillHints: [AutofillHints.password],
                        ),
                        AppButton(
                          text: "Login",
                          onPressed: _submitForm,
                          isLoading: _isLoading,
                        ),
                        TextButton(
                          onPressed:
                              () => NavigationHelper.goTo(context, signup),
                          child: const Text('Don\'t have an account? Sign Up'),
                        ),
                         Text(
                          'OR',
                          textAlign: TextAlign.center,
                          style: AppTextStyle.titleMedium(context),
                        ),
                        OutlinedButton.icon(
                          icon: Image.network(
                            'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.ac_unit),
                          ),
                          label: const Text('Sign in with Google'),
                          onPressed: () {
                            context.read<AuthBloc>().add(GoogleSignInRequested());
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
