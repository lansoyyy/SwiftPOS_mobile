import 'package:sqflite/sqflite.dart';
import '../../models/sale_record.dart';
import '../../models/cart_item.dart';
import '../../models/product.dart';
import '../database/database_service.dart';

/// Sale Record Repository - CRUD Operations for Sales
class SaleRecordRepository {
  final DatabaseService _databaseService = DatabaseService();

  // CREATE - Insert a new sale record with items
  Future<String> insertSale(SaleRecord sale) async {
    final db = await _databaseService.database;

    // Insert sale record
    await db.insert(
      DatabaseService.tableSales,
      sale.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert sale items
    final batch = db.batch();
    for (final item in sale.items) {
      batch.insert(
        DatabaseService.tableSaleItems,
        {
          'sale_id': sale.id,
          'product_id': item.product.id,
          'product_name': item.product.name,
          'quantity': item.quantity,
          'price': item.product.price,
          'subtotal': item.subtotal,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);

    return sale.id;
  }

  // READ - Get all sales
  Future<List<SaleRecord>> getAllSales() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> saleMaps = await db.query(
      DatabaseService.tableSales,
      orderBy: 'timestamp DESC',
    );

    List<SaleRecord> sales = [];
    for (final saleMap in saleMaps) {
      // Get items for this sale
      final List<Map<String, dynamic>> itemMaps = await db.query(
        DatabaseService.tableSaleItems,
        where: 'sale_id = ?',
        whereArgs: [saleMap['id']],
      );

      // Reconstruct CartItems from sale items
      List<CartItem> items = [];
      for (final itemMap in itemMaps) {
        // Get product for this item
        final productMaps = await db.query(
          DatabaseService.tableProducts,
          where: 'id = ?',
          whereArgs: [itemMap['product_id']],
          limit: 1,
        );

        if (productMaps.isNotEmpty) {
          final product = Product.fromMap(productMaps.first);
          items.add(
            CartItem(product: product, quantity: itemMap['quantity'] as int),
          );
        }
      }

      sales.add(SaleRecord.fromMap(saleMap, items));
    }

    return sales;
  }

  // READ - Get sale by ID
  Future<SaleRecord?> getSaleById(String id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> saleMaps = await db.query(
      DatabaseService.tableSales,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (saleMaps.isEmpty) return null;

    final saleMap = saleMaps.first;

    // Get items for this sale
    final List<Map<String, dynamic>> itemMaps = await db.query(
      DatabaseService.tableSaleItems,
      where: 'sale_id = ?',
      whereArgs: [id],
    );

    // Reconstruct CartItems from sale items
    List<CartItem> items = [];
    for (final itemMap in itemMaps) {
      // Get product for this item
      final productMaps = await db.query(
        DatabaseService.tableProducts,
        where: 'id = ?',
        whereArgs: [itemMap['product_id']],
        limit: 1,
      );

      if (productMaps.isNotEmpty) {
        final product = Product.fromMap(productMaps.first);
        items.add(
          CartItem(product: product, quantity: itemMap['quantity'] as int),
        );
      }
    }

    return SaleRecord.fromMap(saleMap, items);
  }

  // READ - Get today's sales
  Future<List<SaleRecord>> getTodaySales() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final db = await _databaseService.database;
    final List<Map<String, dynamic>> saleMaps = await db.query(
      DatabaseService.tableSales,
      where: 'timestamp >= ? AND timestamp < ?',
      whereArgs: [
        startOfDay.millisecondsSinceEpoch,
        endOfDay.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp DESC',
    );

    List<SaleRecord> sales = [];
    for (final saleMap in saleMaps) {
      // Get items for this sale
      final List<Map<String, dynamic>> itemMaps = await db.query(
        DatabaseService.tableSaleItems,
        where: 'sale_id = ?',
        whereArgs: [saleMap['id']],
      );

      // Reconstruct CartItems from sale items
      List<CartItem> items = [];
      for (final itemMap in itemMaps) {
        final productMaps = await db.query(
          DatabaseService.tableProducts,
          where: 'id = ?',
          whereArgs: [itemMap['product_id']],
          limit: 1,
        );

        if (productMaps.isNotEmpty) {
          final product = Product.fromMap(productMaps.first);
          items.add(
            CartItem(product: product, quantity: itemMap['quantity'] as int),
          );
        }
      }

      sales.add(SaleRecord.fromMap(saleMap, items));
    }

    return sales;
  }

  // READ - Get sales by date range
  Future<List<SaleRecord>> getSalesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> saleMaps = await db.query(
      DatabaseService.tableSales,
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp DESC',
    );

    List<SaleRecord> sales = [];
    for (final saleMap in saleMaps) {
      final List<Map<String, dynamic>> itemMaps = await db.query(
        DatabaseService.tableSaleItems,
        where: 'sale_id = ?',
        whereArgs: [saleMap['id']],
      );

      List<CartItem> items = [];
      for (final itemMap in itemMaps) {
        final productMaps = await db.query(
          DatabaseService.tableProducts,
          where: 'id = ?',
          whereArgs: [itemMap['product_id']],
          limit: 1,
        );

        if (productMaps.isNotEmpty) {
          final product = Product.fromMap(productMaps.first);
          items.add(
            CartItem(product: product, quantity: itemMap['quantity'] as int),
          );
        }
      }

      sales.add(SaleRecord.fromMap(saleMap, items));
    }

    return sales;
  }

  // READ - Get sales by payment method
  Future<List<SaleRecord>> getSalesByPaymentMethod(String paymentMethod) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> saleMaps = await db.query(
      DatabaseService.tableSales,
      where: 'payment_method = ?',
      whereArgs: [paymentMethod],
      orderBy: 'timestamp DESC',
    );

    List<SaleRecord> sales = [];
    for (final saleMap in saleMaps) {
      final List<Map<String, dynamic>> itemMaps = await db.query(
        DatabaseService.tableSaleItems,
        where: 'sale_id = ?',
        whereArgs: [saleMap['id']],
      );

      List<CartItem> items = [];
      for (final itemMap in itemMaps) {
        final productMaps = await db.query(
          DatabaseService.tableProducts,
          where: 'id = ?',
          whereArgs: [itemMap['product_id']],
          limit: 1,
        );

        if (productMaps.isNotEmpty) {
          final product = Product.fromMap(productMaps.first);
          items.add(
            CartItem(product: product, quantity: itemMap['quantity'] as int),
          );
        }
      }

      sales.add(SaleRecord.fromMap(saleMap, items));
    }

    return sales;
  }

  // UPDATE - Update a sale record
  Future<void> updateSale(SaleRecord sale) async {
    final db = await _databaseService.database;
    final map = sale.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      DatabaseService.tableSales,
      map,
      where: 'id = ?',
      whereArgs: [sale.id],
    );
  }

