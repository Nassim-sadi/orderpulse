import 'package:equatable/equatable.dart';

class DriverProfile extends Equatable {
  const DriverProfile({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    this.role = 'DRIVER',
  });

  final String uid;
  final String name;
  final String phone;
  final String email;
  final String role;

  @override
  List<Object?> get props => [uid, name, phone, email, role];
}
