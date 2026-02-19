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

  // Database serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'total': total,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'payment_method': paymentMethod,
      'amount_paid': amountPaid,
      'change_amount': change,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory SaleRecord.fromMap(Map<String, dynamic> map, List<CartItem> items) {
    return SaleRecord(
      id: map['id'] as String,
      items: items,
      total: map['total'] as double,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      paymentMethod: map['payment_method'] as String,
      amountPaid: map['amount_paid'] as double?,
      change: map['change_amount'] as double?,
    );
  }
}
