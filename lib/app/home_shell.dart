import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/app_colors.dart';
import '../features/auth/domain/entities/driver_profile.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/presentation/bloc/auth_event.dart';
import '../features/orders/domain/repositories/order_repository.dart';
import '../features/orders/presentation/bloc/order_bloc.dart';
import '../features/orders/presentation/bloc/order_event.dart';
import '../features/orders/presentation/screens/driver_runsheet_screen.dart';
import '../features/settlement/presentation/bloc/settlement_bloc.dart';
import '../features/settlement/presentation/bloc/settlement_event.dart';
import '../features/settlement/presentation/screens/settlement_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.profile});

  final DriverProfile profile;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final profile = widget.profile;
    try {
      await context.read<OrderRepository>().ensureDemoData(
            driverId: profile.uid,
            driverName: profile.name,
            driverPhone: profile.phone,
          );
    } catch (_) {}
    if (!mounted) return;
    context.read<OrderBloc>().add(LoadDriverRunsheetEvent(profile.uid));
    context
        .read<SettlementBloc>()
        .add(LoadSettlementsRequested(profile.uid));
  }

  void _onTabTapped(int index) => setState(() => _tabIndex = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      const DriverRunsheetScreen(),
      SettlementScreen(driverId: widget.profile.uid),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('OrderPulse',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            Text('Driver: ${widget.profile.name}',
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthSignOutRequested()),
          ),
        ],
      ),
      body: IndexedStack(index: _tabIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: _onTabTapped,
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: .25),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check),
            label: 'Run-Sheet',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Cash',
          ),
        ],
      ),
    );
  }
}
