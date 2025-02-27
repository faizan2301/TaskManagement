import 'dart:async';
import 'package:task_management/common/index.dart';
import 'package:task_management/data/models/index.dart';
import 'package:bloc/bloc.dart';
import 'package:task_management/data/repositories/auth_repository.dart';
import 'package:task_management/features/blocs/auth/auth_events.dart';
import 'package:task_management/features/blocs/auth/auth_states.dart';
import 'package:flutter/material.dart';
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription? _authSubscription;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _checkAndUpdateAuthStatus(emit);
      _authSubscription?.cancel();
      _authSubscription = _authRepository.isSignedIn.listen((isSignedIn) async {
        if (!isSignedIn && state is Authenticated) {
          debugPrint("⚡️ AuthBloc: User signed out from Firebase");
          add(SignOutRequested());
        } else if (isSignedIn) {
          debugPrint("⚡️ AuthBloc: User signed in to Firebase");
          add(CheckAuthStatus());
        }
      });
    } catch (e) {

      emit(AuthFailure(e.toString()));
    }
  }
  Future<void> _checkAndUpdateAuthStatus(Emitter<AuthState> emit) async {
    // First check SharedPreferences (prioritize this)
    bool isAuthenticated = await _authRepository.isAuthenticatedFromPrefs();
    debugPrint("⚡️ AuthBloc: isAuthenticated from prefs: $isAuthenticated");

    if (isAuthenticated) {
      // Get user from preferences
      UserModel? prefsUser = await _authRepository.getUserFromPrefs();
      debugPrint("⚡️ AuthBloc: User from prefs: $prefsUser");

      if (prefsUser != null) {
        debugPrint("✅ AuthBloc: User authenticated via SharedPreferences");
        emit(Authenticated(prefsUser));
        return;
      }
    }

    // Only if not authenticated in prefs, check Firebase
    UserModel? firebaseUser = _authRepository.getFirebaseCurrentUser();
    debugPrint("⚡️ AuthBloc: Firebase current user: $firebaseUser");

    if (firebaseUser != null) {
      debugPrint("✅ AuthBloc: User authenticated via Firebase");
      // Save to prefs for next time
      await _authRepository.saveUserToPrefs(firebaseUser);
      emit(Authenticated(firebaseUser));
      return;
    }

    debugPrint("❌ AuthBloc: User is not authenticated");
    emit(Unauthenticated());
  }
  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signUp(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(Unauthenticated());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

}