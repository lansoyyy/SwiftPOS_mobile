import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../database/database_service.dart';
import '../repositories/product_repository.dart';
import '../repositories/sale_record_repository.dart';
import '../../models/product.dart';
import '../../models/sale_record.dart';

/// Data Export Service - Handles exporting data to CSV/JSON and backup
class DataExportService {
  static final DataExportService _instance = DataExportService._internal();
  factory DataExportService() => _instance;
  DataExportService._internal();

  final DatabaseService _databaseService = DatabaseService();
  final ProductRepository _productRepo = ProductRepository();
  final SaleRecordRepository _saleRepo = SaleRecordRepository();

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  final DateFormat _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Export all products to CSV
  Future<String> exportProductsToCSV() async {
    try {
      final products = await _productRepo.getAllProducts();
      final buffer = StringBuffer();

      // CSV Header
      buffer.writeln(
        'ID,Name,Category,Price,Stock,Barcode,Created At,Updated At',
      );

      // CSV Data
      for (final product in products) {
        buffer.writeln(
          '${_escapeCSV(product.id)},'
          '${_escapeCSV(product.name)},'
          '${_escapeCSV(product.category)},'
          '${product.price.toStringAsFixed(2)},'
          '${product.stock},'
          '${_escapeCSV(product.barcode ?? '')},'
          '${_formatTimestamp(product.id.hashCode)},'
          '${_formatTimestamp(product.id.hashCode)}',
        );
      }

      return buffer.toString();
    } catch (e) {
      throw ExportException('Failed to export products: ${e.toString()}');
    }
  }

  /// Export sales to CSV
  Future<String> exportSalesToCSV({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sales = await _saleRepo.getAllSales();
      final filteredSales = _filterSalesByDate(sales, startDate, endDate);
      final buffer = StringBuffer();

      // CSV Header
      buffer.writeln(
        'Sale ID,Date,Time,Payment Method,Items Count,Subtotal,Discount,Tax,Total,Amount Paid,Change',
      );

      // CSV Data
      for (final sale in filteredSales) {
        buffer.writeln(
          '${_escapeCSV(sale.id)},'
          '${_dateFormat.format(sale.timestamp)},'
          '${_dateTimeFormat.format(sale.timestamp).split(' ')[1]},'
          '${_escapeCSV(sale.paymentMethod)},'
          '${sale.totalItems},'
          '${sale.subtotal.toStringAsFixed(2)},'
          '${sale.totalDiscount.toStringAsFixed(2)},'
          '${sale.taxAmount.toStringAsFixed(2)},'
          '${sale.total.toStringAsFixed(2)},'
          '${sale.amountPaid?.toStringAsFixed(2) ?? ''},'
          '${sale.change?.toStringAsFixed(2) ?? ''}',
        );
      }

      return buffer.toString();
    } catch (e) {
      throw ExportException('Failed to export sales: ${e.toString()}');
    }
  }

  /// Export sale items to CSV
  Future<String> exportSaleItemsToCSV({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sales = await _saleRepo.getAllSales();
      final filteredSales = _filterSalesByDate(sales, startDate, endDate);
      final buffer = StringBuffer();

      // CSV Header
      buffer.writeln(
        'Sale ID,Sale Date,Product ID,Product Name,Quantity,Price,Subtotal',
      );

      // CSV Data
      for (final sale in filteredSales) {
        for (final item in sale.items) {
          buffer.writeln(
            '${_escapeCSV(sale.id)},'
            '${_dateFormat.format(sale.timestamp)},'
            '${_escapeCSV(item.product.id)},'
            '${_escapeCSV(item.product.name)},'
            '${item.quantity},'
            '${item.product.price.toStringAsFixed(2)},'
            '${item.subtotal.toStringAsFixed(2)}',
          );
        }
      }

      return buffer.toString();
    } catch (e) {
      throw ExportException('Failed to export sale items: ${e.toString()}');
    }
  }

