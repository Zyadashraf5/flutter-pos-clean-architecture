class SystemSettingsFirestoreModel {
  const SystemSettingsFirestoreModel({
    required this.defaultTaxPercentage,
    required this.currency,
    required this.lowStockThreshold,
  });

  final double defaultTaxPercentage;
  final String currency;
  final int lowStockThreshold;

  Map<String, dynamic> toFirestore() => {
        'defaultTaxPercentage': defaultTaxPercentage,
        'currency': currency,
        'lowStockThreshold': lowStockThreshold,
      };

  factory SystemSettingsFirestoreModel.fromFirestore(Map<String, dynamic> data) {
    return SystemSettingsFirestoreModel(
      defaultTaxPercentage: (data['defaultTaxPercentage'] as num?)?.toDouble() ?? 0,
      currency: data['currency'] as String? ?? 'USD',
      lowStockThreshold: data['lowStockThreshold'] as int? ?? 5,
    );
  }
}
