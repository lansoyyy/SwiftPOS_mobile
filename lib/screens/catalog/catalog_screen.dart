import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../core/constants/app_colors.dart';
import '../main_shell.dart';
import '../checkout/checkout_screen.dart';

class CatalogScreen extends StatefulWidget {
  final MainShellState shell;
  const CatalogScreen({super.key, required this.shell});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _search = '';
  String _category = 'All';
  String _sortBy = 'name'; // name, price, stock
  String _stockFilter = 'all'; // all, inStock, lowStock, outOfStock
  double? _minPrice;
  double? _maxPrice;
  final _searchCtrl = TextEditingController();
  List<String> _categories = ['All'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await widget.shell.getCategories();
    if (mounted) {
      setState(() {
        _categories = ['All', ...categories];
      });
    }
  }

  List<Product> get _filtered {
    var products = widget.shell.products.where((p) {
      // Category filter
      final matchCat = _category == 'All' || p.category == _category;

      // Search filter (name and category)
      final searchLower = _search.toLowerCase();
      final matchSearch =
          p.name.toLowerCase().contains(searchLower) ||
          p.category.toLowerCase().contains(searchLower);

      // Stock filter
      bool matchStock = true;
      switch (_stockFilter) {
        case 'inStock':
          matchStock = p.stock > 0;
          break;
        case 'lowStock':
          matchStock = p.stock > 0 && p.stock <= 5;
          break;
        case 'outOfStock':
          matchStock = p.stock == 0;
          break;
        default:
          matchStock = true;
      }

      // Price range filter
      bool matchPrice = true;
      if (_minPrice != null) {
        matchPrice = matchPrice && p.price >= _minPrice!;
      }
      if (_maxPrice != null) {
        matchPrice = matchPrice && p.price <= _maxPrice!;
      }

      return matchCat && matchSearch && matchStock && matchPrice;
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'price_asc':
        products.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_desc':
        products.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'stock':
        products.sort((a, b) => b.stock.compareTo(a.stock));
        break;
      case 'name':
      default:
        products.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        break;
    }

    return products;
  }

  int _qtyInCart(String productId) {
    final idx = widget.shell.cart.indexWhere((i) => i.product.id == productId);
    return idx >= 0 ? widget.shell.cart[idx].quantity : 0;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartTotal = widget.shell.cartTotal;
    final cartCount = widget.shell.cartCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(child: _buildGrid()),
          ],
        ),
      ),
      bottomNavigationBar: cartCount > 0
          ? _CartBar(
              total: cartTotal,
              count: cartCount,
              onCheckout: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckoutScreen(shell: widget.shell),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SwiftPOS',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontFamily: 'Urbanist',
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Select items to sell',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ],
            ),
          ),
          // IconButton(
          //   onPressed: () => _showScanDialog(context),
          //   icon: Container(
          //     padding: const EdgeInsets.all(8),
          //     decoration: BoxDecoration(
          //       color: AppColors.primary,
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     child: const Icon(
          //       Icons.qr_code_scanner,
          //       color: Colors.white,
          //       size: 22,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              style: const TextStyle(fontFamily: 'Urbanist', fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _search = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    final hasActiveFilters =
        _category != 'All' ||
        _stockFilter != 'all' ||
        _minPrice != null ||
        _maxPrice != null ||
        _sortBy != 'name';

    return GestureDetector(
      onTap: () => _showFilterBottomSheet(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasActiveFilters ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasActiveFilters ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Icon(
          Icons.tune,
          size: 20,
          color: hasActiveFilters ? Colors.white : AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterBottomSheet(
        category: _category,
        categories: _categories,
        stockFilter: _stockFilter,
        sortBy: _sortBy,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        onApply: (category, stockFilter, sortBy, minPrice, maxPrice) {
          setState(() {
            _category = category;
            _stockFilter = stockFilter;
            _sortBy = sortBy;
            _minPrice = minPrice;
            _maxPrice = maxPrice;
          });
        },
        onClear: () {
          setState(() {
            _category = 'All';
            _stockFilter = 'all';
            _sortBy = 'name';
            _minPrice = null;
            _maxPrice = null;
          });
        },
      ),
    );
  }

  void _showVariantDialog(Product product) {
    if (product.variants.isEmpty) {
      widget.shell.addToCart(product);
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Select Variant',
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...product.variants.map((variant) {
              final price = variant.priceOverride ?? product.price;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    widget.shell.addToCart(product, variant: variant);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${variant.size} / ${variant.color}',
                              style: const TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Stock: ${variant.stock}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Urbanist'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final activeFilters = <String>[];

    if (_category != 'All') {
      activeFilters.add(_category);
    }
    if (_stockFilter != 'all') {
      switch (_stockFilter) {
        case 'inStock':
          activeFilters.add('In Stock');
          break;
        case 'lowStock':
          activeFilters.add('Low Stock');
          break;
        case 'outOfStock':
          activeFilters.add('Out of Stock');
          break;
      }
    }
    if (_minPrice != null || _maxPrice != null) {
      final min = _minPrice?.toStringAsFixed(0) ?? '0';
      final max = _maxPrice?.toStringAsFixed(0) ?? '∞';
      activeFilters.add('P$min - P$max');
    }
    if (_sortBy != 'name') {
      switch (_sortBy) {
        case 'price_asc':
          activeFilters.add('Price: Low to High');
          break;
        case 'price_desc':
          activeFilters.add('Price: High to Low');
          break;
        case 'stock':
          activeFilters.add('Stock: High to Low');
          break;
      }
    }

    if (activeFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: activeFilters.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return _FilterChip(
              label: 'Clear All',
              isSelected: false,
              onTap: () {
                setState(() {
                  _category = 'All';
                  _stockFilter = 'all';
                  _sortBy = 'name';
                  _minPrice = null;
                  _maxPrice = null;
                });
              },
              isClear: true,
            );
          }
          return _FilterChip(
            label: activeFilters[i - 1],
            isSelected: true,
            onTap: () {},
          );
        },
      ),
    );
  }

  Widget _buildGrid() {
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off, size: 48, color: AppColors.gray300),
            ),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontFamily: 'Urbanist',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontFamily: 'Urbanist',
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => _ProductCard(
        product: _filtered[i],
        qtyInCart: _qtyInCart(_filtered[i].id),
        onAdd: () {
          if (_filtered[i].variants.isNotEmpty) {
            _showVariantDialog(_filtered[i]);
          } else {
            widget.shell.addToCart(_filtered[i]);
          }
        },
        onRemove: () {
          final qty = _qtyInCart(_filtered[i].id);
          widget.shell.updateQty(_filtered[i].id, qty - 1);
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final int qtyInCart;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _ProductCard({
    required this.product,
    required this.qtyInCart,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.stock <= 5;
    final inCart = qtyInCart > 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon area
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              color: product.color.withOpacity(0.12),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(product.icon, size: 44, color: product.color),
                ),
                if (product.variants.isNotEmpty)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.info,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Var',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),
                  ),
                if (inCart)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$qtyInCart',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'P${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isLowStock
                              ? AppColors.errorLight
                              : AppColors.gray100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isLowStock
                              ? 'Low: ${product.stock}'
                              : '${product.stock} pcs',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isLowStock
                                ? AppColors.error
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (product.stock == 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.gray200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.block,
                            size: 16,
                            color: AppColors.textTertiary,
                          ),
                        )
                      else if (inCart)
                        Row(
                          children: [
                            GestureDetector(
                              onTap: onRemove,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.gray100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.remove, size: 14),
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: onAdd,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        GestureDetector(
                          onTap: onAdd,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  final double total;
  final int count;
  final VoidCallback onCheckout;

  const _CartBar({
    required this.total,
    required this.count,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count item${count > 1 ? 's' : ''}',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Urbanist',
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Text(
            'P${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Urbanist',
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onCheckout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Checkout →',
                style: TextStyle(
                  color: AppColors.primary,
                  fontFamily: 'Urbanist',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isClear;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isClear = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isClear
              ? AppColors.gray200
              : (isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isClear
                ? AppColors.gray300
                : (isSelected ? AppColors.primary : AppColors.border),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isClear)
              Icon(Icons.clear, size: 14, color: AppColors.textSecondary),
            if (isClear) const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isClear
                    ? AppColors.textSecondary
                    : (isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final String category;
  final List<String> categories;
  final String stockFilter;
  final String sortBy;
  final double? minPrice;
  final double? maxPrice;
  final Function(String, String, String, double?, double?) onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    required this.category,
    required this.categories,
    required this.stockFilter,
    required this.sortBy,
    required this.minPrice,
    required this.maxPrice,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _category;
  late String _stockFilter;
  late String _sortBy;
  late TextEditingController _minPriceCtrl;
  late TextEditingController _maxPriceCtrl;

  @override
  void initState() {
    super.initState();
    _category = widget.category;
    _stockFilter = widget.stockFilter;
    _sortBy = widget.sortBy;
    _minPriceCtrl = TextEditingController(
      text: widget.minPrice?.toStringAsFixed(2) ?? '',
    );
    _maxPriceCtrl = TextEditingController(
      text: widget.maxPrice?.toStringAsFixed(2) ?? '',
    );
  }

  @override
  void dispose() {
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category
                  _buildSectionTitle('Category'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.categories.map((cat) {
                      final isSelected = _category == cat;
                      return _FilterOptionChip(
                        label: cat,
                        isSelected: isSelected,
                        onTap: () => setState(() => _category = cat),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Stock Status
                  _buildSectionTitle('Stock Status'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterOptionChip(
                        label: 'All',
                        isSelected: _stockFilter == 'all',
                        onTap: () => setState(() => _stockFilter = 'all'),
                      ),
                      _FilterOptionChip(
                        label: 'In Stock',
                        isSelected: _stockFilter == 'inStock',
                        onTap: () => setState(() => _stockFilter = 'inStock'),
                      ),
                      _FilterOptionChip(
                        label: 'Low Stock',
                        isSelected: _stockFilter == 'lowStock',
                        onTap: () => setState(() => _stockFilter = 'lowStock'),
                      ),
                      _FilterOptionChip(
                        label: 'Out of Stock',
                        isSelected: _stockFilter == 'outOfStock',
                        onTap: () =>
                            setState(() => _stockFilter = 'outOfStock'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Price Range
                  _buildSectionTitle('Price Range'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Min',
                            prefixText: 'P',
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'to',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Max',
                            prefixText: 'P',
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Sort By
                  _buildSectionTitle('Sort By'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _FilterOptionChip(
                        label: 'Name (A-Z)',
                        isSelected: _sortBy == 'name',
                        onTap: () => setState(() => _sortBy = 'name'),
                      ),
                      _FilterOptionChip(
                        label: 'Price (Low to High)',
                        isSelected: _sortBy == 'price_asc',
                        onTap: () => setState(() => _sortBy = 'price_asc'),
                      ),
                      _FilterOptionChip(
                        label: 'Price (High to Low)',
                        isSelected: _sortBy == 'price_desc',
                        onTap: () => setState(() => _sortBy = 'price_desc'),
                      ),
                      _FilterOptionChip(
                        label: 'Stock (High to Low)',
                        isSelected: _sortBy == 'stock',
                        onTap: () => setState(() => _sortBy = 'stock'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Apply Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  final minPrice = _minPriceCtrl.text.isEmpty
                      ? null
                      : double.tryParse(_minPriceCtrl.text);
                  final maxPrice = _maxPriceCtrl.text.isEmpty
                      ? null
                      : double.tryParse(_maxPriceCtrl.text);
                  widget.onApply(
                    _category,
                    _stockFilter,
                    _sortBy,
                    minPrice,
                    maxPrice,
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Urbanist',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _FilterOptionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOptionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
