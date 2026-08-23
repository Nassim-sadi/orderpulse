import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/locale_cubit.dart';
import 'core/services/call_service.dart';
import 'core/services/location_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/settings_service.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/orders/data/repositories/order_repository_impl.dart';
import 'features/orders/domain/repositories/order_repository.dart';
import 'features/orders/presentation/bloc/order_bloc.dart';
import 'features/settlement/data/repositories/settlement_repository_impl.dart';
import 'features/settlement/domain/repositories/settlement_repository.dart';
import 'features/settlement/presentation/bloc/settlement_bloc.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();

  final firestore = FirebaseFirestore.instance;
  final authRepository = FirebaseAuthRepository(FirebaseAuth.instance, firestore);
  final settingsService = SettingsService(firestore);
  await settingsService.warmUp();

  final prefs = await SharedPreferences.getInstance();

  runApp(OrderPulseRoot(
    authRepository: authRepository,
    firestore: firestore,
    settingsService: settingsService,
    prefs: prefs,
  ));
}

class OrderPulseRoot extends StatelessWidget {
  const OrderPulseRoot({
    super.key,
    required this.authRepository,
    required this.firestore,
    required this.settingsService,
    required this.prefs,
  });

  final AuthRepository authRepository;
  final FirebaseFirestore firestore;
  final SettingsService settingsService;
  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<OrderRepository>(
            create: (_) => FirestoreOrderRepository(firestore)),
        RepositoryProvider<SettlementRepository>(
            create: (_) => FirestoreSettlementRepository(firestore)),
        RepositoryProvider<SettingsService>.value(value: settingsService),
        RepositoryProvider<AppSettings>.value(value: settingsService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => AuthBloc(repository: authRepository)),
          BlocProvider<LocaleCubit>(create: (_) => LocaleCubit(prefs)),
          BlocProvider<OrderBloc>(
            create: (context) => OrderBloc(
              repository: context.read<OrderRepository>(),
              locationService: LocationService(),
              callService: CallService(),
              settings: context.read<AppSettings>(),
            ),
          ),
          BlocProvider<SettlementBloc>(
            create: (context) => SettlementBloc(
              settlementRepository: context.read<SettlementRepository>(),
              orderRepository: context.read<OrderRepository>(),
            ),
          ),
        ],
        child: const OrderPulseApp(),
      ),
    );
  }
}
