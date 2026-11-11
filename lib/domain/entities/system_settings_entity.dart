import 'package:equatable/equatable.dart';

class SystemSettingsEntity extends Equatable {
  const SystemSettingsEntity({
    required this.defaultTaxPercentage,
    required this.currency,
    required this.lowStockThreshold,
  });

  final double defaultTaxPercentage;
  final String currency;
  final int lowStockThreshold;

  @override
  List<Object?> get props => [defaultTaxPercentage, currency, lowStockThreshold];
}
