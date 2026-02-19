import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../main_shell.dart';
import '../receipt/receipt_screen.dart';

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
    final total = widget.shell.cartTotal;

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
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Clear Cart',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  content: const Text(
                    'Remove all items from cart?',
                    style: TextStyle(fontFamily: 'Urbanist'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'No',
                        style: TextStyle(fontFamily: 'Urbanist'),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.shell.clearCart();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
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
                                                item.product.name,
                                                style: const TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'P${item.product.price.toStringAsFixed(2)} each',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 12,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
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
                                                  widget.shell.updateQty(
                                                    item.product.id,
                                                    item.quantity - 1,
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
                                                  widget.shell.updateQty(
                                                    item.product.id,
                                                    item.quantity + 1,
                                                  ),
                                              primary: true,
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
                              value: 'P${total.toStringAsFixed(2)}',
                            ),
                            const SizedBox(height: 8),
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
                                  'P${total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: AppColors.primary,
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
  const _TotalRow({required this.label, required this.value});

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
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
            fontSize: 14,
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