  /// Export inventory report to CSV
  Future<String> exportInventoryReportToCSV() async {
    try {
      final products = await _productRepo.getAllProducts();
      final buffer = StringBuffer();

      // CSV Header
      buffer.writeln('ID,Name,Category,Price,Stock,Status,Total Value');

      // CSV Data
      for (final product in products) {
        final status = _getStockStatus(product.stock);
        final totalValue = product.price * product.stock;
        buffer.writeln(
          '${_escapeCSV(product.id)},'
          '${_escapeCSV(product.name)},'
          '${_escapeCSV(product.category)},'
          '${product.price.toStringAsFixed(2)},'
          '${product.stock},'
          '${_escapeCSV(status)},'
          '${totalValue.toStringAsFixed(2)}',
        );
      }

      return buffer.toString();
    } catch (e) {
      throw ExportException(
        'Failed to export inventory report: ${e.toString()}',
      );
    }
  }

  /// Export financial report to CSV
  Future<String> exportFinancialReportToCSV({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final sales = await _saleRepo.getAllSales();
      final filteredSales = _filterSalesByDate(sales, startDate, endDate);
      final buffer = StringBuffer();

      // Calculate totals
      final totalRevenue = filteredSales.fold<double>(
        0,
        (sum, s) => sum + s.total,
      );
      final totalDiscounts = filteredSales.fold<double>(
        0,
        (sum, s) => sum + s.totalDiscount,
      );
      final totalTax = filteredSales.fold<double>(
        0,
        (sum, s) => sum + s.taxAmount,
      );
      final totalItems = filteredSales.fold<int>(
        0,
        (sum, s) => sum + s.totalItems,
      );
      final avgOrderValue = filteredSales.isNotEmpty
          ? totalRevenue / filteredSales.length
          : 0.0;

      // CSV Header
      buffer.writeln('Metric,Value');

      // CSV Data
      buffer.writeln('Total Sales,${filteredSales.length}');
      buffer.writeln('Total Items Sold,$totalItems');
      buffer.writeln('Total Revenue,${totalRevenue.toStringAsFixed(2)}');
      buffer.writeln('Total Discounts,${totalDiscounts.toStringAsFixed(2)}');
      buffer.writeln('Total Tax,${totalTax.toStringAsFixed(2)}');
      buffer.writeln(
        'Net Revenue,${(totalRevenue - totalDiscounts).toStringAsFixed(2)}',
      );
      buffer.writeln('Average Order Value,${avgOrderValue.toStringAsFixed(2)}');
      buffer.writeln(
        'Report Generated,${_dateTimeFormat.format(DateTime.now())}',
      );
      buffer.writeln(
        'Period Start,${startDate != null ? _dateFormat.format(startDate) : 'All Time'}',
      );
      buffer.writeln(
        'Period End,${endDate != null ? _dateFormat.format(endDate) : 'All Time'}',
      );

      return buffer.toString();
    } catch (e) {
      throw ExportException(
        'Failed to export financial report: ${e.toString()}',
      );
    }
  }

  /// Export all data to JSON (full backup)
  Future<String> exportToJSON({DateTime? startDate, DateTime? endDate}) async {
    try {
      final products = await _productRepo.getAllProducts();
      final sales = await _saleRepo.getAllSales();
      final filteredSales = _filterSalesByDate(sales, startDate, endDate);

      final exportData = {
        'version': '1.0.0',
        'exported_at': DateTime.now().toIso8601String(),
        'period': {
          'start': startDate?.toIso8601String(),
          'end': endDate?.toIso8601String(),
        },
        'summary': {
          'total_products': products.length,
          'total_sales': filteredSales.length,
          'total_revenue': filteredSales.fold<double>(
            0,
            (sum, s) => sum + s.total,
          ),
        },
        'products': products.map((p) => _productToJSON(p)).toList(),
        'sales': filteredSales.map((s) => _saleToJSON(s)).toList(),
      };

      return _formatJSON(exportData);
    } catch (e) {
      throw ExportException('Failed to export JSON: ${e.toString()}');
    }
  }

