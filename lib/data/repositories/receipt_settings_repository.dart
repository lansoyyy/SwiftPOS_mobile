import 'package:sqflite/sqflite.dart';
import '../../models/receipt_settings.dart';
import '../database/database_service.dart';

/// Receipt Settings Repository - CRUD Operations for Receipt Settings
class ReceiptSettingsRepository {
  final DatabaseService _databaseService = DatabaseService();

  static const String _settingsKey = 'receipt_settings';

  // Get receipt settings from database
  Future<ReceiptSettings?> getReceiptSettings() async {
    try {
      final db = await _databaseService.database;
      final result = await db.query(
        DatabaseService.tableSettings,
        where: 'key = ?',
        whereArgs: [_settingsKey],
        limit: 1,
      );

      if (result.isEmpty) {
        return null;
      }

      final settingsJson = result.first['value'] as String;
      return ReceiptSettings.fromMap(_parseSettingsJson(settingsJson));
    } catch (e) {
      return null;
    }
  }

  // Save receipt settings to database
  Future<void> saveReceiptSettings(ReceiptSettings settings) async {
    final db = await _databaseService.database;
    final settingsJson = _settingsToJson(settings);

    await db.insert(DatabaseService.tableSettings, {
      'key': _settingsKey,
      'value': settingsJson,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Delete receipt settings
  Future<void> deleteReceiptSettings() async {
    final db = await _databaseService.database;
    await db.delete(
      DatabaseService.tableSettings,
      where: 'key = ?',
      whereArgs: [_settingsKey],
    );
  }

  // Parse settings JSON string to Map
  Map<String, dynamic> _parseSettingsJson(String json) {
    try {
      // Parse the JSON string which contains multiple settings
      final parts = json.split('|');
      final settings = <String, dynamic>{};

      for (final part in parts) {
        final keyValue = part.split(':');
        if (keyValue.length == 2) {
          settings[keyValue[0].trim()] = keyValue[1].trim();
        }
      }

      return settings;
    } catch (e) {
      return {};
    }
  }

  // Convert settings to JSON string
  String _settingsToJson(ReceiptSettings settings) {
    return [
      'store_name:${settings.storeName}',
      'store_address:${settings.storeAddress}',
      'store_phone:${settings.storePhone}',
      'store_email:${settings.storeEmail}',
      'receipt_header:${settings.receiptHeader}',
      'receipt_footer:${settings.receiptFooter}',
      'receipt_message:${settings.receiptMessage}',
      'show_barcode:${settings.showBarcode ? 1 : 0}',
      'show_customer_info:${settings.showCustomerInfo ? 1 : 0}',
      'show_tax_details:${settings.showTaxDetails ? 1 : 0}',
      'font_size:${settings.fontSize}',
      'paper_width:${settings.paperWidth}',
    ].join('|');
  }
}
