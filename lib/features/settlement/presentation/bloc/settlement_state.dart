import 'package:equatable/equatable.dart';

import '../../domain/entities/settlement_entity.dart';

enum SettlementSubmitStatus { idle, submitting, success, failure }

class SettlementState extends Equatable {
  const SettlementState({
    this.isLoading = false,
    this.settlements = const [],
    this.summary,
    this.submitStatus = SettlementSubmitStatus.idle,
    this.errorMessage,
  });

  final bool isLoading;
  final List<SettlementEntity> settlements;
  final DailyCashSummary? summary;
  final SettlementSubmitStatus submitStatus;
  final String? errorMessage;

  bool get hasSubmittedToday =>
      settlements.any((s) => s.date == _todayIso());

  static String _todayIso() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  SettlementState copyWith({
    bool? isLoading,
    List<SettlementEntity>? settlements,
    DailyCashSummary? summary,
    SettlementSubmitStatus? submitStatus,
    String? errorMessage,
    bool clearError = false,
  }) =>
      SettlementState(
        isLoading: isLoading ?? this.isLoading,
        settlements: settlements ?? this.settlements,
        summary: summary ?? this.summary,
        submitStatus: submitStatus ?? this.submitStatus,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  List<Object?> get props => [
        isLoading,
        settlements,
        summary,
        submitStatus,
        errorMessage,
      ];
}
