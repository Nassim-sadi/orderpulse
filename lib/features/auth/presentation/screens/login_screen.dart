import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/locale_cubit.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) => DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: locale.languageCode,
          dropdownColor: const Color(0xFF212B3D),
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.language, size: 18),
          items: [
            DropdownMenuItem(value: 'en', child: Text(l10n.langEnglish)),
            DropdownMenuItem(value: 'ar', child: Text(l10n.langArabic)),
            DropdownMenuItem(value: 'fr', child: Text(l10n.langFrench)),
          ],
          onChanged: (code) {
            if (code != null) {
              context.read<LocaleCubit>().setLanguage(code);
            }
          },
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthSignInRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: const LanguageDropdown(),
                    ),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: .15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_shipping_rounded,
                        size: 44,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      l10n.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                        labelText: l10n.emailLabel,
                        prefixIcon: const Icon(Icons.alternate_email),
                      ),
                      validator: (v) =>
                          (v == null || !v.contains('@')) ? l10n.enterValidEmail : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      onFieldSubmitted: (_) => _submit(context),
                      decoration: InputDecoration(
                        labelText: l10n.passwordLabel,
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? l10n.minSixCharacters
                          : null,
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) => state.isBusy
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                FilledButton(
                                  onPressed: () => _submit(context),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                  ),
                                  child: Text(l10n.signIn,
                                      style:
                                          const TextStyle(fontWeight: FontWeight.w800)),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  icon: Image.asset(
                                    'assets/google_logo.png',
                                    height: 20,
                                    errorBuilder: (_, _, _) => const Icon(Icons.g_mobiledata, size: 26),
                                  ),
                                  label: Text(l10n.continueWithGoogle),
                                  onPressed: () => context
                                      .read<AuthBloc>()
                                      .add(const AuthGoogleSignInRequested()),
                                  style: OutlinedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.newDriverPrompt,
                            style: const TextStyle(color: Colors.white54)),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/register'),
                          child: Text(
                            l10n.createAccount,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
