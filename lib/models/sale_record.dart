import 'cart_item.dart';

class SaleRecord {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime timestamp;
  final String paymentMethod;
  final double? amountPaid;
  final double? change;

  SaleRecord({
    required this.id,
    required this.items,
    required this.total,
    required this.timestamp,
    required this.paymentMethod,
    this.amountPaid,
    this.change,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
