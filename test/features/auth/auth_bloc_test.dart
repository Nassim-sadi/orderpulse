import 'package:bloc_test/bloc_test.dart';
import 'package:cod_delivery_app/features/auth/domain/entities/auth_failure.dart';
import 'package:cod_delivery_app/features/auth/domain/entities/driver_profile.dart';
import 'package:cod_delivery_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cod_delivery_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:cod_delivery_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:cod_delivery_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class FakeUser extends Fake implements User {
  @override
  String get uid => 'u_1';

  @override
  String? get displayName => 'Nassim';

  @override
  String? get email => 'n@example.com';

  @override
  String? get phoneNumber => '0555';
}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    when(() => repository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
  });

  AuthBloc build() => AuthBloc(repository: repository);

  group('error mapping', () {
    blocTest<AuthBloc, AuthState>(
      'maps invalid credentials to a friendly message',
      build: build,
      act: (bloc) {
        when(() => repository.signInWithEmail(any(), any()))
            .thenThrow(const AuthFailure(AuthFailureKind.invalidCredentials));
        bloc.add(const AuthSignInRequested(
            email: 'a@b.c', password: 'wrong'));
      },
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated)
            .having((s) => s.errorMessage, 'error',
                'Invalid email or password.'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'explains the missing-Google-account case',
      build: build,
      act: (bloc) {
        when(() => repository.signInWithGoogle()).thenThrow(
          const AuthFailure(AuthFailureKind.googleNoAccount),
        );
        bloc.add(const AuthGoogleSignInRequested());
      },
      expect: () => [
        isA<AuthState>().having((s) => s.status, 'status', AuthStatus.loading),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated)
            .having(
              (s) => s.errorMessage,
              'error',
              contains('No Google account found'),
            ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'distinguishes user cancellation from real failures',
      build: build,
      act: (bloc) async {
        when(() => repository.signInWithGoogle())
            .thenThrow(const AuthFailure(AuthFailureKind.googleCancelled));
        bloc.add(const AuthGoogleSignInRequested());
        await Future<void>.delayed(Duration.zero);

        when(() => repository.signInWithGoogle())
            .thenThrow(const AuthFailure(AuthFailureKind.network));
        bloc.add(const AuthGoogleSignInRequested());
      },
      expect: () => [
        isA<AuthState>(),
        isA<AuthState>()
            .having((s) => s.errorMessage, 'error',
                'Google sign-in was cancelled.'),
        isA<AuthState>(),
        isA<AuthState>()
            .having((s) => s.errorMessage, 'error',
                'Network error. Check your connection.'),
      ],
    );
  });

  group('AuthUserChanged', () {
    test('loads the profile for the signed-in user', () async {
      final user = FakeUser();
      final profile = DriverProfile(
        uid: 'u_1',
        name: 'Nassim',
        phone: '0555',
        email: 'n@example.com',
        trustScore: 90,
      );
      when(() => repository.loadProfile('u_1'))
          .thenAnswer((_) async => profile);
      when(() => repository.currentUser).thenReturn(user);

      final emitted = <AuthState>[];
      final bloc = build();
      final sub = bloc.stream.listen(emitted.add);
      bloc.add(const AuthUserChanged('u_1'));
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();
      await bloc.close();

      expect(emitted.last.status, AuthStatus.authenticated);
      expect(emitted.last.profile, profile);
    });
  });
}
