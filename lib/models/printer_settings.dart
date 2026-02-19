/// Printer Settings Model
class PrinterSettings {
  final String? printerName;
  final String? printerAddress;
  final bool isConnected;
  final DateTime? lastConnected;

  PrinterSettings({
    this.printerName,
    this.printerAddress,
    this.isConnected = false,
    this.lastConnected,
  });

  PrinterSettings copyWith({
    String? printerName,
    String? printerAddress,
    bool? isConnected,
    DateTime? lastConnected,
  }) {
    return PrinterSettings(
      printerName: printerName ?? this.printerName,
      printerAddress: printerAddress ?? this.printerAddress,
      isConnected: isConnected ?? this.isConnected,
      lastConnected: lastConnected ?? this.lastConnected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'printerName': printerName,
      'printerAddress': printerAddress,
      'isConnected': isConnected ? 1 : 0,
      'lastConnected': lastConnected?.millisecondsSinceEpoch,
    };
  }

  factory PrinterSettings.fromMap(Map<String, dynamic> map) {
    return PrinterSettings(
      printerName: map['printerName'] as String?,
      printerAddress: map['printerAddress'] as String?,
      isConnected: (map['isConnected'] as int?) == 1,
      lastConnected: map['lastConnected'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastConnected'] as int)
          : null,
    );
  }
}
