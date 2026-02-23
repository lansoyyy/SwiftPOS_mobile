import 'product.dart';
import 'discount.dart';

class CartItem {
  final Product product;
  int quantity;
  Discount? discount;

  CartItem({required this.product, this.quantity = 1, this.discount});

  double get basePrice => product.price * quantity;

  double get discountAmount => discount?.applyTo(basePrice) ?? 0.0;

  double get subtotal => basePrice - discountAmount;

  CartItem copyWith({Product? product, int? quantity, Discount? discount}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
    );
  }
}
