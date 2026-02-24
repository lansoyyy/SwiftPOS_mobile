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
  final List<ProductVariant> variants;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.barcode,
    required this.icon,
    required this.color,
    this.variants = const [],
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
    List<ProductVariant>? variants,
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
      variants: variants ?? this.variants,
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
      'variants': variants.map((v) => v.toMap()).toList(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    final variantsList =
        (map['variants'] as List<dynamic>?)
            ?.map((v) => ProductVariant.fromMap(v as Map<String, dynamic>))
            .toList() ??
        [];

    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      price: map['price'] as double,
      stock: map['stock'] as int,
      barcode: map['barcode'] as String?,
      icon: IconData(map['icon_code'] as int, fontFamily: 'MaterialIcons'),
      color: Color(map['color_value'] as int),
      variants: variantsList,
    );
  }
}

class ProductVariant {
  final String id;
  final String size;
  final String color;
  final double? priceOverride;
  int stock;

  ProductVariant({
    required this.id,
    required this.size,
    required this.color,
    this.priceOverride,
    required this.stock,
  });

  ProductVariant copyWith({
    String? id,
    String? size,
    String? color,
    double? priceOverride,
    int? stock,
  }) {
    return ProductVariant(
      id: id ?? this.id,
      size: size ?? this.size,
      color: color ?? this.color,
      priceOverride: priceOverride ?? this.priceOverride,
      stock: stock ?? this.stock,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'size': size,
      'color': color,
      'price_override': priceOverride,
      'stock': stock,
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      id: map['id'] as String,
      size: map['size'] as String,
      color: map['color'] as String,
      priceOverride: map['price_override'] as double?,
      stock: map['stock'] as int,
    );
  }
}
