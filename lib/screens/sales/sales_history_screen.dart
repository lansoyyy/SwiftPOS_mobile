import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/sale_record.dart';
import '../../core/constants/app_colors.dart';
import '../main_shell.dart';
import '../receipt/receipt_screen.dart';

class SalesHistoryScreen extends StatefulWidget {
  final MainShellState shell;
  const SalesHistoryScreen({super.key, required this.shell});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  String _dateFilter = 'Today';

  static const _filters = ['Today', 'All Time'];

  List<SaleRecord> get _filtered {
    if (_dateFilter == 'Today') return widget.shell.todaySales;
    return widget.shell.salesHistory;
  }

  double get _filteredTotal => _filtered.fold(0.0, (s, r) => s + r.total);

  Color _methodColor(String method) {
    switch (method) {
      case 'Cash':
        return AppColors.cash;
      case 'GCash/Maya':
        return AppColors.gcash;
      case 'Card':
        return AppColors.card;
      default:
        return AppColors.gray400;
    }
  }

  IconData _methodIcon(String method) {
    switch (method) {
      case 'Cash':
        return Icons.payments_outlined;
      case 'GCash/Maya':
        return Icons.qr_code;
      case 'Card':
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }

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
    return '${months[dt.month - 1]} ${dt.day}';
  }

  Future<void> _reprintLastReceipt() async {
    final sales = widget.shell.salesHistory;
    if (sales.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No sales history available')),
        );
      }
      return;
    }

    final lastSale = sales.last;

    if (!widget.shell.isPrinterConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No printer connected. Go to Settings to connect a printer.',
            ),
          ),
        );
      }
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
          'Reprinting receipt to ${widget.shell.connectedPrinter}...',
          style: const TextStyle(fontFamily: 'Urbanist'),
        ),
      ),
    );

    // Print the receipt
    final success = await widget.shell.printReceipt(lastSale);

    // Close loading dialog
    if (mounted) {
      Navigator.pop(context);
    }

    // Show result
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Receipt reprinted successfully'
                : 'Failed to reprint receipt',
          ),
          backgroundColor: success ? AppColors.success : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sales = _filtered;
    final total = _filteredTotal;
    final txCount = sales.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildHeroCard(total, txCount),
            _buildFilterTabs(),
            _buildSummaryRow(sales),
            Expanded(child: _buildList(sales)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sales',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Track your earnings',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _reprintLastReceipt,
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Reprint Last Receipt',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryBg,
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(double total, int txCount) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                _dateFilter == 'Today' ? "Today's Sales" : 'All Time Sales',
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'P${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w800,
              fontSize: 36,
              color: AppColors.surface,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatChip(
                label: '$txCount transactions',
                icon: Icons.receipt_outlined,
              ),
              const SizedBox(width: 8),
              if (txCount > 0)
                _StatChip(
                  label: 'Avg P${(total / txCount).toStringAsFixed(0)}',
                  icon: Icons.trending_up,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: _filters.map((f) {
          final selected = _dateFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _dateFilter = f),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  f,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.textOnPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryRow(List<SaleRecord> sales) {
    if (sales.isEmpty) return const SizedBox.shrink();
    final cashTotal = sales
        .where((s) => s.paymentMethod == 'Cash')
        .fold(0.0, (s, r) => s + r.total);
    final qrTotal = sales
        .where((s) => s.paymentMethod == 'GCash/Maya')
        .fold(0.0, (s, r) => s + r.total);
    final cardTotal = sales
        .where((s) => s.paymentMethod == 'Card')
        .fold(0.0, (s, r) => s + r.total);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        children: [
          if (cashTotal > 0)
            Expanded(
              child: _MethodSummary(
                label: 'Cash',
                amount: cashTotal,
                color: AppColors.cash,
              ),
            ),
          if (cashTotal > 0 && (qrTotal > 0 || cardTotal > 0))
            const SizedBox(width: 8),
          if (qrTotal > 0)
            Expanded(
              child: _MethodSummary(
                label: 'GCash',
                amount: qrTotal,
                color: AppColors.gcash,
              ),
            ),
          if (qrTotal > 0 && cardTotal > 0) const SizedBox(width: 8),
          if (cardTotal > 0)
            Expanded(
              child: _MethodSummary(
                label: 'Card',
                amount: cardTotal,
                color: AppColors.card,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList(List<SaleRecord> sales) {
    if (sales.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.gray300,
            ),
            const SizedBox(height: 12),
            Text(
              'No sales recorded yet',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 15,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Start selling from the Catalog tab',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 13,
                color: AppColors.gray300,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      itemCount: sales.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final s = sales[i];
        final color = _methodColor(s.paymentMethod);
        final icon = _methodIcon(s.paymentMethod);
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReceiptScreen(record: s, shell: widget.shell),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            s.paymentMethod,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s.paymentMethod,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${s.totalItems} item${s.totalItems > 1 ? 's' : ''} · ${_formatDate(s.timestamp)}, ${_formatTime(s.timestamp)}',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s.items.map((i) => i.product.name).take(2).join(', ') +
                            (s.items.length > 2 ? '...' : ''),
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 11,
                          color: AppColors.textTertiary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'P${s.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _StatChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white70),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 12,
              color: AppColors.surface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodSummary extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  const _MethodSummary({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'P${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
