import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

/// Database Service for SwiftPOS - Local SQLite Database
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  // Database name and version
  static const String _databaseName = 'swiftpos.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String tableProducts = 'products';
  static const String tableSales = 'sales';
  static const String tableSaleItems = 'sale_items';
  static const String tableSettings = 'settings';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE $tableProducts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        barcode TEXT,
        icon_code INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Sales table
    await db.execute('''
      CREATE TABLE $tableSales (
        id TEXT PRIMARY KEY,
        total REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        payment_method TEXT NOT NULL,
        amount_paid REAL,
        change_amount REAL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Sale items table
    await db.execute('''
      CREATE TABLE $tableSaleItems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sale_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES $tableSales (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES $tableProducts (id) ON DELETE CASCADE
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE $tableSettings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute(
      'CREATE INDEX idx_products_category ON $tableProducts(category)',
    );
    await db.execute(
      'CREATE INDEX idx_products_stock ON $tableProducts(stock)',
    );
    await db.execute(
      'CREATE INDEX idx_sales_timestamp ON $tableSales(timestamp)',
    );
    await db.execute(
      'CREATE INDEX idx_sale_items_sale_id ON $tableSaleItems(sale_id)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Future migrations
    }
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  // Clear all data (for testing/reset)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(tableSaleItems);
    await db.delete(tableSales);
    await db.delete(tableProducts);
    await db.delete(tableSettings);
  }
}
