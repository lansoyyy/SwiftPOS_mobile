import 'cart_item.dart';
import 'discount.dart';

class SaleRecord {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double totalDiscount;
  final double taxAmount;
  final double total;
  final DateTime timestamp;
  final String paymentMethod;
  final List<String> paymentMethods; // For split payments
  final double? amountPaid;
  final double? change;
  final Discount? orderDiscount;

  SaleRecord({
    required this.id,
    required this.items,
    required this.subtotal,
    this.totalDiscount = 0.0,
    this.taxAmount = 0.0,
    required this.total,
    required this.timestamp,
    required this.paymentMethod,
    this.paymentMethods = const [],
    this.amountPaid,
    this.change,
    this.orderDiscount,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  // Database serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'subtotal': subtotal,
      'total_discount': totalDiscount,
      'tax_amount': taxAmount,
      'total': total,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'payment_method': paymentMethod,
      'payment_methods': paymentMethods.join(','),
      'amount_paid': amountPaid,
      'change_amount': change,
      'order_discount_id': orderDiscount?.id,
      'order_discount_name': orderDiscount?.name,
      'order_discount_type': orderDiscount?.type.name,
      'order_discount_value': orderDiscount?.value,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory SaleRecord.fromMap(Map<String, dynamic> map, List<CartItem> items) {
    Discount? orderDiscount;
    if (map['order_discount_name'] != null) {
      orderDiscount = Discount(
        id: map['order_discount_id'] as String?,
        name: map['order_discount_name'] as String,
        type: DiscountType.values.firstWhere(
          (e) => e.name == map['order_discount_type'],
          orElse: () => DiscountType.percentage,
        ),
        value: (map['order_discount_value'] as num).toDouble(),
        isItemLevel: false,
      );
    }

    return SaleRecord(
      id: map['id'] as String,
      items: items,
      subtotal: (map['subtotal'] as num).toDouble(),
      totalDiscount: (map['total_discount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (map['tax_amount'] as num?)?.toDouble() ?? 0.0,
      total: map['total'] as double,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      paymentMethod: map['payment_method'] as String,
      paymentMethods: (map['payment_methods'] as String? ?? '')
          .split(',')
          .where((s) => s.isNotEmpty)
          .toList(),
      amountPaid: map['amount_paid'] as double?,
      change: map['change_amount'] as double?,
      orderDiscount: orderDiscount,
    );
  }
}
