import 'package:flutter/material.dart';

/// Validation Utilities
class Validators {
  /// Validate product name
  static String? validateProductName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Product name is required';
    }
    if (value.length < 2) {
      return 'Product name must be at least 2 characters';
    }
    if (value.length > 100) {
      return 'Product name must not exceed 100 characters';
    }
    return null;
  }

  /// Validate product category
  static String? validateCategory(String? value) {
    if (value == null || value.isEmpty) {
      return 'Category is required';
    }
    if (value.length > 50) {
      return 'Category must not exceed 50 characters';
    }
    return null;
  }

  /// Validate price
  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid price';
    }
    if (price < 0) {
      return 'Price cannot be negative';
    }
    if (price > 999999.99) {
      return 'Price is too high';
    }
    return null;
  }

  /// Validate stock
  static String? validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'Stock is required';
    }
    final stock = int.tryParse(value);
    if (stock == null) {
      return 'Please enter a valid stock quantity';
    }
    if (stock < 0) {
      return 'Stock cannot be negative';
    }
    if (stock > 999999) {
      return 'Stock value is too high';
    }
    return null;
  }

  /// Validate barcode
  static String? validateBarcode(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Barcode is optional
    }
    if (value.length > 50) {
      return 'Barcode must not exceed 50 characters';
    }
    return null;
  }

  /// Validate discount value
  static String? validateDiscountValue(String? value, bool isPercentage) {
    if (value == null || value.isEmpty) {
      return 'Discount value is required';
    }
    final discount = double.tryParse(value);
    if (discount == null) {
      return 'Please enter a valid discount value';
    }
    if (discount < 0) {
      return 'Discount cannot be negative';
    }
    if (isPercentage && discount > 100) {
      return 'Percentage discount cannot exceed 100%';
    }
    return null;
  }

  /// Validate tax rate
  static String? validateTaxRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tax rate is required';
    }
    final tax = double.tryParse(value);
    if (tax == null) {
      return 'Please enter a valid tax rate';
    }
    if (tax < 0) {
      return 'Tax rate cannot be negative';
    }
    if (tax > 100) {
      return 'Tax rate cannot exceed 100%';
    }
    return null;
  }

  /// Validate cash amount
  static String? validateCashAmount(String? value, double total) {
    if (value == null || value.isEmpty) {
      return 'Cash amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }
    if (amount < 0) {
      return 'Amount cannot be negative';
    }
    if (amount < total) {
      return 'Amount must be at least ${total.toStringAsFixed(2)}';
    }
    return null;
  }

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[\d\s\-\+\(\)]{7,20}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validate required field
  static String? validateRequired(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate numeric field
  static String? validateNumeric(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  /// Validate positive number
  static String? validatePositiveNumber(
    String? value, {
    String fieldName = 'This field',
  }) {
    final numericError = validateNumeric(value, fieldName: fieldName);
    if (numericError != null) return numericError;

    final num = double.tryParse(value!);
    if (num != null && num < 0) {
      return '$fieldName must be positive';
    }
    return null;
  }

  /// Validate integer field
  static String? validateInteger(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a valid integer';
    }
    return null;
  }

  /// Validate date range
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Both dates are required';
    }
    if (endDate.isBefore(startDate)) {
      return 'End date must be after start date';
    }
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(
    String? value,
    int minLength, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String fieldName = 'This field',
  }) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }
}

/// Business Logic Validators
class BusinessValidators {
  /// Check if product has sufficient stock
  static bool hasSufficientStock(int currentStock, int requestedQuantity) {
    return currentStock >= requestedQuantity;
  }

  /// Get stock status
  static StockStatus getStockStatus(int stock) {
    if (stock == 0) return StockStatus.outOfStock;
    if (stock <= 5) return StockStatus.lowStock;
    return StockStatus.inStock;
  }

  /// Check if discount is valid
  static bool isValidDiscount(double discount, bool isPercentage) {
    if (discount < 0) return false;
    if (isPercentage && discount > 100) return false;
    return true;
  }

  /// Check if tax is valid
  static bool isValidTax(double tax) {
    return tax >= 0 && tax <= 100;
  }

  /// Calculate change
  static double calculateChange(double amountPaid, double total) {
    return amountPaid - total;
  }

  /// Check if payment is sufficient
  static bool isPaymentSufficient(double amountPaid, double total) {
    return amountPaid >= total;
  }

  /// Validate cart item
  static String? validateCartItem(int stock, int quantity) {
    if (quantity <= 0) {
      return 'Quantity must be greater than 0';
    }
    if (!hasSufficientStock(stock, quantity)) {
      return 'Insufficient stock. Available: $stock';
    }
    return null;
  }

  /// Validate cart total
  static String? validateCartTotal(double total) {
    if (total <= 0) {
      return 'Cart cannot be empty';
    }
    return null;
  }
}

/// Stock Status Enum
enum StockStatus { inStock, lowStock, outOfStock }

/// Stock Status Extensions
extension StockStatusExtension on StockStatus {
  String get displayName {
    switch (this) {
      case StockStatus.inStock:
        return 'In Stock';
      case StockStatus.lowStock:
        return 'Low Stock';
      case StockStatus.outOfStock:
        return 'Out of Stock';
    }
  }

  Color getColor(BuildContext context) {
    switch (this) {
      case StockStatus.inStock:
        return Colors.green;
      case StockStatus.lowStock:
        return Colors.orange;
      case StockStatus.outOfStock:
        return Colors.red;
    }
  }
}
