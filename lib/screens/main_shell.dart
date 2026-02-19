import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/sale_record.dart';
import '../data/sample_data.dart';
import '../core/constants/app_colors.dart';
import 'catalog/catalog_screen.dart';
import 'inventory/inventory_screen.dart';
import 'sales/sales_history_screen.dart';
import 'settings/printer_settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  List<Product> products = List.from(sampleProducts);
  final List<CartItem> cart = [];
  final List<SaleRecord> salesHistory = [];
  String? connectedPrinter;
  bool isPrinterConnected = false;

  // Cart
  void addToCart(Product product) {
    setState(() {
      final idx = cart.indexWhere((i) => i.product.id == product.id);
      if (idx >= 0) {
        cart[idx].quantity++;
      } else {
        cart.add(CartItem(product: product));
      }
    });
  }

  void removeFromCart(String productId) {
    setState(() => cart.removeWhere((i) => i.product.id == productId));
  }

  void updateQty(String productId, int qty) {
    setState(() {
      if (qty <= 0) {
        cart.removeWhere((i) => i.product.id == productId);
      } else {
        final idx = cart.indexWhere((i) => i.product.id == productId);
        if (idx >= 0) cart[idx].quantity = qty;
      }
    });
  }

  void clearCart() => setState(() => cart.clear());

  double get cartTotal => cart.fold(0.0, (s, i) => s + i.subtotal);
  int get cartCount => cart.fold(0, (s, i) => s + i.quantity);

  SaleRecord completeSale(String paymentMethod, {double? amountPaid}) {
    final total = cartTotal;
    final items = cart
        .map((i) => CartItem(product: i.product, quantity: i.quantity))
        .toList();
    final record = SaleRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: items,
      total: total,
      timestamp: DateTime.now(),
      paymentMethod: paymentMethod,
      amountPaid: amountPaid,
      change: amountPaid != null ? amountPaid - total : null,
    );
    setState(() {
      for (final item in cart) {
        final pi = products.indexWhere((p) => p.id == item.product.id);
        if (pi >= 0) products[pi].stock -= item.quantity;
      }
      salesHistory.insert(0, record);
      cart.clear();
    });
    return record;
  }

  // Inventory
  void updateStock(String productId, int newStock) {
    setState(() {
      final idx = products.indexWhere((p) => p.id == productId);
      if (idx >= 0) products[idx].stock = newStock;
    });
  }

  void addProduct(Product product) => setState(() => products.add(product));

  void deleteProduct(String productId) {
    setState(() => products.removeWhere((p) => p.id == productId));
  }

  // Printer
  void connectPrinter(String name) {
    setState(() {
      connectedPrinter = name;
      isPrinterConnected = true;
    });
  }

  void disconnectPrinter() {
    setState(() {
      connectedPrinter = null;
      isPrinterConnected = false;
    });
  }

  double get todayTotal {
    final today = DateTime.now();
    return salesHistory
        .where(
          (s) =>
              s.timestamp.year == today.year &&
              s.timestamp.month == today.month &&
              s.timestamp.day == today.day,
        )
        .fold(0.0, (sum, s) => sum + s.total);
  }

  List<SaleRecord> get todaySales {
    final today = DateTime.now();
    return salesHistory
        .where(
          (s) =>
              s.timestamp.year == today.year &&
              s.timestamp.month == today.month &&
              s.timestamp.day == today.day,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      CatalogScreen(shell: this),
      InventoryScreen(shell: this),
      SalesHistoryScreen(shell: this),
      PrinterSettingsScreen(shell: this),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        backgroundColor: AppColors.surface,
        elevation: 0,
        shadowColor: AppColors.shadow,
        indicatorColor: AppColors.primaryBg,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.storefront_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.storefront),
            ),
            label: 'Catalog',
          ),
          const NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Sales',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
