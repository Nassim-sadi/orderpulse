import 'package:bloc_test/bloc_test.dart';
import 'package:cod_delivery_app/core/services/call_service.dart';
import 'package:cod_delivery_app/core/services/location_service.dart';
import 'package:cod_delivery_app/core/services/settings_service.dart';
import 'package:cod_delivery_app/features/orders/domain/entities/order_entity.dart';
import 'package:cod_delivery_app/features/orders/domain/repositories/order_repository.dart';
import 'package:cod_delivery_app/features/orders/presentation/bloc/order_bloc.dart';
import 'package:cod_delivery_app/features/orders/presentation/bloc/order_event.dart';
import 'package:cod_delivery_app/features/orders/presentation/bloc/order_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class MockLocationService extends Mock implements LocationService {}

class MockCallService extends Mock implements CallService {}

class FakeAppSettings extends Fake implements AppSettings {
  @override
  Duration get driverStatusWindow => const Duration(minutes: 10);

  @override
  Duration get merchantVerificationWindow => const Duration(minutes: 15);
}

OrderEntity _order() => OrderEntity(
      id: 'ORD-1',
      trackingNumber: 'TRK-1',
      client: const ClientDetails(
          name: 'Test Client',
          phone: '0550123456',
          wilaya: 'Batna',
          commune: 'Bouakal',
          streetAddress: 'Street 1'),
      financials:
          const Financials(itemSubtotal: 100, shippingFee: 50, totalCodAmount: 150),
      status: OrderStatus.outForDelivery,
      assignedDriver: const DriverRef(id: 'drv_1', name: 'Driver', phone: '066'),
      createdAt: DateTime(2026, 8, 22),
      updatedAt: DateTime(2026, 8, 22),
    );

