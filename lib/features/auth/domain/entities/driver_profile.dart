import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_constants.dart';

class DriverProfile extends Equatable {
  const DriverProfile({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    this.role = 'DRIVER',
    this.trustScore = AppConstants.defaultTrustScore,
  });

  final String uid;
  final String name;
  final String phone;
  final String email;
  final String role;
  final int trustScore;

  bool get isMerchant => role.toUpperCase() == 'MERCHANT';

  @override
  List<Object?> get props => [uid, name, phone, email, role, trustScore];
}
