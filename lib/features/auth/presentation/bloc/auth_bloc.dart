import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/driver_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.repository})
      : super(const AuthState()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthSignOutRequested>(_onSignOut);

    _subscription = repository.authStateChanges.listen((user) {
      add(AuthUserChanged(user?.uid));
    });
  }

  final AuthRepository repository;
  StreamSubscription<dynamic>? _subscription;

  Future<void> _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    final uid = event.userId;
    if (uid == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
      return;
    }
    try {
      var profile = await repository.loadProfile(uid);
      profile ??= DriverProfile(
        uid: uid,
        name: repository.currentUser?.displayName ?? 'Driver',
        phone: repository.currentUser?.phoneNumber ?? '',
        email: repository.currentUser?.email ?? '',
      );
      emit(AuthState(status: AuthStatus.authenticated, profile: profile));
    } catch (e) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await repository.signInWithEmail(event.email, event.password);
    } on Exception catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _mapError(e),
      ));
    }
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await repository.registerDriver(
        name: event.name,
        phone: event.phone,
        email: event.email,
        password: event.password,
      );
    } on Exception catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _mapError(e),
      ));
    }
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      await repository.signInWithGoogle();
    } on Exception catch (e) {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: _mapError(e),
      ));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repository.signOut();
  }

  String _mapError(Exception e) {
    final message = e.toString();
    if (message.contains('invalid-credential') ||
        message.contains('wrong-password') ||
        message.contains('user-not-found')) {
      return 'Invalid email or password.';
    }
    if (message.contains('email-already-in-use')) {
      return 'An account already exists for this email.';
    }
    if (message.contains('weak-password')) {
      return 'Password is too weak (minimum 6 characters).';
    }
    if (message.contains('invalid-email')) {
      return 'That email address looks invalid.';
    }
    if (message.contains('network-request-failed')) {
      return 'Network error. Check your connection.';
    }
    if (message.contains('ApiException') ||
        message.contains('cancelled') ||
        message.contains('Canceled')) {
      return 'Google sign-in was cancelled.';
    }
    return 'Authentication failed. Please try again.';
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
