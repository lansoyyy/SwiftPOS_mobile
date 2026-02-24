import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/discount.dart';
import '../../models/tax_settings.dart';
import '../../models/cart_item.dart';
import '../main_shell.dart';
import '../receipt/receipt_screen.dart';
import '../receipt/receipt_preview_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final MainShellState shell;
  const CheckoutScreen({super.key, required this.shell});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _processing = false;
  final _cashController = TextEditingController();

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  void _showItemDiscountDialog(CartItem item) {
    showDialog(
      context: context,
      builder: (_) => _ItemDiscountDialog(
        item: item,
        onApply: (discount) {
          widget.shell.setItemDiscount(item.product.id, discount);
        },
      ),
    );
  }

  void _showOrderDiscountDialog() {
    showDialog(
      context: context,
      builder: (_) => _OrderDiscountDialog(
        currentDiscount: widget.shell.orderDiscount,
        onApply: (discount) {
          widget.shell.setOrderDiscount(discount);
        },
      ),
    );
  }

  void _showTaxSettingsDialog() {
    showDialog(
      context: context,
      builder: (_) => _TaxSettingsDialog(
        currentSettings: widget.shell.taxSettings,
        onApply: (settings) {
          widget.shell.setTaxSettings(settings);
        },
      ),
    );
  }

  void _showReceiptPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptPreviewScreen(
          shell: widget.shell,
          items: widget.shell.cart,
          taxSettings: widget.shell.taxSettings,
          orderDiscount: widget.shell.orderDiscount,
          subtotal: widget.shell.cartSubtotal,
          itemDiscounts: widget.shell.cartItemDiscounts,
          orderDiscountAmount: widget.shell.cartOrderDiscount,
          taxAmount: widget.shell.cartTaxAmount,
          total: widget.shell.cartTotal,
        ),
      ),
    );
  }

  void _showPriceOverrideDialog(CartItem item) {
    final controller = TextEditingController(
      text: item.priceOverride?.toStringAsFixed(2) ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Price Override',
          style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.displayName,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (item.variant != null) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.variant!.size} / ${item.variant!.color}',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12,
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Original Price: \$${item.product.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Override Price',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.gray100,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Urbanist'),
            ),
          ),
          TextButton(
            onPressed: () {
              final price = double.tryParse(controller.text);
              if (price != null && price >= 0) {
                widget.shell.setPriceOverride(item.product.id, price);
                controller.dispose();
                Navigator.pop(context);
              }
            },
            child: const Text(
              'Apply',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              widget.shell.setPriceOverride(item.product.id, null);
              controller.dispose();
              Navigator.pop(context);
            },
            child: const Text(
              'Clear',
              style: TextStyle(
                fontFamily: 'Urbanist',
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.delete_outline, color: AppColors.warning, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Clear Cart?',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to clear all items from the cart? This action cannot be undone.',
          style: const TextStyle(fontFamily: 'Urbanist'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Urbanist'),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.shell.clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Clear Cart',
              style: TextStyle(fontFamily: 'Urbanist'),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePayment(String method) async {
    if (method == 'Cash') {
      _showCashDialog();
    } else {
      _processPayment(method, null);
    }
  }

  void _showCashDialog() {
    _cashController.text = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cash Payment',
          style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total: P${widget.shell.cartTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cashController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              autofocus: true,
              style: const TextStyle(fontFamily: 'Urbanist', fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Amount Received',
                prefixText: 'P ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Urbanist'),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final paid = double.tryParse(_cashController.text);
              if (paid == null || paid < widget.shell.cartTotal) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Insufficient amount',
                      style: TextStyle(fontFamily: 'Urbanist'),
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _processPayment('Cash', paid);
            },
            child: const Text(
              'Confirm',
              style: TextStyle(fontFamily: 'Urbanist', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _processPayment(String method, double? amountPaid) async {
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    final record = await widget.shell.completeSale(
      method,
      amountPaid: amountPaid,
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(record: record, shell: widget.shell),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = widget.shell.cart;

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
          'Checkout',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _showClearCartDialog,
            icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
            label: const Text(
              'Clear',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'Urbanist',
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: _processing
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'Processing payment...',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Order Summary header
                      Row(
                        children: [
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${widget.shell.cartCount} items',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Cart items
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ...cart.asMap().entries.map((e) {
                              final item = e.value;
                              final isLast = e.key == cart.length - 1;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: item.product.color
                                                .withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            item.product.icon,
                                            size: 20,
                                            color: item.product.color,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.displayName,
                                                style: const TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    'P${item.product.price.toStringAsFixed(2)} each',
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 12,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                  if (item.discount !=
                                                      null) ...[
                                                    const SizedBox(width: 4),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppColors.warning,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        item.discount!.name,
                                                        style: const TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Qty controls
                                        Row(
                                          children: [
                                            _QtyBtn(
                                              icon: Icons.remove,
                                              onTap: () =>
                                                  widget.shell.decrementQty(
                                                    item.product.id,
                                                  ),
                                            ),
                                            SizedBox(
                                              width: 32,
                                              child: Text(
                                                '${item.quantity}',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            _QtyBtn(
                                              icon: Icons.add,
                                              onTap: () =>
                                                  widget.shell.incrementQty(
                                                    item.product.id,
                                                  ),
                                              primary: true,
                                            ),
                                            const SizedBox(width: 4),
                                            GestureDetector(
                                              onTap: () =>
                                                  _showPriceOverrideDialog(
                                                    item,
                                                  ),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      item.priceOverride != null
                                                      ? AppColors.primary
                                                      : AppColors.gray100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.edit,
                                                  size: 16,
                                                  color:
                                                      item.priceOverride != null
                                                      ? Colors.white
                                                      : AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            GestureDetector(
                                              onTap: () =>
                                                  _showItemDiscountDialog(item),
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: item.discount != null
                                                      ? AppColors.warning
                                                      : AppColors.gray100,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Icon(
                                                  Icons.local_offer,
                                                  size: 16,
                                                  color: item.discount != null
                                                      ? Colors.white
                                                      : AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'P${item.subtotal.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isLast)
                                    Divider(
                                      height: 1,
                                      indent: 68,
                                      color: AppColors.divider,
                                    ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Totals
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _TotalRow(
                              label: 'Subtotal',
                              value:
                                  'P${widget.shell.cartSubtotal.toStringAsFixed(2)}',
                            ),
                            if (widget.shell.cartItemDiscounts > 0) ...[
                              const SizedBox(height: 4),
                              _TotalRow(
                                label: 'Item Discounts',
                                value:
                                    '-P${widget.shell.cartItemDiscounts.toStringAsFixed(2)}',
                                valueColor: AppColors.warning,
                              ),
                            ],
                            if (widget.shell.cartOrderDiscount > 0) ...[
                              const SizedBox(height: 4),
                              _TotalRow(
                                label: 'Order Discount',
                                value:
                                    '-P${widget.shell.cartOrderDiscount.toStringAsFixed(2)}',
                                valueColor: AppColors.warning,
                              ),
                            ],
                            const SizedBox(height: 8),
                            if (widget.shell.taxSettings.enabled) ...[
                              _TotalRow(
                                label: widget.shell.taxSettings.name,
                                value:
                                    'P${widget.shell.cartTaxAmount.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 4),
                            ],
                            Divider(color: Colors.grey[100]),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'TOTAL',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'P${widget.shell.cartTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            // Order discount button
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _showOrderDiscountDialog,
                                    icon: const Icon(
                                      Icons.local_offer,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Add Order Discount',
                                      style: TextStyle(fontFamily: 'Urbanist'),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textSecondary,
                                      side: BorderSide(color: AppColors.border),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _showTaxSettingsDialog,
                                    icon: const Icon(
                                      Icons.receipt_long,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Tax Settings',
                                      style: TextStyle(fontFamily: 'Urbanist'),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.textSecondary,
                                      side: BorderSide(color: AppColors.border),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Select Payment Method',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                // Preview receipt button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: OutlinedButton.icon(
                    onPressed: _showReceiptPreview,
                    icon: const Icon(Icons.receipt_long, size: 20),
                    label: const Text(
                      'Preview Receipt',
                      style: TextStyle(fontFamily: 'Urbanist'),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 50),
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                // Payment buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    children: [
                      _PaymentButton(
                        icon: Icons.payments_outlined,
                        label: 'Cash',
                        subtitle: 'Pay with physical cash',
                        color: AppColors.cash,
                        onTap: () => _handlePayment('Cash'),
                      ),
                      const SizedBox(height: 10),
                      _PaymentButton(
                        icon: Icons.qr_code,
                        label: 'GCash / Maya (QR)',
                        subtitle: 'Scan QR to pay',
                        color: AppColors.gcash,
                        onTap: () => _handlePayment('GCash/Maya'),
                      ),
                      const SizedBox(height: 10),
                      _PaymentButton(
                        icon: Icons.credit_card,
                        label: 'Card',
                        subtitle: 'Debit or credit card',
                        color: AppColors.card,
                        onTap: () => _handlePayment('Card'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool primary;
  const _QtyBtn({
    required this.icon,
    required this.onTap,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: primary ? AppColors.textOnPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _TotalRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Urbanist',
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _PaymentButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PaymentButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

// Dialogs for tax, discount, and payment
class _ItemDiscountDialog extends StatefulWidget {
  final CartItem item;
  final Function(Discount?) onApply;

  const _ItemDiscountDialog({required this.item, required this.onApply});

  @override
  State<_ItemDiscountDialog> createState() => _ItemDiscountDialogState();
}

class _ItemDiscountDialogState extends State<_ItemDiscountDialog> {
  Discount? _selectedDiscount;

  @override
  void initState() {
    super.initState();
    _selectedDiscount = widget.item.discount;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.item.product.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.item.product.icon,
              size: 20,
              color: widget.item.product.color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.item.product.name,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'P${widget.item.basePrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Discount',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DiscountChip(
                label: 'No Discount',
                isSelected: _selectedDiscount == null,
                onTap: () => setState(() => _selectedDiscount = null),
              ),
              ...Discount.predefinedItemDiscounts.map((discount) {
                final isSelected = _selectedDiscount?.name == discount.name;
                return _DiscountChip(
                  label: discount.name,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedDiscount = discount),
                );
              }),
            ],
          ),
          if (_selectedDiscount != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Discounted Price',
                    style: TextStyle(fontFamily: 'Urbanist', fontSize: 13),
                  ),
                  Text(
                    'P${(widget.item.basePrice - _selectedDiscount!.applyTo(widget.item.basePrice)).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(fontFamily: 'Urbanist')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            widget.onApply(_selectedDiscount);
            Navigator.pop(context);
          },
          child: const Text(
            'Apply',
            style: TextStyle(fontFamily: 'Urbanist', color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _OrderDiscountDialog extends StatefulWidget {
  final Discount? currentDiscount;
  final Function(Discount?) onApply;

  const _OrderDiscountDialog({
    required this.currentDiscount,
    required this.onApply,
  });

  @override
  State<_OrderDiscountDialog> createState() => _OrderDiscountDialogState();
}

class _OrderDiscountDialogState extends State<_OrderDiscountDialog> {
  Discount? _selectedDiscount;

  @override
  void initState() {
    super.initState();
    _selectedDiscount = widget.currentDiscount;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Order Discount',
        style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Discount',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DiscountChip(
                label: 'No Discount',
                isSelected: _selectedDiscount == null,
                onTap: () => setState(() => _selectedDiscount = null),
              ),
              ...Discount.predefinedOrderDiscounts.map((discount) {
                final isSelected = _selectedDiscount?.name == discount.name;
                return _DiscountChip(
                  label: discount.name,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedDiscount = discount),
                );
              }),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(fontFamily: 'Urbanist')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            widget.onApply(_selectedDiscount);
            Navigator.pop(context);
          },
          child: const Text(
            'Apply',
            style: TextStyle(fontFamily: 'Urbanist', color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _TaxSettingsDialog extends StatefulWidget {
  final TaxSettings currentSettings;
  final Function(TaxSettings) onApply;

  const _TaxSettingsDialog({
    required this.currentSettings,
    required this.onApply,
  });

  @override
  State<_TaxSettingsDialog> createState() => _TaxSettingsDialogState();
}

class _TaxSettingsDialogState extends State<_TaxSettingsDialog> {
  late bool _enabled;
  late double _rate;
  late String _name;
  final _rateController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _enabled = widget.currentSettings.enabled;
    _rate = widget.currentSettings.rate;
    _name = widget.currentSettings.name;
    _rateController.text = _rate.toStringAsFixed(2);
    _nameController.text = _name;
  }

  @override
  void dispose() {
    _rateController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Tax Settings',
        style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text(
              'Enable Tax',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              _enabled ? 'Tax will be applied to orders' : 'Tax is disabled',
              style: const TextStyle(fontFamily: 'Urbanist', fontSize: 12),
            ),
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _rateController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            enabled: _enabled,
            decoration: InputDecoration(
              labelText: 'Tax Rate (%)',
              suffixText: '%',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (value) {
              final parsed = double.tryParse(value);
              if (parsed != null) {
                setState(() => _rate = parsed);
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            enabled: _enabled,
            decoration: InputDecoration(
              labelText: 'Tax Name',
              hintText: 'e.g., VAT, GST, Sales Tax',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
            onChanged: (value) => setState(() => _name = value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(fontFamily: 'Urbanist')),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () {
            widget.onApply(
              TaxSettings(enabled: _enabled, rate: _rate, name: _name),
            );
            Navigator.pop(context);
          },
          child: const Text(
            'Apply',
            style: TextStyle(fontFamily: 'Urbanist', color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _DiscountChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DiscountChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
