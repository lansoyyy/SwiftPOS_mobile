enum DiscountType { percentage, fixedAmount }

class Discount {
  final String? id;
  final String name;
  final DiscountType type;
  final double value;
  final bool isItemLevel; // true for item-level, false for order-level

  const Discount({
    this.id,
    required this.name,
    required this.type,
    required this.value,
    this.isItemLevel = false,
  });

  double applyTo(double amount) {
    switch (type) {
      case DiscountType.percentage:
        return amount * (value / 100);
      case DiscountType.fixedAmount:
        return value.clamp(0, amount);
    }
  }

  Discount copyWith({
    String? id,
    String? name,
    DiscountType? type,
    double? value,
    bool? isItemLevel,
  }) {
    return Discount(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      isItemLevel: isItemLevel ?? this.isItemLevel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'value': value,
      'is_item_level': isItemLevel,
    };
  }

  factory Discount.fromMap(Map<String, dynamic> map) {
    return Discount(
      id: map['id'] as String?,
      name: map['name'] as String,
      type: DiscountType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => DiscountType.percentage,
      ),
      value: (map['value'] as num).toDouble(),
      isItemLevel: map['is_item_level'] as bool? ?? false,
    );
  }

  // Predefined discounts
  static const List<Discount> predefinedItemDiscounts = [
    Discount(
      name: '5% Off',
      type: DiscountType.percentage,
      value: 5,
      isItemLevel: true,
    ),
    Discount(
      name: '10% Off',
      type: DiscountType.percentage,
      value: 10,
      isItemLevel: true,
    ),
    Discount(
      name: '15% Off',
      type: DiscountType.percentage,
      value: 15,
      isItemLevel: true,
    ),
    Discount(
      name: '20% Off',
      type: DiscountType.percentage,
      value: 20,
      isItemLevel: true,
    ),
  ];

  static const List<Discount> predefinedOrderDiscounts = [
    Discount(
      name: '5% Off Total',
      type: DiscountType.percentage,
      value: 5,
      isItemLevel: false,
    ),
    Discount(
      name: '10% Off Total',
      type: DiscountType.percentage,
      value: 10,
      isItemLevel: false,
    ),
    Discount(
      name: '15% Off Total',
      type: DiscountType.percentage,
      value: 15,
      isItemLevel: false,
    ),
    Discount(
      name: 'P50 Off',
      type: DiscountType.fixedAmount,
      value: 50,
      isItemLevel: false,
    ),
    Discount(
      name: 'P100 Off',
      type: DiscountType.fixedAmount,
      value: 100,
      isItemLevel: false,
    ),
  ];
}
