import 'package:sqflite/sqflite.dart';
import '../../models/printer_settings.dart';
import '../database/database_service.dart';

/// Printer Settings Repository - CRUD Operations for Printer Settings
class PrinterSettingsRepository {
  final DatabaseService _databaseService = DatabaseService();

  // Settings keys
  static const String keyPrinterName = 'printer_name';
  static const String keyPrinterAddress = 'printer_address';
  static const String keyIsConnected = 'is_connected';
  static const String keyLastConnected = 'last_connected';

  // CREATE/UPDATE - Save printer settings
  Future<void> savePrinterSettings(PrinterSettings settings) async {
    final db = await _databaseService.database;
    final batch = db.batch();

    // Save printer name
    if (settings.printerName != null) {
      await db.delete(
        DatabaseService.tableSettings,
        where: 'key = ?',
        whereArgs: [keyPrinterName],
      );
      batch.insert(
        DatabaseService.tableSettings,
        {
          'key': keyPrinterName,
          'value': settings.printerName,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Save printer address
    if (settings.printerAddress != null) {
      await db.delete(
        DatabaseService.tableSettings,
        where: 'key = ?',
        whereArgs: [keyPrinterAddress],
      );
      batch.insert(
        DatabaseService.tableSettings,
        {
          'key': keyPrinterAddress,
          'value': settings.printerAddress,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Save connection status
    await db.delete(
      DatabaseService.tableSettings,
      where: 'key = ?',
      whereArgs: [keyIsConnected],
    );
    batch.insert(DatabaseService.tableSettings, {
      'key': keyIsConnected,
      'value': settings.isConnected ? '1' : '0',
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Save last connected timestamp
    if (settings.lastConnected != null) {
      await db.delete(
        DatabaseService.tableSettings,
        where: 'key = ?',
        whereArgs: [keyLastConnected],
      );
      batch.insert(
        DatabaseService.tableSettings,
        {
          'key': keyLastConnected,
          'value': settings.lastConnected!.millisecondsSinceEpoch.toString(),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  // READ - Get printer settings
  Future<PrinterSettings?> getPrinterSettings() async {
    final db = await _databaseService.database;

    // Get printer name
    final nameMaps = await db.query(
      DatabaseService.tableSettings,
      where: 'key = ?',
      whereArgs: [keyPrinterName],
      limit: 1,
    );
    final printerName = nameMaps.isNotEmpty
        ? nameMaps.first['value'] as String?
        : null;

    // Get printer address
    final addressMaps = await db.query(
      DatabaseService.tableSettings,
      where: 'key = ?',
      whereArgs: [keyPrinterAddress],
      limit: 1,
    );
    final printerAddress = addressMaps.isNotEmpty
        ? addressMaps.first['value'] as String?
        : null;

    // Get connection status
    final connectedMaps = await db.query(
      DatabaseService.tableSettings,
      where: 'key = ?',
      whereArgs: [keyIsConnected],
      limit: 1,
    );
    final isConnected = connectedMaps.isNotEmpty
        ? (connectedMaps.first['value'] as String) == '1'
        : false;

    // Get last connected timestamp
    final lastConnectedMaps = await db.query(
      DatabaseService.tableSettings,
      where: 'key = ?',
      whereArgs: [keyLastConnected],
      limit: 1,
    );
    DateTime? lastConnected;
    if (lastConnectedMaps.isNotEmpty) {
      final timestamp = int.tryParse(
        lastConnectedMaps.first['value'] as String,
      );
      if (timestamp != null) {
        lastConnected = DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
    }

    // If no settings found, return null
    if (printerName == null &&
        printerAddress == null &&
        !isConnected &&
        lastConnected == null) {
      return null;
    }

    return PrinterSettings(
      printerName: printerName,
      printerAddress: printerAddress,
      isConnected: isConnected,
      lastConnected: lastConnected,
    );
  }

  // READ - Get printer name
  Future<String?> getPrinterName() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.tableSettings,
      where: 'key = ?',
      whereArgs: [keyPrinterName],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first['value'] as String? : null;
  }

  // READ - Get printer address
  Future<String?> getPrinterAddress() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.tableSettings,
      where: 'key = ?',
      whereArgs: [keyPrinterAddress],
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first['value'] as String? : null;
  }

  // READ - Get connection status
  Future<bool> isConnected() async {
    final db = await _databaseService.database;
    final List<Map<String, dynamic>> maps = await db.query(
      DatabaseService.tableSettings,
      where: 'key = ?',
      whereArgs: [keyIsConnected],
      limit: 1,
    );
    return maps.isNotEmpty ? (maps.first['value'] as String) == '1' : false;
  }

  // UPDATE - Set printer name
  Future<void> setPrinterName(String name) async {
    final db = await _databaseService.database;
    await db.insert(DatabaseService.tableSettings, {
      'key': keyPrinterName,
      'value': name,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // UPDATE - Set printer address
  Future<void> setPrinterAddress(String address) async {
    final db = await _databaseService.database;
    await db.insert(DatabaseService.tableSettings, {
      'key': keyPrinterAddress,
      'value': address,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // UPDATE - Set connection status
  Future<void> setConnectionStatus(bool connected) async {
    final db = await _databaseService.database;
    await db.insert(DatabaseService.tableSettings, {
      'key': keyIsConnected,
      'value': connected ? '1' : '0',
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // UPDATE - Update last connected timestamp
  Future<void> updateLastConnected() async {
    final db = await _databaseService.database;
    await db.insert(DatabaseService.tableSettings, {
      'key': keyLastConnected,
      'value': DateTime.now().millisecondsSinceEpoch.toString(),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // DELETE - Clear printer settings
  Future<void> clearPrinterSettings() async {
    final db = await _databaseService.database;
    await db.delete(
      DatabaseService.tableSettings,
      where: 'key = ? OR key = ? OR key = ? OR key = ?',
      whereArgs: [
        keyPrinterName,
        keyPrinterAddress,
        keyIsConnected,
        keyLastConnected,
      ],
    );
  }

  // DELETE - Disconnect printer
  Future<void> disconnectPrinter() async {
    await setConnectionStatus(false);
  }
}
