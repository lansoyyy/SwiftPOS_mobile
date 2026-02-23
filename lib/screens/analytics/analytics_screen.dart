import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../main_shell.dart';
import '../../models/sale_record.dart';

class AnalyticsScreen extends StatefulWidget {
  final MainShellState shell;
  const AnalyticsScreen({super.key, required this.shell});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  DateTime _selectedDate = DateTime.now();
  String _period = 'day'; // day, week, month, year

  @override
  Widget build(BuildContext context) {
    final sales = widget.shell.salesHistory;
    final filteredSales = _filterSalesByPeriod(sales);
    final dailyTotals = _calculateDailyTotals(filteredSales);
    final productStats = _calculateProductStats(filteredSales);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Analytics',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'export') {
                _showExportDialog(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Export Data',
                      style: TextStyle(fontFamily: 'Urbanist'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Period selector
          _buildPeriodSelector(),
          // Date picker
          _buildDatePicker(),
          // Summary cards
          _buildSummaryCards(filteredSales, dailyTotals),
          const SizedBox(height: 16),
          // Charts
          _buildSalesChart(dailyTotals),
          const SizedBox(height: 16),
          // Product performance
          _buildProductPerformance(productStats),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _PeriodChip(
            label: 'Day',
            isSelected: _period == 'day',
            onTap: () => setState(() => _period = 'day'),
          ),
          const SizedBox(width: 8),
          _PeriodChip(
            label: 'Week',
            isSelected: _period == 'week',
            onTap: () => setState(() => _period = 'week'),
          ),
          const SizedBox(width: 8),
          _PeriodChip(
            label: 'Month',
            isSelected: _period == 'month',
            onTap: () => setState(() => _period = 'month'),
          ),
          const SizedBox(width: 8),
          _PeriodChip(
            label: 'Year',
            isSelected: _period == 'year',
            onTap: () => setState(() => _period = 'year'),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: GestureDetector(
        onTap: () => _selectDate(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                _formatDate(_selectedDate),
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(
    List<SaleRecord> sales,
    Map<String, double> dailyTotals,
  ) {
    final totalSales = sales.length;
    final totalRevenue = sales.fold<double>(0, (sum, r) => sum + r.total);
    final avgOrderValue = totalSales > 0 ? totalRevenue / totalSales : 0.0;
    final topDay = dailyTotals.entries.isNotEmpty
        ? dailyTotals.entries.reduce((a, b) => a.value > b.value ? a : b)
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Total Sales',
                  value: '$totalSales',
                  icon: Icons.receipt_long,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Total Revenue',
                  value: 'P${totalRevenue.toStringAsFixed(2)}',
                  icon: Icons.payments,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Avg Order',
                  value: 'P${avgOrderValue.toStringAsFixed(2)}',
                  icon: Icons.shopping_cart,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Best Day',
                  value: topDay != null ? 'N/A' : _formatDateShort(topDay!.key),
                  icon: Icons.trending_up,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart(Map<String, double> dailyTotals) {
    final entries = dailyTotals.entries.toList();
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxValue = entries
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    final chartData = entries.take(7).toList(); // Last 7 days

    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sales Trend (Last 7 Days)',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: CustomPaint(
                  painter: _SalesChartPainter(
                    data: chartData,
                    maxValue: maxValue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductPerformance(Map<String, _ProductStats> productStats) {
    final sortedProducts = productStats.entries.toList()
      ..sort((a, b) => b.value.totalSold.compareTo(a.value.totalSold));
    final topProducts = sortedProducts.take(5).toList();
    final worstProducts = sortedProducts.reversed.take(5).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Product Performance',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ProductListCard(
                  title: 'Top Selling',
                  products: topProducts,
                  color: AppColors.success,
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ProductListCard(
                  title: 'Low Performing',
                  products: worstProducts,
                  color: AppColors.error,
                  icon: Icons.trending_down,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<SaleRecord> _filterSalesByPeriod(List<SaleRecord> sales) {
    final now = DateTime.now();
    switch (_period) {
      case 'day':
        return sales
            .where(
              (s) =>
                  s.timestamp.year == now.year &&
                  s.timestamp.month == now.month &&
                  s.timestamp.day == now.day,
            )
            .toList();
      case 'week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return sales
            .where(
              (s) =>
                  s.timestamp.isAfter(weekStart) &&
                  s.timestamp.isBefore(now.add(const Duration(days: 1))),
            )
            .toList();
      case 'month':
        return sales
            .where(
              (s) =>
                  s.timestamp.year == now.year &&
                  s.timestamp.month == now.month,
            )
            .toList();
      case 'year':
        return sales.where((s) => s.timestamp.year == now.year).toList();
      default:
        return sales;
    }
  }

  Map<String, double> _calculateDailyTotals(List<SaleRecord> sales) {
    final totals = <String, double>{};
    for (final sale in sales) {
      final key =
          '${sale.timestamp.year}-${sale.timestamp.month}-${sale.timestamp.day}';
      totals[key] = (totals[key] ?? 0) + sale.total;
    }
    return totals;
  }

  Map<String, _ProductStats> _calculateProductStats(List<SaleRecord> sales) {
    final stats = <String, _ProductStats>{};
    for (final sale in sales) {
      for (final item in sale.items) {
        final productId = item.product.id;
        final productName = item.product.name;
        if (!stats.containsKey(productId)) {
          stats[productId] = _ProductStats(
            productId: productId,
            productName: productName,
            totalSold: 0,
            totalRevenue: 0,
          );
        }
        stats[productId] = _ProductStats(
          productId: productId,
          productName: productName,
          totalSold: stats[productId]!.totalSold + item.quantity,
          totalRevenue: stats[productId]!.totalRevenue + item.subtotal,
        );
      }
    }
    return stats;
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _showExportDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Export Data',
          style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart, color: AppColors.primary),
              title: const Text(
                'Export as CSV',
                style: TextStyle(fontFamily: 'Urbanist'),
              ),
              onTap: () {
                Navigator.pop(context);
                _exportAsCSV();
              },
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
        ],
      ),
    );
  }

  void _exportAsCSV() {
    final sales = widget.shell.salesHistory;
    if (sales.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No sales data to export')));
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln(
      'Date,Time,Items,Total,Discount,Tax,Payment Method,Amount Paid,Change',
    );

    for (final sale in sales) {
      final date = DateFormat('yyyy-MM-dd').format(sale.timestamp);
      final time = DateFormat('HH:mm:ss').format(sale.timestamp);
      final items = sale.items
          .map((i) => '${i.product.name} x${i.quantity}')
          .join('; ');
      final discount = sale.totalDiscount > 0
          ? '-P${sale.totalDiscount.toStringAsFixed(2)}'
          : '';
      final tax = sale.taxAmount > 0
          ? 'P${sale.taxAmount.toStringAsFixed(2)}'
          : '';
      final paymentMethod = sale.paymentMethods.isNotEmpty
          ? sale.paymentMethods.join('/')
          : sale.paymentMethod;
      final amountPaid = sale.amountPaid?.toStringAsFixed(2) ?? '';
      final change = sale.change?.toStringAsFixed(2) ?? '';

      buffer.writeln(
        '$date,$time,$items,P${sale.total.toStringAsFixed(2)},$discount,$tax,$paymentMethod,$amountPaid,$change',
      );
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'CSV exported with ${sales.length} records',
          style: const TextStyle(fontFamily: 'Urbanist'),
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return DateFormat('MMM dd, yyyy').format(dt);
  }

  String _formatDateShort(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length != 3) return dateKey;
    final month = int.tryParse(parts[1]) ?? 1;
    final day = int.tryParse(parts[2]) ?? 1;
    return '${_monthName(month)} $day';
  }

  String _monthName(int month) {
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
    return months[month - 1];
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PeriodChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductStats {
  final String productId;
  final String productName;
  final int totalSold;
  final double totalRevenue;

  _ProductStats({
    required this.productId,
    required this.productName,
    required this.totalSold,
    required this.totalRevenue,
  });
}

class _ProductListCard extends StatelessWidget {
  final String title;
  final List<MapEntry<String, _ProductStats>> products;
  final Color color;
  final IconData icon;

  const _ProductListCard({
    required this.title,
    required this.products,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...products.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.value.productName,
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${entry.value.totalSold} sold',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'P${entry.value.totalRevenue.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: color,
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

class _SalesChartPainter extends CustomPainter {
  final List<MapEntry<String, double>> data;
  final double maxValue;

  _SalesChartPainter({required this.data, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - 40;
    final barWidth = chartWidth / data.length;
    final maxValue = this.maxValue > 0 ? this.maxValue : 1.0;

    // Draw bars
    for (int i = 0; i < data.length; i++) {
      final value = data[i].value;
      final barHeight = (value / maxValue) * chartHeight;
      final x = padding + (i * barWidth) + (barWidth * 0.1);
      final y = size.height - barHeight - 10;

      final paint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill;

      final barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth * 0.8, barHeight),
        const Radius.circular(4),
      );

      canvas.drawRRect(barRect, paint);
    }

    // Draw baseline
    final baselinePaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(padding, size.height - 10),
      Offset(size.width - padding, size.height - 10),
      baselinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SalesChartPainter oldDelegate) => true;
}
