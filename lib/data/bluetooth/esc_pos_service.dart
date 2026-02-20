import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../../models/sale_record.dart';
import 'bluetooth_service.dart';

/// ESC/POS Print Service - Handles thermal printer commands and receipt formatting
class EscPosService {
  final BluetoothService _bluetoothService;

  EscPosService(this._bluetoothService);

  // ESC/POS Commands
  static const int _ESC = 0x1B;
  static const int _GS = 0x1D;

  // Text alignment
  static final Uint8List _alignLeft = Uint8List.fromList([_ESC, 0x61, 0x00]);
  static final Uint8List _alignCenter = Uint8List.fromList([_ESC, 0x61, 0x01]);
  static final Uint8List _alignRight = Uint8List.fromList([_ESC, 0x61, 0x02]);

  // Text styles
  static final Uint8List _boldOn = Uint8List.fromList([_ESC, 0x45, 0x0B]);
  static final Uint8List _boldOff = Uint8List.fromList([_ESC, 0x45, 0x0A]);
  static final Uint8List _underlineOn = Uint8List.fromList([_ESC, 0x2D, 0x01]);
  static final Uint8List _underlineOff = Uint8List.fromList([_ESC, 0x2D, 0x00]);

  // Text size (normal)
  static final Uint8List _textSizeNormal = Uint8List.fromList([
    _GS,
    0x21,
    0x00,
  ]);
  // Text size (double height)
  static final Uint8List _textSizeDoubleHeight = Uint8List.fromList([
    _GS,
    0x21,
    0x10,
  ]);
  // Text size (double width)
  static final Uint8List _textSizeDoubleWidth = Uint8List.fromList([
    _GS,
    0x21,
    0x20,
  ]);
  // Text size (double width and height)
  static final Uint8List _textSizeDouble = Uint8List.fromList([
    _GS,
    0x21,
    0x30,
  ]);

  // Line spacing
  static final Uint8List _lineSpacingDefault = Uint8List.fromList([
    _ESC,
    0x33,
    0x00,
  ]);
  static final Uint8List _lineSpacing60 = Uint8List.fromList([
    _ESC,
    0x33,
    0x60,
  ]);

  // Feed and cut
  static final Uint8List _feed3Lines = Uint8List.fromList([_ESC, 0x64, 0x03]);
  static final Uint8List _feed5Lines = Uint8List.fromList([_ESC, 0x64, 0x05]);
  static final Uint8List _cutPaper = Uint8List.fromList([
    _GS,
    0x56,
    0x42,
    0x00,
  ]);
  static final Uint8List _cutPaperPartial = Uint8List.fromList([
    _GS,
    0x56,
    0x42,
    0x01,
  ]);

  // Barcode
  static final Uint8List _barcodeHRI = Uint8List.fromList([
    _GS,
    0x48,
    0x02,
  ]); // HRI below
  static final Uint8List _barcodeWidth = Uint8List.fromList([
    _GS,
    0x77,
    0x02,
  ]); // Width 2
  static final Uint8List _barcodeHeight = Uint8List.fromList([
    _GS,
    0x68,
    0x64,
  ]); // Height 100

  // QR Code
  static final Uint8List _qrCodeModel2 = Uint8List.fromList([
    _GS,
    0x28,
    0x6B,
    0x04,
    0x00,
    0x31,
    0x41,
  ]); // Model 2
  static final Uint8List _qrCodeSize = Uint8List.fromList([
    _GS,
    0x28,
    0x6B,
    0x03,
    0x00,
    0x31,
    0x43,
    0x08,
  ]); // Size 8
  static final Uint8List _qrCodeErrorLevel = Uint8List.fromList([
    _GS,
    0x28,
    0x6B,
    0x03,
    0x00,
    0x31,
    0x45,
    0x31,
  ]); // Error level L

