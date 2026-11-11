import 'package:equatable/equatable.dart';

class SupplierEntity extends Equatable {
  const SupplierEntity({
    required this.id,
    required this.name,
    this.phone,
    this.totalDebt = 0,
    this.totalPaid = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? phone;
  final double totalDebt;
  final double totalPaid;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, name, phone, totalDebt, totalPaid, createdAt, updatedAt];
}
