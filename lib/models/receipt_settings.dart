/// Receipt Settings Model - Customizable receipt configuration
class ReceiptSettings {
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String storeEmail;
  final String receiptHeader;
  final String receiptFooter;
  final String receiptMessage;
  final bool showBarcode;
  final bool showCustomerInfo;
  final bool showTaxDetails;
  final int fontSize;
  final int paperWidth; // 58mm, 80mm, etc.

  const ReceiptSettings({
    this.storeName = '',
    this.storeAddress = '',
    this.storePhone = '',
    this.storeEmail = '',
    this.receiptHeader = '',
    this.receiptFooter = 'Thank you for your purchase!',
    this.receiptMessage = '',
    this.showBarcode = true,
    this.showCustomerInfo = false,
    this.showTaxDetails = true,
    this.fontSize = 12,
    this.paperWidth = 58,
  });

  ReceiptSettings copyWith({
    String? storeName,
    String? storeAddress,
    String? storePhone,
    String? storeEmail,
    String? receiptHeader,
    String? receiptFooter,
    String? receiptMessage,
    bool? showBarcode,
    bool? showCustomerInfo,
    bool? showTaxDetails,
    int? fontSize,
    int? paperWidth,
  }) {
    return ReceiptSettings(
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      storePhone: storePhone ?? this.storePhone,
      storeEmail: storeEmail ?? this.storeEmail,
      receiptHeader: receiptHeader ?? this.receiptHeader,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      receiptMessage: receiptMessage ?? this.receiptMessage,
      showBarcode: showBarcode ?? this.showBarcode,
      showCustomerInfo: showCustomerInfo ?? this.showCustomerInfo,
      showTaxDetails: showTaxDetails ?? this.showTaxDetails,
      fontSize: fontSize ?? this.fontSize,
      paperWidth: paperWidth ?? this.paperWidth,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'store_name': storeName,
      'store_address': storeAddress,
      'store_phone': storePhone,
      'store_email': storeEmail,
      'receipt_header': receiptHeader,
      'receipt_footer': receiptFooter,
      'receipt_message': receiptMessage,
      'show_barcode': showBarcode ? 1 : 0,
      'show_customer_info': showCustomerInfo ? 1 : 0,
      'show_tax_details': showTaxDetails ? 1 : 0,
      'font_size': fontSize,
      'paper_width': paperWidth,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory ReceiptSettings.fromMap(Map<String, dynamic> map) {
    return ReceiptSettings(
      storeName: map['store_name'] as String? ?? '',
      storeAddress: map['store_address'] as String? ?? '',
      storePhone: map['store_phone'] as String? ?? '',
      storeEmail: map['store_email'] as String? ?? '',
      receiptHeader: map['receipt_header'] as String? ?? '',
      receiptFooter:
          map['receipt_footer'] as String? ?? 'Thank you for your purchase!',
      receiptMessage: map['receipt_message'] as String? ?? '',
      showBarcode: (map['show_barcode'] as int?) == 1,
      showCustomerInfo: (map['show_customer_info'] as int?) == 1,
      showTaxDetails: (map['show_tax_details'] as int?) == 1,
      fontSize: map['font_size'] as int? ?? 12,
      paperWidth: map['paper_width'] as int? ?? 58,
    );
  }

  /// Default receipt settings
  static const ReceiptSettings defaultSettings = ReceiptSettings(
    storeName: 'SwiftPOS Store',
    receiptFooter: 'Thank you for your purchase!',
    showBarcode: true,
    showTaxDetails: true,
    fontSize: 12,
    paperWidth: 58,
  );
}

/// Paper width options
enum PaperWidth {
  mm58,
  mm80;

  int get value {
    switch (this) {
      case PaperWidth.mm58:
        return 58;
      case PaperWidth.mm80:
        return 80;
    }
  }

  String get displayName {
    switch (this) {
      case PaperWidth.mm58:
        return '58mm';
      case PaperWidth.mm80:
        return '80mm';
    }
  }
}
