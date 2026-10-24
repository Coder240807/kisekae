import 'package:flutter/material.dart';

import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/models/seller_product.dart';
import 'package:kisekae/screens/sellerproductdetail.dart';
import 'package:kisekae/services/seller_product.dart';

class InventoryScreen extends StatefulWidget {
  final int storeId;

  const InventoryScreen({super.key, required this.storeId});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  static const _lowStockLimit = 50;

  final HandleProduct _productService = HandleProduct();

  bool _isLoading = true;
  List<Product> _allProducts = [];
  String _selectedFilter = 'Current Stock';

  final List<String> _filters = ['Current Stock', 'Low Stock', 'Out of Stock'];

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts({bool showLoader = true}) async {
    if (showLoader) setState(() => _isLoading = true);

    try {
      final response = await _productService.getStoreProducts(
        storeId: widget.storeId,
        status: 'ACTIVE',
      );

      if (!mounted) return;
      setState(() {
        _allProducts = response.results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final message = e is ApiException
          ? e.message
          : 'Failed to load inventory';
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  List<Product> _visibleProducts() {
    switch (_selectedFilter) {
      case 'Low Stock':
        return _allProducts
            .where((p) => p.stock > 0 && p.stock < _lowStockLimit)
            .toList();
      case 'Out of Stock':
        return _allProducts.where((p) => p.stock <= 0).toList();
      default:
        return _allProducts.where((p) => p.stock > 0).toList();
    }
  }

  Map<String, dynamic> _getStatusDisplay(Product product) {
    if (product.stock <= 0) {
      return {'text': 'Out of stock', 'color': const Color(0xFFE53935)};
    } else if (product.stock < _lowStockLimit) {
      return {'text': 'Low stock', 'color': const Color(0xFFFF8A65)};
    } else {
      return {'text': 'In stock', 'color': const Color(0xFF4CAF50)};
    }
  }

  void _openProduct(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SellerProductDetailScreen(
          storeId: widget.storeId,
          productId: product.id,
        ),
      ),
    ).then((_) {
      // Reload quietly when coming back, so edits made there show up here.
      if (mounted) _fetchProducts(showLoader: false);
    });
  }

  Widget _productCard(Product product) {
    const cardBackgroundColor = Color(0xFFFFF8F0);
    final statusDisplay = _getStatusDisplay(product);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openProduct(product),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5DDD2)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? Image.network(
                      product.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: const Color(0xFFE5DDD2),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: const Color(0xFFE5DDD2),
                      child: const Icon(Icons.checkroom, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (product.sku?.trim().isNotEmpty ?? false)
                        ? "Product no. - ${product.sku}"
                        : "Product no. - ${product.id}",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Stock - ${product.stock}",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "Status - ",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        statusDisplay['text'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: statusDisplay['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFEFE8DF);
    const primaryColor = Color(0xFF8B2E3E);

    final products = _visibleProducts();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Inventory",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: GestureDetector(
                      onTap: () {
                        if (_selectedFilter != filter) {
                          setState(() => _selectedFilter = filter);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primaryColor, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : products.isEmpty
                ? Center(
                    child: Text(
                      "No products found",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    color: primaryColor,
                    onRefresh: () => _fetchProducts(showLoader: false),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) =>
                          _productCard(products[index]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