  // DELETE - Delete a sale record (with cascade to items)
  Future<void> deleteSale(String id) async {
    final db = await _databaseService.database;
    await db.delete(
      DatabaseService.tableSales,
      where: 'id = ?',
      whereArgs: [id],
    );
    // Items are deleted automatically due to CASCADE constraint
  }

  // DELETE - Delete multiple sales
  Future<void> deleteSales(List<String> ids) async {
    final db = await _databaseService.database;
    final batch = db.batch();
    for (final id in ids) {
      batch.delete(
        DatabaseService.tableSales,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }

  // DELETE - Delete all sales
  Future<void> deleteAllSales() async {
    final db = await _databaseService.database;
    await db.delete(DatabaseService.tableSales);
    // Items are deleted automatically due to CASCADE constraint
  }

  // COUNT - Get total sales count
  Future<int> getSalesCount() async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseService.tableSales}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // COUNT - Get today's sales count
  Future<int> getTodaySalesCount() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseService.tableSales} WHERE timestamp >= ? AND timestamp < ?',
      [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // SUM - Get total sales amount
  Future<double> getTotalSales() async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT SUM(total) as total FROM ${DatabaseService.tableSales}',
    );
    return (Sqflite.firstIntValue(result) ?? 0).toDouble();
  }

  // SUM - Get today's total sales
  Future<double> getTodayTotalSales() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT SUM(total) as total FROM ${DatabaseService.tableSales} WHERE timestamp >= ? AND timestamp < ?',
      [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
    );
    return (Sqflite.firstIntValue(result) ?? 0).toDouble();
  }

  // SUM - Get total sales by date range
  Future<double> getTotalSalesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT SUM(total) as total FROM ${DatabaseService.tableSales} WHERE timestamp >= ? AND timestamp <= ?',
      [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch],
    );
    return (Sqflite.firstIntValue(result) ?? 0).toDouble();
  }
}
