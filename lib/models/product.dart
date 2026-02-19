import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  int stock;
  final String? barcode;
  final IconData icon;
  final Color color;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.barcode,
    required this.icon,
    required this.color,
  });

  Product copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? barcode,
    IconData? icon,
    Color? color,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      barcode: barcode ?? this.barcode,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  // Database serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'barcode': barcode,
      'icon_code': icon.codePoint,
      'color_value': color.value,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      price: map['price'] as double,
      stock: map['stock'] as int,
      barcode: map['barcode'] as String?,
      icon: IconData(map['icon_code'] as int, fontFamily: 'MaterialIcons'),
      color: Color(map['color_value'] as int),
    );
  }
}
