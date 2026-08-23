import 'package:equatable/equatable.dart';

sealed class SettlementEvent extends Equatable {
  const SettlementEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettlementsRequested extends SettlementEvent {
  const LoadSettlementsRequested(this.driverId);

  final String driverId;

  @override
  List<Object?> get props => [driverId];
}

class RefreshSummaryRequested extends SettlementEvent {
  const RefreshSummaryRequested(this.driverId);

  final String driverId;

  @override
  List<Object?> get props => [driverId];
}

class SubmitDailySettlementRequested extends SettlementEvent {
  const SubmitDailySettlementRequested(this.driverId);

  final String driverId;

  @override
  List<Object?> get props => [driverId];
}
