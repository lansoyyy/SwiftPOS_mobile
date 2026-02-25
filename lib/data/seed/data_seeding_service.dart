import 'package:sqflite/sqflite.dart';
import '../database/database_service.dart';
import '../../data/sample_data.dart';
import '../../models/product.dart';

/// Data Seeding Service - Handles initial data seeding
class DataSeedingService {
  static final DataSeedingService _instance = DataSeedingService._internal();
  factory DataSeedingService() => _instance;
  DataSeedingService._internal();

  final DatabaseService _databaseService = DatabaseService();

  static const String _isSeededKey = 'is_data_seeded';

  /// Check if data has been seeded
  Future<bool> isDataSeeded() async {
    try {
      final db = await _databaseService.database;
      final result = await db.query(
        DatabaseService.tableSettings,
        where: 'key = ?',
        whereArgs: [_isSeededKey],
        limit: 1,
      );
      return result.isNotEmpty && result.first['value'] == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Mark data as seeded
  Future<void> _markAsSeeded() async {
    try {
      final db = await _databaseService.database;
      await db.insert(
        DatabaseService.tableSettings,
        {
          'key': _isSeededKey,
          'value': 'true',
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      // Ignore errors when marking as seeded
    }
  }

  /// Seed initial data
  Future<void> seedData() async {
    try {
      // Check if already seeded
      if (await isDataSeeded()) {
        return;
      }

      final db = await _databaseService.database;

      // Seed products
      await _seedProducts(db);

      // Mark as seeded
      await _markAsSeeded();
    } catch (e) {
      throw SeedingException('Failed to seed data: ${e.toString()}');
    }
  }

  /// Seed products from sample data
  Future<void> _seedProducts(Database db) async {
    final batch = db.batch();

    for (final product in sampleProducts) {
      batch.insert(
        DatabaseService.tableProducts,
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    await batch.commit(noResult: true);
  }

  /// Force re-seed data (useful for testing)
  Future<void> forceReseed() async {
    try {
      final db = await _databaseService.database;

      // Clear products
      await db.delete(DatabaseService.tableProducts);

      // Re-seed
      await _seedProducts(db);

      // Mark as seeded
      await _markAsSeeded();
    } catch (e) {
      throw SeedingException('Failed to re-seed data: ${e.toString()}');
    }
  }

  /// Seed custom products
  Future<void> seedCustomProducts(List<Product> products) async {
    try {
      final db = await _databaseService.database;
      final batch = db.batch();

      for (final product in products) {
        batch.insert(
          DatabaseService.tableProducts,
          product.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      await batch.commit(noResult: true);
    } catch (e) {
      throw SeedingException('Failed to seed custom products: ${e.toString()}');
    }
  }

  /// Get seeding status
  Future<SeedingStatus> getSeedingStatus() async {
    try {
      final isSeeded = await isDataSeeded();
      final db = await _databaseService.database;

      // Get product count
      final productResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseService.tableProducts}',
      );
      final productCount = Sqflite.firstIntValue(productResult) ?? 0;

      // Get sales count
      final salesResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${DatabaseService.tableSales}',
      );
      final salesCount = Sqflite.firstIntValue(salesResult) ?? 0;

      return SeedingStatus(
        isSeeded: isSeeded,
        productCount: productCount,
        salesCount: salesCount,
      );
    } catch (e) {
      throw SeedingException('Failed to get seeding status: ${e.toString()}');
    }
  }

  /// Reset all data (clear and re-seed)
  Future<void> resetData() async {
    try {
      await _databaseService.clearAllData();
      await seedData();
    } catch (e) {
      throw SeedingException('Failed to reset data: ${e.toString()}');
    }
  }
}

/// Seeding Exception
class SeedingException implements Exception {
  final String message;
  SeedingException(this.message);

  @override
  String toString() => message;
}

/// Seeding Status
class SeedingStatus {
  final bool isSeeded;
  final int productCount;
  final int salesCount;

  SeedingStatus({
    required this.isSeeded,
    required this.productCount,
    required this.salesCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'is_seeded': isSeeded,
      'product_count': productCount,
      'sales_count': salesCount,
    };
  }
}
