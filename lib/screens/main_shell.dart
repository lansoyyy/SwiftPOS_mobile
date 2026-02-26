import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../models/sale_record.dart';
import '../models/printer_settings.dart';
import '../models/tax_settings.dart';
import '../models/discount.dart';
import '../models/receipt_settings.dart';
import '../core/constants/app_colors.dart';
import '../data/repositories/product_repository.dart';
import '../data/repositories/sale_record_repository.dart';
import '../data/repositories/printer_settings_repository.dart';
import '../data/repositories/receipt_settings_repository.dart';
import '../data/bluetooth/bluetooth_service.dart';
import '../data/bluetooth/esc_pos_service.dart';
import 'catalog/catalog_screen.dart';
import 'inventory/inventory_screen.dart';
import 'sales/sales_history_screen.dart';
import 'analytics/analytics_screen.dart';
import 'settings/printer_settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  // Repositories
  final ProductRepository _productRepo = ProductRepository();
  final SaleRecordRepository _saleRepo = SaleRecordRepository();
  final PrinterSettingsRepository _printerRepo = PrinterSettingsRepository();
  final ReceiptSettingsRepository _receiptSettingsRepo =
      ReceiptSettingsRepository();

  // Bluetooth Service
  final BluetoothService _bluetoothService = BluetoothService();
  late final EscPosService _escPosService;

  // State
  List<Product> _products = [];
  final List<CartItem> cart = [];
  List<SaleRecord> _salesHistory = [];
  String? connectedPrinter;
  bool isPrinterConnected = false;
  bool _isLoading = true;
  TaxSettings taxSettings = const TaxSettings();
  Discount? orderDiscount;

  @override
  void initState() {
    super.initState();
    _escPosService = EscPosService(_bluetoothService);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load products from database
    _products = await _productRepo.getAllProducts();

    // Load sales history from database
    _salesHistory = await _saleRepo.getAllSales();

    // Load printer settings from database
    final printerSettings = await _printerRepo.getPrinterSettings();
    if (printerSettings != null) {
      connectedPrinter = printerSettings.printerName;
      isPrinterConnected = printerSettings.isConnected;
    }

    setState(() => _isLoading = false);
  }

  // Cart
  void addToCart(Product product, {ProductVariant? variant}) {
    setState(() {
      final idx = cart.indexWhere((i) => i.product.id == product.id);
      if (idx >= 0) {
        // Check if same variant
        if (cart[idx].variant?.id == variant?.id) {
          cart[idx].quantity++;
        } else {
          cart.add(CartItem(product: product, variant: variant));
        }
      } else {
        cart.add(CartItem(product: product, variant: variant));
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

  void incrementQty(String productId) {
    setState(() {
      final idx = cart.indexWhere((i) => i.product.id == productId);
      if (idx >= 0) {
        cart[idx].quantity++;
      }
    });
  }

  void decrementQty(String productId) {
    setState(() {
      final idx = cart.indexWhere((i) => i.product.id == productId);
      if (idx >= 0) {
        if (cart[idx].quantity > 1) {
          cart[idx].quantity--;
        } else {
          cart.removeAt(idx);
        }
      }
    });
  }

  void setPriceOverride(String productId, double? priceOverride) {
    setState(() {
      final idx = cart.indexWhere((i) => i.product.id == productId);
      if (idx >= 0) {
        cart[idx] = cart[idx].copyWith(priceOverride: priceOverride);
      }
    });
  }

  void setCartItemVariant(String productId, ProductVariant? variant) {
    setState(() {
      final idx = cart.indexWhere((i) => i.product.id == productId);
      if (idx >= 0) {
        cart[idx] = cart[idx].copyWith(variant: variant);
      }
    });
  }

  void clearCart() => setState(() {
    cart.clear();
    orderDiscount = null;
  });

  double get cartSubtotal => cart.fold(0.0, (s, i) => s + i.basePrice);

  double get cartItemDiscounts =>
      cart.fold(0.0, (s, i) => s + i.discountAmount);

  double get cartSubtotalAfterDiscounts => cartSubtotal - cartItemDiscounts;

  double get cartOrderDiscount =>
      orderDiscount?.applyTo(cartSubtotalAfterDiscounts) ?? 0.0;

  double get cartTaxableAmount =>
      cartSubtotalAfterDiscounts - cartOrderDiscount;

  double get cartTaxAmount =>
      taxSettings.enabled ? cartTaxableAmount * (taxSettings.rate / 100) : 0.0;

  double get cartTotal => cartTaxableAmount + cartTaxAmount;

  int get cartCount => cart.fold(0, (s, i) => s + i.quantity);

  // Tax & Discount
  void setTaxSettings(TaxSettings settings) {
    setState(() => taxSettings = settings);
  }

  void setOrderDiscount(Discount? discount) {
    setState(() => orderDiscount = discount);
  }

  void setItemDiscount(String productId, Discount? discount) {
    setState(() {
      final idx = cart.indexWhere((i) => i.product.id == productId);
      if (idx >= 0) {
        cart[idx] = cart[idx].copyWith(discount: discount);
      }
    });
  }

  // Sales
  Future<SaleRecord> completeSale(
    String paymentMethod, {
    double? amountPaid,
    List<String>? paymentMethods,
  }) async {
    final subtotal = cartSubtotal;
    final totalDiscount = cartItemDiscounts + cartOrderDiscount;
    final taxAmount = cartTaxAmount;
    final total = cartTotal;

    final items = cart
        .map(
          (i) => CartItem(
            product: i.product,
            quantity: i.quantity,
            discount: i.discount,
          ),
        )
        .toList();

    final record = SaleRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: items,
      subtotal: subtotal,
      totalDiscount: totalDiscount,
      taxAmount: taxAmount,
      total: total,
      timestamp: DateTime.now(),
      paymentMethod: paymentMethod,
      paymentMethods: paymentMethods ?? [paymentMethod],
      amountPaid: amountPaid,
      change: amountPaid != null ? amountPaid - total : null,
      orderDiscount: orderDiscount,
    );

    // Save sale to database
    await _saleRepo.insertSale(record);

    // Update product stocks
    for (final item in cart) {
      await _productRepo.decrementProductStock(item.product.id, item.quantity);
    }

    // Reload products and sales
    await _reloadProducts();
    await _reloadSales();

    // Clear cart
    setState(() => cart.clear());

    return record;
  }

  // Inventory
  Future<void> updateStock(String productId, int newStock) async {
    await _productRepo.updateProductStock(productId, newStock);
    await _reloadProducts();
  }

  Future<void> addProduct(Product product) async {
    await _productRepo.insertProduct(product);
    await _reloadProducts();
  }

  Future<void> deleteProduct(String productId) async {
    await _productRepo.deleteProduct(productId);
    await _reloadProducts();
  }

  Future<void> updateProduct(Product product) async {
    await _productRepo.updateProduct(product);
    await _reloadProducts();
  }

  // Printer
  Future<void> connectPrinter(String name, String address) async {
    final connected = await _bluetoothService.connect(address);
    if (connected) {
      final settings = PrinterSettings(
        printerName: name,
        printerAddress: address,
        isConnected: true,
        lastConnected: DateTime.now(),
      );
      await _printerRepo.savePrinterSettings(settings);
      setState(() {
        connectedPrinter = name;
        isPrinterConnected = true;
      });
    }
  }

  Future<void> disconnectPrinter() async {
    await _bluetoothService.disconnect();
    await _printerRepo.disconnectPrinter();
    setState(() {
      connectedPrinter = null;
      isPrinterConnected = false;
    });
  }

  // Bluetooth Methods
  Future<bool> initializeBluetooth() async {
    return await _bluetoothService.initialize();
  }

  Future<bool> enableBluetooth() async {
    return await _bluetoothService.enableBluetooth();
  }

  Future<void> startBluetoothScan() async {
    await _bluetoothService.startScan();
  }

  Future<void> stopBluetoothScan() async {
    await _bluetoothService.stopScan();
  }

  bool get isBluetoothEnabled => _bluetoothService.isEnabled;
  bool get isBluetoothScanning => _bluetoothService.isScanning;
  List<BluetoothDeviceModel> get bluetoothDevices =>
      _bluetoothService.discoveredDevices;
  Stream<BluetoothState> get onBluetoothStateChanged =>
      _bluetoothService.onStateChanged;
  Stream<List<BluetoothDeviceModel>> get onBluetoothDevicesChanged =>
      _bluetoothService.onDevicesChanged;
  Stream<bool> get onBluetoothScanningChanged =>
      _bluetoothService.onScanningChanged;

  // Print Methods
  Future<bool> printReceipt(
    SaleRecord sale, {
    ReceiptSettings? receiptSettings,
  }) async {
    return await _escPosService.printReceipt(sale, settings: receiptSettings);
  }

  Future<bool> printTestReceipt({ReceiptSettings? receiptSettings}) async {
    return await _escPosService.printTestReceipt(settings: receiptSettings);
  }

  Future<bool> printText(
    String text, {
    bool bold = false,
    bool center = false,
  }) async {
    return await _escPosService.printText(text, bold: bold, center: center);
  }

  // Getters for screens
  List<Product> get products => _products;
  List<SaleRecord> get salesHistory => _salesHistory;

  // Get categories from database
  Future<List<String>> getCategories() async {
    return await _productRepo.getCategories();
  }

  double get todayTotal {
    final today = DateTime.now();
    return _salesHistory
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
    return _salesHistory
        .where(
          (s) =>
              s.timestamp.year == today.year &&
              s.timestamp.month == today.month &&
              s.timestamp.day == today.day,
        )
        .toList();
  }

  // Private helpers
  Future<void> _reloadProducts() async {
    _products = await _productRepo.getAllProducts();
    if (mounted) setState(() {});
  }

  Future<void> _reloadSales() async {
    _salesHistory = await _saleRepo.getAllSales();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final screens = [
      CatalogScreen(shell: this),
      InventoryScreen(shell: this),
      SalesHistoryScreen(shell: this),
      AnalyticsScreen(shell: this),
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
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Analytics',
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
