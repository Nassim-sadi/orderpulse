import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/auth_failure.dart';
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
        errorMessage: describeAuthFailure(e),
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
        errorMessage: describeAuthFailure(e),
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
        errorMessage: describeAuthFailure(e),
      ));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await repository.signOut();
  }

  static String describeAuthFailure(Exception e) {
    if (e is! AuthFailure) return e.toString();
    return switch (e.kind) {
      AuthFailureKind.invalidCredentials => 'Invalid email or password.',
      AuthFailureKind.emailInUse =>
        'An account already exists for this email.',
      AuthFailureKind.weakPassword =>
        'Password is too weak (minimum 6 characters).',
      AuthFailureKind.invalidEmail => 'That email address looks invalid.',
      AuthFailureKind.network => 'Network error. Check your connection.',
      AuthFailureKind.tooManyRequests =>
        'Too many attempts. Please wait and try again.',
      AuthFailureKind.googleCancelled => 'Google sign-in was cancelled.',
      AuthFailureKind.googleNoAccount =>
        'No Google account found on this device. Add one in Settings > Accounts, then try again.',
      AuthFailureKind.googleUnavailable =>
        'Google Sign-In failed. Check that Google Play Services are up to date and the app is signed correctly.',
      AuthFailureKind.unknown => 'Authentication failed. Please try again.',
    };
  }

  @override
  Future<void> close() {
    unawaited(_subscription?.cancel());
    return super.close();
  }
}