  /// Save export to file
  Future<String> saveExport(String content, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/$filename';
      final file = File(path);
      await file.writeAsString(content);
      return path;
    } catch (e) {
      throw ExportException('Failed to save export: ${e.toString()}');
    }
  }

  /// Save export to file and share
  Future<void> saveAndShareExport(String content, String filename) async {
    try {
      final path = await saveExport(content, filename);
      await Share.shareXFiles([
        XFile(path),
      ], subject: 'SwiftPOS Export - $filename');
    } catch (e) {
      throw ExportException('Failed to save and share: ${e.toString()}');
    }
  }

  /// Create database backup file
  Future<String> createDatabaseBackup() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final dbPath = '${directory.path}/swiftpos.db';
      final dbFile = File(dbPath);

      if (!await dbFile.exists()) {
        throw ExportException('Database file not found');
      }

      final backupPath =
          '${directory.path}/swiftpos_backup_${DateTime.now().millisecondsSinceEpoch}.db';
      await dbFile.copy(backupPath);

      return backupPath;
    } catch (e) {
      throw ExportException('Failed to create backup: ${e.toString()}');
    }
  }

  /// Get export statistics
  Future<ExportStatistics> getExportStatistics() async {
    try {
      final products = await _productRepo.getAllProducts();
      final sales = await _saleRepo.getAllSales();

      final totalRevenue = sales.fold<double>(0, (sum, s) => sum + s.total);
      final totalItems = sales.fold<int>(0, (sum, s) => sum + s.totalItems);
      final totalInventoryValue = products.fold<double>(
        0,
        (sum, p) => sum + (p.price * p.stock),
      );

      return ExportStatistics(
        totalProducts: products.length,
        totalSales: sales.length,
        totalRevenue: totalRevenue,
        totalItemsSold: totalItems,
        totalInventoryValue: totalInventoryValue,
        lowStockCount: products.where((p) => p.stock <= 5).length,
        outOfStockCount: products.where((p) => p.stock == 0).length,
      );
    } catch (e) {
      throw ExportException('Failed to get statistics: ${e.toString()}');
    }
  }

  // Helper Methods

  String _escapeCSV(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  String _formatTimestamp(int timestamp) {
    return _dateTimeFormat.format(
      DateTime.fromMillisecondsSinceEpoch(timestamp.abs()),
    );
  }

  String _getStockStatus(int stock) {
    if (stock == 0) return 'Out of Stock';
    if (stock <= 5) return 'Low Stock';
    return 'In Stock';
  }

  List<SaleRecord> _filterSalesByDate(
    List<SaleRecord> sales,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null && endDate == null) return sales;

    return sales.where((sale) {
      if (startDate != null && sale.timestamp.isBefore(startDate)) return false;
      if (endDate != null && sale.timestamp.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  Map<String, dynamic> _productToJSON(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'category': product.category,
      'price': product.price,
      'stock': product.stock,
      'barcode': product.barcode,
      'icon_code': product.icon.codePoint,
      'color_value': product.color.value,
      'variants': product.variants.map((v) => v.toMap()).toList(),
    };
  }

  Map<String, dynamic> _saleToJSON(SaleRecord sale) {
    return {
      'id': sale.id,
      'timestamp': sale.timestamp.toIso8601String(),
      'payment_method': sale.paymentMethod,
      'subtotal': sale.subtotal,
      'total_discount': sale.totalDiscount,
      'tax_amount': sale.taxAmount,
      'total': sale.total,
      'amount_paid': sale.amountPaid,
      'change': sale.change,
      'items': sale.items
          .map(
            (item) => {
              'product_id': item.product.id,
              'product_name': item.product.name,
              'quantity': item.quantity,
              'price': item.product.price,
              'subtotal': item.subtotal,
            },
          )
          .toList(),
    };
  }

  String _formatJSON(Map<String, dynamic> data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }
}

/// Export Exception
class ExportException implements Exception {
  final String message;
  ExportException(this.message);

  @override
  String toString() => message;
}

/// Export Statistics
class ExportStatistics {
  final int totalProducts;
  final int totalSales;
  final double totalRevenue;
  final int totalItemsSold;
  final double totalInventoryValue;
  final int lowStockCount;
  final int outOfStockCount;

  ExportStatistics({
    required this.totalProducts,
    required this.totalSales,
    required this.totalRevenue,
    required this.totalItemsSold,
    required this.totalInventoryValue,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'total_products': totalProducts,
      'total_sales': totalSales,
      'total_revenue': totalRevenue,
      'total_items_sold': totalItemsSold,
      'total_inventory_value': totalInventoryValue,
      'low_stock_count': lowStockCount,
      'out_of_stock_count': outOfStockCount,
    };
  }
}
