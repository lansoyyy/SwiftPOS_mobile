import 'package:flutter/material.dart';
import '../models/product.dart';

final List<Product> sampleProducts = [
  // Food
  Product(id: 'p1', name: 'Cheeseburger', category: 'Food', price: 89.00, stock: 24, icon: Icons.lunch_dining, color: const Color(0xFFEA580C)),
  Product(id: 'p2', name: 'Chicken Sandwich', category: 'Food', price: 79.00, stock: 18, icon: Icons.lunch_dining, color: const Color(0xFFEA580C)),
  Product(id: 'p3', name: 'French Fries', category: 'Food', price: 49.00, stock: 3, icon: Icons.fastfood, color: const Color(0xFFEA580C)),
  Product(id: 'p4', name: 'Pizza Slice', category: 'Food', price: 65.00, stock: 12, icon: Icons.local_pizza, color: const Color(0xFFEA580C)),
  // Drinks
  Product(id: 'p5', name: 'Bottled Water', category: 'Drinks', price: 20.00, stock: 50, icon: Icons.water_drop, color: const Color(0xFF2563EB)),
  Product(id: 'p6', name: 'Hot Coffee', category: 'Drinks', price: 55.00, stock: 30, icon: Icons.coffee, color: const Color(0xFF92400E)),
  Product(id: 'p7', name: 'Iced Tea', category: 'Drinks', price: 35.00, stock: 25, icon: Icons.local_drink, color: const Color(0xFF0891B2)),
  Product(id: 'p8', name: 'Fruit Juice', category: 'Drinks', price: 45.00, stock: 4, icon: Icons.emoji_food_beverage, color: const Color(0xFFD97706)),
  // Snacks
  Product(id: 'p9', name: 'Potato Chips', category: 'Snacks', price: 35.00, stock: 20, icon: Icons.cookie, color: const Color(0xFFF59E0B)),
  Product(id: 'p10', name: 'Chocolate Bar', category: 'Snacks', price: 25.00, stock: 2, icon: Icons.cookie, color: const Color(0xFF92400E)),
  Product(id: 'p11', name: 'Crackers Pack', category: 'Snacks', price: 20.00, stock: 15, icon: Icons.bakery_dining, color: const Color(0xFFF59E0B)),
  // Personal Care
  Product(id: 'p12', name: 'Shampoo Sachet', category: 'Care', price: 10.00, stock: 60, icon: Icons.wash, color: const Color(0xFF059669)),
  Product(id: 'p13', name: 'Soap Bar', category: 'Care', price: 35.00, stock: 4, icon: Icons.soap, color: const Color(0xFF059669)),
  Product(id: 'p14', name: 'Toothpaste', category: 'Care', price: 55.00, stock: 9, icon: Icons.medical_services, color: const Color(0xFF059669)),
  // Others
  Product(id: 'p15', name: 'Ballpen', category: 'Others', price: 12.00, stock: 45, icon: Icons.edit, color: const Color(0xFF6366F1)),
  Product(id: 'p16', name: 'Notepad', category: 'Others', price: 25.00, stock: 8, icon: Icons.note_alt, color: const Color(0xFF6366F1)),
];

const List<String> productCategories = ['All', 'Food', 'Drinks', 'Snacks', 'Care', 'Others'];
