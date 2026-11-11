import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  const CategoryEntity({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  final String id;
  final String name;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt, isActive];
}
