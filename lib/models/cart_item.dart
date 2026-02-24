import 'product.dart';
import 'discount.dart';

class CartItem {
  final Product product;
  int quantity;
  Discount? discount;
  final ProductVariant? variant;
  final double? priceOverride;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.discount,
    this.variant,
    this.priceOverride,
  });

  double get basePrice {
    final unitPrice = priceOverride ?? variant?.priceOverride ?? product.price;
    return unitPrice * quantity;
  }

  double get discountAmount => discount?.applyTo(basePrice) ?? 0.0;

  double get subtotal => basePrice - discountAmount;

  String get displayName {
    if (variant != null) {
      return '${product.name} (${variant!.size} / ${variant!.color})';
    }
    return product.name;
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
    Discount? discount,
    ProductVariant? variant,
    double? priceOverride,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
      variant: variant ?? this.variant,
      priceOverride: priceOverride ?? this.priceOverride,
    );
  }
}
