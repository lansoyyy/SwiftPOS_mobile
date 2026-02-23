import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/sale_record.dart';
import '../../core/constants/app_colors.dart';
import '../main_shell.dart';

class ReceiptScreen extends StatelessWidget {
  final SaleRecord record;
  final MainShellState shell;

  const ReceiptScreen({super.key, required this.record, required this.shell});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        title: const Text(
          'Receipt',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showPrintDialog(context),
            icon: const Icon(Icons.print_outlined),
            tooltip: 'Print Receipt',
          ),
          IconButton(
            onPressed: () => _showShareSheet(context),
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
          ),
        ],
      ),
      body: Column(
        children: [
          // Success banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: AppColors.surface,
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.success,
                  ),
                ),
                Text(
                  'via ${record.paymentMethod}',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Receipt paper
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top serrated edge
                    CustomPaint(
                      size: const Size(double.infinity, 12),
                      painter: _SerratedPainter(top: true),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        children: [
                          // Header
                          const Text(
                            'SwiftPOS',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Official Receipt',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 11,
                              color: Colors.grey[500],
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _DashedDivider(),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _ReceiptLabel(
                                'REF #',
                                record.id.substring(record.id.length - 6),
                              ),
                              _ReceiptLabel(
                                'DATE',
                                _formatDate(record.timestamp),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _ReceiptLabel(
                                'TIME',
                                _formatTime(record.timestamp),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _DashedDivider(),
                          const SizedBox(height: 10),
                          // Items
                          ...record.items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: const TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (item.discount != null) ...[
                                          Text(
                                            item.discount!.name,
                                            style: const TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 10,
                                              color: AppColors.warning,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                        Text(
                                          '${item.quantity} x P${item.product.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 11,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'P${item.subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          _DashedDivider(),
                          const SizedBox(height: 10),
                          // Totals
                          _ReceiptTotalRow(
                            label: 'Subtotal',
                            value: 'P${record.subtotal.toStringAsFixed(2)}',
                          ),
                          if (record.totalDiscount > 0) ...[
                            const SizedBox(height: 4),
                            _ReceiptTotalRow(
                              label: 'Discounts',
                              value:
                                  '-P${record.totalDiscount.toStringAsFixed(2)}',
                              valueColor: AppColors.warning,
                            ),
                          ],
                          if (record.taxAmount > 0) ...[
                            const SizedBox(height: 4),
                            _ReceiptTotalRow(
                              label: 'Tax',
                              value: 'P${record.taxAmount.toStringAsFixed(2)}',
                            ),
                          ],
                          const SizedBox(height: 8),
                          _DashedDivider(),
                          const SizedBox(height: 10),
                          // Total
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
                                'P${record.total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          if (record.amountPaid != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Cash Paid',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                Text(
                                  'P${record.amountPaid!.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Change',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                Text(
                                  'P${record.change!.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 12,
                                    color: AppColors.success,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 10),
                          _DashedDivider(),
                          const SizedBox(height: 14),
                          Text(
                            'Thank you for your purchase!',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Powered by SwiftPOS',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 10,
                              color: Colors.grey[400],
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    // Bottom serrated edge
                    CustomPaint(
                      size: const Size(double.infinity, 12),
                      painter: _SerratedPainter(top: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showPrintDialog(context),
                    icon: const Icon(Icons.print_outlined, size: 20),
                    label: const Text(
                      'Print Receipt',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showShareSheet(context),
                    icon: const Icon(Icons.share_outlined, size: 20),
                    label: const Text(
                      'Share Receipt',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6366F1),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF6366F1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPrintDialog(BuildContext context) async {
    final isPrinterConnected = shell.isPrinterConnected;

    if (!isPrinterConnected) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.print, color: Colors.grey),
              SizedBox(width: 8),
              Text(
                'No Printer Connected',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: const Text(
            'Go to Settings to connect a thermal printer.',
            style: TextStyle(fontFamily: 'Urbanist'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(fontFamily: 'Urbanist')),
            ),
          ],
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text(
              'Printing...',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Sending receipt to ${shell.connectedPrinter}...',
          style: const TextStyle(fontFamily: 'Urbanist'),
        ),
      ),
    );

    // Print the receipt
    final success = await shell.printReceipt(record);

    // Close loading dialog
    if (context.mounted) {
      Navigator.pop(context);
    }

    // Show result
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? AppColors.success : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                success ? 'Print Successful' : 'Print Failed',
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            success
                ? 'Receipt has been sent to the printer.'
                : 'Failed to send receipt to the printer. Please try again.',
            style: const TextStyle(fontFamily: 'Urbanist'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(fontFamily: 'Urbanist')),
            ),
          ],
        ),
      );
    }
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share Receipt',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            _ShareOption(
              icon: Icons.message,
              label: 'SMS',
              color: const Color(0xFF10B981),
            ),
            _ShareOption(
              icon: Icons.chat_bubble_outline,
              label: 'Messenger',
              color: const Color(0xFF3B82F6),
            ),
            _ShareOption(
              icon: Icons.email_outlined,
              label: 'Email',
              color: const Color(0xFFEA580C),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () => Navigator.pop(context),
    );
  }
}

class _ReceiptLabel extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptLabel(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ReceiptTotalRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _ReceiptTotalRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(
            count,
            (_) => Container(
              width: dashWidth,
              height: 1,
              margin: const EdgeInsets.only(right: dashSpace),
              color: Colors.grey[300],
            ),
          ),
        );
      },
    );
  }
}

class _SerratedPainter extends CustomPainter {
  final bool top;
  const _SerratedPainter({required this.top});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFF8F9FB);
    final path = Path();
    const r = 6.0;
    if (top) {
      path.moveTo(0, r);
      double x = 0;
      while (x < size.width) {
        path.arcToPoint(
          Offset(x + r * 2, r),
          radius: const Radius.circular(r),
          clockwise: false,
        );
        x += r * 2;
      }
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    } else {
      path.moveTo(0, 0);
      double x = 0;
      while (x < size.width) {
        path.arcToPoint(
          Offset(x + r * 2, 0),
          radius: const Radius.circular(r),
          clockwise: true,
        );
        x += r * 2;
      }
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
