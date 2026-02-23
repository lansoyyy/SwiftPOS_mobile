class TaxSettings {
  final bool enabled;
  final double rate; // Tax rate as percentage (e.g., 12 for 12%)
  final String name; // e.g., "VAT", "GST", "Sales Tax"

  const TaxSettings({this.enabled = false, this.rate = 0.0, this.name = 'Tax'});

  TaxSettings copyWith({bool? enabled, double? rate, String? name}) {
    return TaxSettings(
      enabled: enabled ?? this.enabled,
      rate: rate ?? this.rate,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {'enabled': enabled, 'rate': rate, 'name': name};
  }

  factory TaxSettings.fromMap(Map<String, dynamic> map) {
    return TaxSettings(
      enabled: map['enabled'] as bool? ?? false,
      rate: (map['rate'] as num?)?.toDouble() ?? 0.0,
      name: map['name'] as String? ?? 'Tax',
    );
  }
}
