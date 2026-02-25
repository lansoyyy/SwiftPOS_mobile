import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/error_handler.dart';
import '../../data/export/data_export_service.dart';
import '../main_shell.dart';

class ReportsScreen extends StatefulWidget {
  final MainShellState shell;
  const ReportsScreen({super.key, required this.shell});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final DataExportService _exportService = DataExportService();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Reports',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateFilter(),
                  const SizedBox(height: 24),
                  _buildReportCards(),
                  const SizedBox(height: 24),
                  _buildExportSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date Filter',
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
                child: _DateButton(
                  label: 'Start Date',
                  date: _startDate,
                  onTap: () => _selectStartDate(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateButton(
                  label: 'End Date',
                  date: _endDate,
                  onTap: () => _selectEndDate(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: _clearDateFilter,
            icon: const Icon(Icons.clear, size: 18),
            label: const Text(
              'Clear Filter',
              style: TextStyle(fontFamily: 'Urbanist'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Reports',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        _ReportCard(
          icon: Icons.receipt_long,
          title: 'Sales Report',
          description: 'Detailed sales transactions',
          color: AppColors.primary,
          onTap: () => _showSalesReport(),
        ),
        const SizedBox(height: 12),
        _ReportCard(
          icon: Icons.inventory_2,
          title: 'Inventory Report',
          description: 'Product stock and value',
          color: AppColors.success,
          onTap: () => _showInventoryReport(),
        ),
        const SizedBox(height: 12),
        _ReportCard(
          icon: Icons.account_balance,
          title: 'Financial Report',
          description: 'Revenue and profit analysis',
          color: Colors.orange,
          onTap: () => _showFinancialReport(),
        ),
        const SizedBox(height: 12),
        _ReportCard(
          icon: Icons.shopping_cart,
          title: 'Sale Items Report',
          description: 'Individual item sales',
          color: Colors.purple,
          onTap: () => _showSaleItemsReport(),
        ),
      ],
    );
  }

  Widget _buildExportSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Data',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _ExportButton(
            icon: Icons.table_chart,
            label: 'Export Sales (CSV)',
            onTap: () => _exportSalesCSV(),
          ),
          const SizedBox(height: 8),
          _ExportButton(
            icon: Icons.inventory,
            label: 'Export Products (CSV)',
            onTap: () => _exportProductsCSV(),
          ),
          const SizedBox(height: 8),
          _ExportButton(
            icon: Icons.description,
            label: 'Export All Data (JSON)',
            onTap: () => _exportJSON(),
          ),
          const SizedBox(height: 8),
          _ExportButton(
            icon: Icons.backup,
            label: 'Create Database Backup',
            onTap: () => _createBackup(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _clearDateFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _showSalesReport() async {
    setState(() => _isLoading = true);
    try {
      final csv = await _exportService.exportSalesToCSV(
        startDate: _startDate,
        endDate: _endDate,
      );
      await _showReportDialog('Sales Report', csv);
    } catch (e) {
      ErrorHandler.handleErrorWithDialog(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showInventoryReport() async {
    setState(() => _isLoading = true);
    try {
      final csv = await _exportService.exportInventoryReportToCSV();
      await _showReportDialog('Inventory Report', csv);
    } catch (e) {
      ErrorHandler.handleErrorWithDialog(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showFinancialReport() async {
    setState(() => _isLoading = true);
    try {
      final csv = await _exportService.exportFinancialReportToCSV(
        startDate: _startDate,
        endDate: _endDate,
      );
      await _showReportDialog('Financial Report', csv);
    } catch (e) {
      ErrorHandler.handleErrorWithDialog(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showSaleItemsReport() async {
    setState(() => _isLoading = true);
    try {
      final csv = await _exportService.exportSaleItemsToCSV(
        startDate: _startDate,
        endDate: _endDate,
      );
      await _showReportDialog('Sale Items Report', csv);
    } catch (e) {
      ErrorHandler.handleErrorWithDialog(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportSalesCSV() async {
    setState(() => _isLoading = true);
    try {
      final csv = await _exportService.exportSalesToCSV(
        startDate: _startDate,
        endDate: _endDate,
      );
      final filename = 'sales_${DateTime.now().millisecondsSinceEpoch}.csv';
      await _exportService.saveAndShareExport(csv, filename);
      ErrorHandler.showSuccessToast('Sales exported successfully');
    } catch (e) {
      ErrorHandler.handleErrorWithDialog(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportProductsCSV() async {
    setState(() => _isLoading = true);
    try {
      final csv = await _exportService.exportProductsToCSV();
      final filename = 'products_${DateTime.now().millisecondsSinceEpoch}.csv';
      await _exportService.saveAndShareExport(csv, filename);
      ErrorHandler.showSuccessToast('Products exported successfully');
    } catch (e) {
      ErrorHandler.handleErrorWithDialog(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _exportJSON() async {
    setState(() => _isLoading = true);
    try {
      final json = await _exportService.exportToJSON(
        startDate: _startDate,
        endDate: _endDate,
      );
      final filename =
          'swiftpos_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      await _exportService.saveAndShareExport(json, filename);
      ErrorHandler.showSuccessToast('Data exported successfully');
    } catch (e) {
      ErrorHandler.handleErrorWithDialog(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isLoading = true);
    try {
      final path = await _exportService.createDatabaseBackup();
      ErrorHandler.showSuccessToast('Backup created: $path');
    } catch (e) {
      ErrorHandler.handleErrorWithDialog(context, e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showReportDialog(String title, String content) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(
              content,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 12,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? DateFormat('MMM dd, yyyy').format(date!)
                  : 'Select date',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
                color: date != null ? AppColors.textPrimary : AppColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 13,
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ExportButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.gray300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.download, size: 18, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}
