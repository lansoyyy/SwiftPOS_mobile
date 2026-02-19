import 'package:sqflite/sqflite.dart';
import '../../models/product.dart';
import '../database/database_service.dart';

/// Product Repository - CRUD Operations for Products
class ProductRepository {
  final DatabaseService _databaseService = DatabaseService();

  // CREATE - Insert a new product
  Future<void> insertProduct(Product product) async {
    final db = await _databaseService.database;
    await db.insert(
      DatabaseService.tableProducts,
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // CREATE - Insert multiple products (bulk insert)
  Future<void> insertProducts(List<Product> products) async {
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
  }

  // READ - Get all products
  Future<List<Product>> getAllProducts() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.tableProducts,
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  // READ - Get product by ID
  Future<Product?> getProductById(String id) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Product.fromMap(maps.first);
  }

  // READ - Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.tableProducts,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  // READ - Search products by name
  Future<List<Product>> searchProducts(String query) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.tableProducts,
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  // READ - Get low stock products (stock <= 5)
  Future<List<Product>> getLowStockProducts({int threshold = 5}) async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.tableProducts,
      where: 'stock <= ?',
      whereArgs: [threshold],
      orderBy: 'stock ASC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  // READ - Get products by category with search
  Future<List<Product>> getProductsByCategoryAndSearch(
    String category,
    String searchQuery,
  ) async {
    final db = await _databaseService.database;
    String? where;
    List<dynamic>? whereArgs;

    if (category == 'All') {
      where = 'name LIKE ?';
      whereArgs = ['%$searchQuery%'];
    } else {
      where = 'category = ? AND name LIKE ?';
      whereArgs = [category, '%$searchQuery%'];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.tableProducts,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  // UPDATE - Update a product
  Future<void> updateProduct(Product product) async {
    final db = await _databaseService.database;
    final map = product.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      DatabaseService.tableProducts,
      map,
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // UPDATE - Update product stock
  Future<void> updateProductStock(String productId, int newStock) async {
    final db = await _databaseService.database;
    await db.update(
      DatabaseService.tableProducts,
      {'stock': newStock, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // UPDATE - Increment product stock
  Future<void> incrementProductStock(String productId, int amount) async {
    final db = await _databaseService.database;
    await db.rawUpdate(
      'UPDATE ${DatabaseService.tableProducts} SET stock = stock + ?, updated_at = ? WHERE id = ?',
      [amount, DateTime.now().millisecondsSinceEpoch, productId],
    );
  }

  // UPDATE - Decrement product stock
  Future<void> decrementProductStock(String productId, int amount) async {
    final db = await _databaseService.database;
    await db.rawUpdate(
      'UPDATE ${DatabaseService.tableProducts} SET stock = stock - ?, updated_at = ? WHERE id = ?',
      [amount, DateTime.now().millisecondsSinceEpoch, productId],
    );
  }

  // DELETE - Delete a product
  Future<void> deleteProduct(String id) async {
    final db = await _databaseService.database;
    await db.delete(
      DatabaseService.tableProducts,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE - Delete multiple products
  Future<void> deleteProducts(List<String> ids) async {
    final db = await _databaseService.database;
    final batch = db.batch();
    for (final id in ids) {
      batch.delete(
        DatabaseService.tableProducts,
        where: 'id = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }

  // DELETE - Delete all products
  Future<void> deleteAllProducts() async {
    final db = await _databaseService.database;
    await db.delete(DatabaseService.tableProducts);
  }

  // COUNT - Get total product count
  Future<int> getProductCount() async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseService.tableProducts}',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // COUNT - Get low stock product count
  Future<int> getLowStockCount({int threshold = 5}) async {
    final db = await _databaseService.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DatabaseService.tableProducts} WHERE stock <= ?',
      [threshold],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // GET - Get all unique categories
  Future<List<String>> getCategories() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT category FROM ${DatabaseService.tableProducts} ORDER BY category ASC',
    );
    return maps.map((map) => map['category'] as String).toList();
  }
}