  /// Print a receipt for a sale record
  Future<bool> printReceipt(
    SaleRecord sale, {
    String storeName = 'SwiftPOS',
  }) async {
    if (!_bluetoothService.isConnected) {
      return false;
    }

    final buffer = StringBuffer();

    // Initialize printer
    buffer.write(_lineSpacingDefault);
    buffer.write(_textSizeNormal);

    // Header
    buffer.write(_alignCenter);
    buffer.write(_textSizeDoubleWidth);
    buffer.write(_boldOn);
    buffer.writeln(storeName);
    buffer.write(_boldOff);
    buffer.write(_textSizeNormal);
    buffer.writeln('=' * 30);
    buffer.writeln();

    // Date and time
    buffer.write(_alignLeft);
    buffer.writeln('Date: ${_formatDate(sale.timestamp)}');
    buffer.writeln('Time: ${_formatTime(sale.timestamp)}');
    buffer.writeln('Receipt #: ${sale.id.substring(sale.id.length - 8)}');
    buffer.writeln();

    // Items header
    buffer.write(_boldOn);
    buffer.writeln('ITEM                     QTY  AMT');
    buffer.write(_boldOff);
    buffer.writeln('-' * 30);

    // Items
    for (final item in sale.items) {
      final name = item.product.name;
      final qty = item.quantity;
      final price = item.product.price * qty;

      // Item name
      buffer.write(name);

      // Calculate spacing
      final nameLength = name.length;
      final remaining = 30 - nameLength;

      if (remaining > 0) {
        buffer.write(' ' * remaining);
      }

      // Qty and price
      buffer.writeln('${qty.toString().padLeft(3)}  ${_formatCurrency(price)}');
    }

    buffer.writeln('-' * 30);
    buffer.writeln();

    // Totals
    buffer.write(_alignRight);
    buffer.write(_boldOn);
    buffer.writeln('TOTAL: ${_formatCurrency(sale.total)}');
    buffer.write(_boldOff);
    buffer.writeln();

    // Payment info
    buffer.write(_alignLeft);
    buffer.writeln('Payment Method: ${sale.paymentMethod}');
    if (sale.amountPaid != null) {
      buffer.writeln('Amount Paid: ${_formatCurrency(sale.amountPaid!)}');
    }
    if (sale.change != null && sale.change! > 0) {
      buffer.writeln('Change: ${_formatCurrency(sale.change!)}');
    }
    buffer.writeln();

    // Footer
    buffer.write(_alignCenter);
    buffer.write(_textSizeDoubleHeight);
    buffer.write(_boldOn);
    buffer.writeln('THANK YOU!');
    buffer.write(_boldOff);
    buffer.write(_textSizeNormal);
    buffer.writeln();

    // Feed and cut
    buffer.write(_feed5Lines);
    buffer.write(_cutPaper);

    // Send to printer
    return await _bluetoothService.sendBytes(_stringToBytes(buffer.toString()));
  }

  /// Print a test receipt
  Future<bool> printTestReceipt({String storeName = 'SwiftPOS'}) async {
    if (!_bluetoothService.isConnected) {
      return false;
    }

    final buffer = StringBuffer();

    // Initialize printer
    buffer.write(_lineSpacingDefault);
    buffer.write(_textSizeNormal);

    // Header
    buffer.write(_alignCenter);
    buffer.write(_textSizeDoubleWidth);
    buffer.write(_boldOn);
    buffer.writeln(storeName);
    buffer.write(_boldOff);
    buffer.write(_textSizeNormal);
    buffer.writeln('=' * 30);
    buffer.writeln();

    // Test message
    buffer.write(_alignCenter);
    buffer.write(_boldOn);
    buffer.writeln('TEST PRINT');
    buffer.write(_boldOff);
    buffer.writeln();

    buffer.write(_alignLeft);
    buffer.writeln('This is a test print to verify');
    buffer.writeln('your thermal printer is working');
    buffer.writeln('correctly.');
    buffer.writeln();

    // Date and time
    buffer.writeln('Date: ${_formatDate(DateTime.now())}');
    buffer.writeln('Time: ${_formatTime(DateTime.now())}');
    buffer.writeln();

    // Footer
    buffer.write(_alignCenter);
    buffer.write(_textSizeDoubleHeight);
    buffer.write(_boldOn);
    buffer.writeln('SUCCESS!');
    buffer.write(_boldOff);
    buffer.write(_textSizeNormal);
    buffer.writeln();

    // Feed and cut
    buffer.write(_feed5Lines);
    buffer.write(_cutPaper);

    // Send to printer
    return await _bluetoothService.sendBytes(_stringToBytes(buffer.toString()));
  }

  /// Print a simple text message
  Future<bool> printText(
    String text, {
    bool bold = false,
    bool center = false,
  }) async {
    if (!_bluetoothService.isConnected) {
      return false;
    }

    final buffer = StringBuffer();

    if (center) {
      buffer.write(_alignCenter);
    } else {
      buffer.write(_alignLeft);
    }

    if (bold) {
      buffer.write(_boldOn);
    }

    buffer.writeln(text);

    if (bold) {
      buffer.write(_boldOff);
    }

    buffer.write(_feed3Lines);

    return await _bluetoothService.sendBytes(_stringToBytes(buffer.toString()));
  }

  /// Print a divider line
  Future<bool> printDivider({String char = '-', int length = 30}) async {
    if (!_bluetoothService.isConnected) {
      return false;
    }

    final buffer = StringBuffer();
    buffer.write(_alignCenter);
    buffer.writeln(char * length);
    buffer.write(_feed3Lines);

    return await _bluetoothService.sendBytes(_stringToBytes(buffer.toString()));
  }

  /// Format date for receipt
  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format time for receipt
  String _formatTime(DateTime date) {
    return DateFormat('hh:mm a').format(date);
  }

  /// Format currency for receipt
  String _formatCurrency(double amount) {
    return 'P${amount.toStringAsFixed(2)}';
  }

  /// Convert string to bytes (Latin-1 encoding)
  Uint8List _stringToBytes(String text) {
    return Uint8List.fromList(text.codeUnits);
  }

  /// Get bytes for a command
  Uint8List _getCommand(List<int> bytes) {
    return Uint8List.fromList(bytes);
  }
}
