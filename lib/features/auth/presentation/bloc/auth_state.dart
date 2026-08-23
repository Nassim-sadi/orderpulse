import 'package:equatable/equatable.dart';

import '../../domain/entities/driver_profile.dart';

enum AuthStatus { unknown, loading, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.profile,
    this.errorMessage,
  });

  final AuthStatus status;
  final DriverProfile? profile;
  final String? errorMessage;

  bool get isBusy => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    DriverProfile? profile,
    String? errorMessage,
    bool clearError = false,
  }) =>
      AuthState(
        status: status ?? this.status,
        profile: profile ?? this.profile,
        errorMessage:
            clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [status, profile, errorMessage];
}
