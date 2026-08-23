import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/merchant/presentation/merchant_shell.dart';
import 'home_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
              prev.errorMessage != curr.errorMessage && curr.errorMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ));
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status && curr.status == AuthStatus.authenticated,
          listener: (context, state) {
            final name = state.profile?.name ?? '';
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(name.isEmpty ? 'Welcome back' : 'Welcome back, $name'),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
              ));
          },
        ),
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) =>
              prev.status == AuthStatus.authenticated &&
              curr.status == AuthStatus.unauthenticated,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Signed out successfully.'),
              behavior: SnackBarBehavior.floating,
            ));
          },
        ),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) => switch (state.status) {
          AuthStatus.unknown => const _SplashView(),
          AuthStatus.loading => const _SplashView(showSpinner: true),
          AuthStatus.authenticated when state.profile?.isMerchant == true =>
            const MerchantShell(),
          AuthStatus.authenticated when state.profile != null => HomeShell(
              key: Key('home_${state.profile!.uid}'),
              profile: state.profile!,
            ),
          _ => const LoginScreen(),
        },
      ),
    );
  }
}

class _SplashView extends StatelessWidget {
  const _SplashView({this.showSpinner = false});

  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_shipping_rounded,
                size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 20),
            if (showSpinner) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
