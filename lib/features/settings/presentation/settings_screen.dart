import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/locale_cubit.dart';
import '../../../core/services/settings_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/domain/entities/driver_profile.dart';
import '../../auth/domain/repositories/auth_repository.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_event.dart';
import '../../auth/presentation/bloc/auth_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthBloc>().state.profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(DriverProfile profile) async {
    final messenger = ScaffoldMessenger.of(context);
    final repository = context.read<AuthRepository>();
    await repository.updateProfile(
      uid: profile.uid,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );
    if (!mounted) return;
    context.read<AuthBloc>().add(AuthUserChanged(profile.uid));
    messenger.showSnackBar(const SnackBar(
      content: Text('Profile updated.'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsService = context.read<SettingsService>();
    final localeCubit = context.read<LocaleCubit>();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final profile = authState.profile;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (profile != null) ...[
                _Section(
                  title: l10n.accountSection,
                  icon: Icons.person_outline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(profile.email,
                                style: const TextStyle(color: Colors.white54)),
                          ),
                          Chip(
                            avatar: Icon(Icons.verified_user,
                                size: 16,
                                color: Colors.green.shade400),
                            label: Text(
                              '${profile.trustScore}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.green.shade400),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration:
                            InputDecoration(labelText: l10n.nameLabel),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration:
                            InputDecoration(labelText: l10n.phoneLabel),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () => _saveProfile(profile),
                        icon: const Icon(Icons.save_outlined),
                        label: Text(l10n.saveProfile),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              _Section(
                title: l10n.languageLabel,
                icon: Icons.translate,
                child: DropdownButtonFormField<String>(
                  initialValue: localeCubit.state.languageCode,
                  dropdownColor: const Color(0xFF212B3D),
                  items: [
                    DropdownMenuItem(
                        value: 'en', child: Text(l10n.langEnglish)),
                    DropdownMenuItem(
                        value: 'ar', child: Text(l10n.langArabic)),
                    DropdownMenuItem(
                        value: 'fr', child: Text(l10n.langFrench)),
                  ],
                  onChanged: (code) {
                    if (code != null) localeCubit.setLanguage(code);
                  },
                ),
              ),
              const SizedBox(height: 14),
              _Section(
                title: l10n.timersSection,
                icon: Icons.timer_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TimerDropdown(
                      label: l10n.driverTimerLabel,
                      isDriver: true,
                      currentValue:
                          settingsService.driverStatusWindow.inMinutes,
                      onSelected: (driverMinutes, merchantMinutes) =>
                          settingsService.updateWindows(
                        driverStatusMinutes: driverMinutes,
                        verificationMinutes: merchantMinutes,
                      ).then((_) => _toastTimerSaved()),
                    ),
                    const SizedBox(height: 10),
                    _TimerDropdown(
                      label: l10n.merchantTimerLabel,
                      isDriver: false,
                      currentValue: settingsService
                          .merchantVerificationWindow.inMinutes,
                      onSelected: (driverMinutes, merchantMinutes) =>
                          settingsService.updateWindows(
                        driverStatusMinutes: driverMinutes,
                        verificationMinutes: merchantMinutes,
                      ).then((_) => _toastTimerSaved()),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _toastTimerSaved() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context).timerSavedToast),
      behavior: SnackBarBehavior.floating,
    ));
  }
}

class _TimerDropdown extends StatelessWidget {
  const _TimerDropdown({
    required this.label,
    required this.isDriver,
    required this.currentValue,
    required this.onSelected,
  });

  final String label;
  final bool isDriver;
  final int currentValue;
  final void Function(int driverMinutes, int merchantMinutes) onSelected;

  static const List<int> presets = [5, 10, 15, 30];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white54)),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          initialValue: presets.contains(currentValue)
              ? currentValue
              : presets.first,
          dropdownColor: const Color(0xFF212B3D),
          items: [
            for (final p in presets)
              DropdownMenuItem(
                value: p,
                child: Text(l10n.minutesUnit(p)),
              ),
          ],
          onChanged: (value) {
            if (value == null) return;
            final service = RepositoryProvider.of<SettingsService>(context);
            onSelected(
              isDriver
                  ? value
                  : service.driverStatusWindow.inMinutes,
              isDriver
                  ? service.merchantVerificationWindow.inMinutes
                  : value,
            );
          },
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF212B3D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
