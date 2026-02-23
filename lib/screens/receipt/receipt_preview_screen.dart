import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../main_shell.dart';
import '../../models/cart_item.dart';
import '../../models/tax_settings.dart';
import '../../models/discount.dart';

class ReceiptPreviewScreen extends StatelessWidget {
  final MainShellState shell;
  final List<CartItem> items;
  final TaxSettings taxSettings;
  final Discount? orderDiscount;
  final double subtotal;
  final double itemDiscounts;
  final double orderDiscountAmount;
  final double taxAmount;
  final double total;

  const ReceiptPreviewScreen({
    super.key,
    required this.shell,
    required this.items,
    required this.taxSettings,
    required this.orderDiscount,
    required this.subtotal,
    required this.itemDiscounts,
    required this.orderDiscountAmount,
    required this.taxAmount,
    required this.total,
  });

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12
        ? dt.hour - 12
        : dt.hour == 0
        ? 12
        : dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $ampm';
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Receipt Preview',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check, size: 20),
            label: const Text(
              'Confirm',
              style: TextStyle(fontFamily: 'Urbanist'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: AppColors.surface,
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Receipt Preview',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  'Review before completing sale',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Receipt content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'SwiftPOS',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '123 Main Street',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Tel: (555) 123-4567',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _formatDate(now),
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _formatTime(now),
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(height: 2, color: AppColors.primary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Items
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.product.name,
                                    style: const TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  _formatCurrency(item.subtotal),
                                  style: const TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.quantity} x ${_formatCurrency(item.basePrice)}',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (item.discount != null)
                                  Text(
                                    '-${_formatCurrency(item.discountAmount)}',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 11,
                                      color: AppColors.warning,
                                    ),
                                  ),
                              ],
                            ),
                            if (item.discount != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Discount: ${item.discount!.name}',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 10,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(height: 1, color: Colors.grey[300]),
                    const SizedBox(height: 12),

                    // Totals
                    _ReceiptTotalRow(
                      label: 'Subtotal',
                      value: _formatCurrency(subtotal),
                    ),
                    if (itemDiscounts > 0)
                      _ReceiptTotalRow(
                        label: 'Item Discounts',
                        value: '-${_formatCurrency(itemDiscounts)}',
                        valueColor: AppColors.warning,
                      ),
                    if (orderDiscountAmount > 0)
                      _ReceiptTotalRow(
                        label: 'Order Discount (${orderDiscount?.name})',
                        value: '-${_formatCurrency(orderDiscountAmount)}',
                        valueColor: AppColors.warning,
                      ),
                    if (taxSettings.enabled)
                      _ReceiptTotalRow(
                        label: 'Tax (${taxSettings.name} ${taxSettings.rate}%)',
                        value: _formatCurrency(taxAmount),
                      ),
                    const SizedBox(height: 8),
                    Container(height: 2, color: AppColors.primary),
                    const SizedBox(height: 12),
                    _ReceiptTotalRow(
                      label: 'TOTAL',
                      value: _formatCurrency(total),
                      valueColor: AppColors.primary,
                      isBold: true,
                    ),
                    const SizedBox(height: 16),

                    // Footer
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Thank you for your purchase!',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Please come again',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom actions
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.check_circle, size: 20),
                    label: const Text(
                      'Complete Sale',
                      style: TextStyle(fontFamily: 'Urbanist'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text(
                      'Edit Order',
                      style: TextStyle(fontFamily: 'Urbanist'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptTotalRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool isBold;

  const _ReceiptTotalRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: isBold ? 16 : 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