void main() {
  late MockOrderRepository repository;
  late MockLocationService locationService;
  late MockCallService callService;
  late FakeAppSettings settings;
  late OrderEntity order;

  setUpAll(() {
    registerFallbackValue(FailureReason.unresponsive);
    registerFallbackValue(DateTime.now());
    registerFallbackValue(const Duration(minutes: 15));
  });

  setUp(() {
    repository = MockOrderRepository();
    locationService = MockLocationService();
    callService = MockCallService();
    settings = FakeAppSettings();
    order = _order();

    when(() => repository.watchDriverOrders(any()))
        .thenAnswer((_) => Stream.value([_order()]));
    when(() => repository.logCallAttempt(
          orderId: any(named: 'orderId'),
          driverId: any(named: 'driverId'),
          clientPhone: any(named: 'clientPhone'),
          responseWindow: any(named: 'responseWindow'),
        )).thenAnswer((_) async {});
    when(() => callService.dialCustomer(any())).thenAnswer((_) async => true);
  });

  OrderBloc buildBloc() => OrderBloc(
        repository: repository,
        locationService: locationService,
        callService: callService,
        settings: settings,
      );

  group('LoadDriverRunsheetEvent', () {
    blocTest<OrderBloc, OrderState>(
      'emits loading then loaded with orders',
      build: buildBloc,
      act: (bloc) => bloc.add(const LoadDriverRunsheetEvent('drv_1')),
      expect: () => [
        isA<OrderLoadingState>(),
        isA<OrderLoadedState>()
            .having((s) => s.orders.length, 'orders.length', 1),
      ],
      verify: (_) {
        verify(() => repository.watchDriverOrders('drv_1')).called(1);
      },
    );
  });

  group('CallInitiatedEvent', () {
    blocTest<OrderBloc, OrderState>(
      'logs a call attempt and starts the driver response window',
      build: buildBloc,
      seed: () => OrderLoadedState([order]),
      act: (bloc) async {
        bloc.add(const CallInitiatedEvent(
          orderId: 'ORD-1',
          driverId: 'drv_1',
          clientPhone: '0550123456',
        ));
      },
      verify: (_) {
        verify(() => repository.logCallAttempt(
              orderId: 'ORD-1',
              driverId: 'drv_1',
              clientPhone: '0550123456',
              responseWindow: const Duration(minutes: 10),
            )).called(1);
      },
    );

    blocTest<OrderBloc, OrderState>(
      'emits action failure when the dialer cannot be opened',
      build: buildBloc,
      act: (bloc) async {
        when(() => callService.dialCustomer(any())).thenAnswer((_) async => false);
        bloc
            .add(const CallInitiatedEvent(
                orderId: 'ORD-1', driverId: 'drv_1', clientPhone: '0550123456'));
      },
      expect: () => [
        isA<OrderActionFailureState>().having(
            (s) => s.code, 'code', OrderActionError.dialerFailed),
      ],
      verify: (_) {
        verifyNever(() => repository.logCallAttempt(
              orderId: any(named: 'orderId'),
              driverId: any(named: 'driverId'),
              clientPhone: any(named: 'clientPhone'),
              responseWindow: any(named: 'responseWindow'),
            ));
      },
    );
  });

  group('AttemptDeliveryFailureEvent', () {
    test('prompts for unverified confirmation instead of blocking', () async {
      when(() => callService.verifyOutboundCall(any(),
              since: any(named: 'since')))
          .thenAnswer((_) async => false);

      final bloc = buildBloc()
        ..add(const LoadDriverRunsheetEvent('drv_1'));
      await Future<void>.delayed(Duration.zero);

      bloc.add(const AttemptDeliveryFailureEvent(
        orderId: 'ORD-1',
        reason: FailureReason.unresponsive,
        clientPhone: '0550123456',
      ));
      await Future<void>.delayed(Duration.zero);

      final last = bloc.state as UnverifiedDeclinePromptState;
      expect(last.orderId, 'ORD-1');
      expect(last.reason, FailureReason.unresponsive);
      expect(bloc.state is! OrderActionFailureState, isTrue);
    });

    blocTest<OrderBloc, OrderState>(
      'reports failure with GPS fix and moves order to pending verification',
      build: buildBloc,
      seed: () => OrderLoadedState([order]),
      act: (bloc) async {
        when(() => callService.verifyOutboundCall(any(),
                since: any(named: 'since')))
            .thenAnswer((_) async => true);
        when(() => locationService.getCurrentPosition()).thenAnswer(
          (_) async => const GpsFix(
              latitude: 35.5558, longitude: 6.1741, accuracyMeters: 4.2),
        );
        when(() => repository.reportDeliveryFailure(
              orderId: any(named: 'orderId'),
              reason: any(named: 'reason'),
              callInitiatedAt: any(named: 'callInitiatedAt'),
              callDurationSeconds: any(named: 'callDurationSeconds'),
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              accuracyMeters: any(named: 'accuracyMeters'),
              verificationWindow: any(named: 'verificationWindow'),
              verifiedCall: any(named: 'verifiedCall'),
            )).thenAnswer((_) async {});

        bloc.add(const LoadDriverRunsheetEvent('drv_1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const AttemptDeliveryFailureEvent(
          orderId: 'ORD-1',
          reason: FailureReason.unresponsive,
          clientPhone: '0550123456',
        ));
      },
      expect: () => [
        isA<OrderLoadingState>(),
        isA<OrderLoadedState>(),
        isA<OrderLoadedState>()
            .having(
                (s) => s.orders.first.status, 'status',
                OrderStatus.failedPendingVerification)
            .having((s) => s.orders.first.audit!.location.latitude,
                'audit lat', 35.5558)
            .having((s) => s.orders.first.audit!.unverifiedReturn,
                'unverified flag', isFalse)
            .having((s) => s.orders.first.driverResponseDeadline, 'timer cleared',
                isNull),
      ],
      verify: (_) {
        verify(() => repository.reportDeliveryFailure(
              orderId: 'ORD-1',
              reason: FailureReason.unresponsive,
              callInitiatedAt: any(named: 'callInitiatedAt'),
              callDurationSeconds: any(named: 'callDurationSeconds'),
              latitude: 35.5558,
              longitude: 6.1741,
              accuracyMeters: 4.2,
              verificationWindow: const Duration(minutes: 15),
              verifiedCall: true,
            )).called(1);
      },
    );
  });

  group('ConfirmUnverifiedDeclineEvent', () {
    blocTest<OrderBloc, OrderState>(
      'reports an UNVERIFIED failure after explicit confirmation',
      build: buildBloc,
      seed: () => OrderLoadedState([order]),
      act: (bloc) async {
        when(() => locationService.getCurrentPosition()).thenAnswer(
          (_) async => const GpsFix(
              latitude: 35.5558, longitude: 6.1741, accuracyMeters: 4.2),
        );
        when(() => repository.reportDeliveryFailure(
              orderId: any(named: 'orderId'),
              reason: any(named: 'reason'),
              callInitiatedAt: any(named: 'callInitiatedAt'),
              callDurationSeconds: any(named: 'callDurationSeconds'),
              latitude: any(named: 'latitude'),
              longitude: any(named: 'longitude'),
              accuracyMeters: any(named: 'accuracyMeters'),
              verificationWindow: any(named: 'verificationWindow'),
              verifiedCall: any(named: 'verifiedCall'),
            )).thenAnswer((_) async {});

        bloc.add(const LoadDriverRunsheetEvent('drv_1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const ConfirmUnverifiedDeclineEvent(
          orderId: 'ORD-1',
          reason: FailureReason.refused,
          clientPhone: '0550123456',
        ));
      },
      expect: () => [
        isA<OrderLoadingState>(),
        isA<OrderLoadedState>(),
        isA<OrderLoadedState>()
            .having((s) => s.orders.first.status, 'status',
                OrderStatus.failedPendingVerification)
            .having((s) => s.orders.first.audit!.unverifiedReturn,
                'unverified flag', isTrue),
      ],
      verify: (_) {
        verify(() => repository.reportDeliveryFailure(
              orderId: 'ORD-1',
              reason: FailureReason.refused,
              callInitiatedAt: any(named: 'callInitiatedAt'),
              callDurationSeconds: any(named: 'callDurationSeconds'),
              latitude: 35.5558,
              longitude: 6.1741,
              accuracyMeters: 4.2,
              verificationWindow: const Duration(minutes: 15),
              verifiedCall: false,
            )).called(1);
      },
    );
  });

  group('DeliveryConfirmedEvent', () {
    blocTest<OrderBloc, OrderState>(
      'confirms delivery and logs collected cash',
      build: buildBloc,
      seed: () => OrderLoadedState([order]),
      act: (bloc) async {
        when(() => repository.markDelivered(orderId: any(named: 'orderId')))
            .thenAnswer((_) async {});
        bloc.add(const LoadDriverRunsheetEvent('drv_1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const DeliveryConfirmedEvent('ORD-1'));
      },
      expect: () => [
        isA<OrderLoadingState>(),
        isA<OrderLoadedState>(),
        isA<OrderLoadedState>()
            .having((s) => s.orders.first.status, 'status',
                OrderStatus.deliveredPaid)
            .having((s) => s.orders.first.financials.amountCollected,
                'collected', 150),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'ignores delivery confirmation for an unknown order id',
      build: buildBloc,
      act: (bloc) async {
        when(() => repository.markDelivered(orderId: any(named: 'orderId')))
            .thenAnswer((_) async {});
        bloc.add(const LoadDriverRunsheetEvent('drv_1'));
        await Future<void>.delayed(Duration.zero);
        bloc.add(const DeliveryConfirmedEvent('UNKNOWN-ID'));
      },
      expect: () => [
        isA<OrderLoadingState>(),
        isA<OrderLoadedState>(),
      ],
      verify: (_) {
        verifyNever(() =>
            repository.markDelivered(orderId: any(named: 'orderId')));
      },
    );
  });
}
