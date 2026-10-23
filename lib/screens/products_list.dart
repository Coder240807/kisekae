import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kisekae/models/product_detail.dart';
import 'package:kisekae/services/buyer_product.dart';

import 'package:kisekae/services/wishlist_service.dart';

class FilterChipData {
  final String label;
  final String? ordering;
  final String? category;
  final bool? inStock;
  final double? maxPrice;

  const FilterChipData({
    required this.label,
    this.ordering,
    this.category,
    this.inStock,
    this.maxPrice,
  });
}

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final Product _productService = Product();
  final WishlistService _wishlistService = WishlistService();
  final TextEditingController _searchController = TextEditingController();

  CancelToken? _searchCancelToken;

  List<ProductDetail> _products = [];
  final Set<int> _wishlistedProductIds = {};

  bool _isLoading = true;
  String _searchQuery = '';

  final List<FilterChipData> _apiFilters = const [
    FilterChipData(label: "Top Rated", ordering: "top_rated"),
    FilterChipData(label: "In Stock", inStock: true),
    FilterChipData(label: "Tops", category: "Top"),
    FilterChipData(label: "One-Piece", category: "ONE_PIECE"),
    FilterChipData(label: "Newest", ordering: "newest"),
    FilterChipData(label: "Under ₹500", maxPrice: 500.0),
  ];

  FilterChipData? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _searchCancelToken?.cancel("Screen disposed");
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    // Safely cancel any pending network request before starting a new search
    _searchCancelToken?.cancel("New search request initiated");
    _searchCancelToken = CancelToken();

    setState(() => _isLoading = true);
    try {
      final response = await _productService.getProducts(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        ordering: _selectedFilter?.ordering,
        category: _selectedFilter?.category,
        inStock: _selectedFilter?.inStock,
        maxPrice: _selectedFilter?.maxPrice,
        cancelToken: _searchCancelToken,
      );

      if (mounted) {
        setState(() {
          _products = response.results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        // Request was cancelled intentionally due to a newer search/filter action
        return;
      }
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _toggleWishlist(ProductDetail product) async {
    final productId = product.id;
    final isWishlisted = _wishlistedProductIds.contains(productId);

    setState(() {
      if (isWishlisted) {
        _wishlistedProductIds.remove(productId);
      } else {
        _wishlistedProductIds.add(productId);
      }
    });

    try {
      if (!isWishlisted) {
        await _wishlistService.addToWishlist(productId: productId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} added to wishlist'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (isWishlisted) {
            _wishlistedProductIds.add(productId);
          } else {
            _wishlistedProductIds.remove(productId);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wishlist update failed: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFEFE8DF);
    const primaryColor = Color(0xFF8B2E3E);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.black,
            ),
          ),
        ),
        titleSpacing: 0,
        title: Container(
          height: 46,
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFBF8F5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFD3C7B8)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.black87, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (value) {
                    FocusScope.of(context)
                        .unfocus(); // Unfocus keyboard immediately
                    _searchQuery = value.trim();
                    _fetchProducts();
                  },
                  decoration: const InputDecoration(
                    hintText: "EXPLORE YOUR STYLE",
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    _searchController.clear();
                    _searchQuery = '';
                    _fetchProducts();
                  },
                  child: const Icon(
                    Icons.clear,
                    color: Colors.black54,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFFBF8F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD3C7B8)),
              ),
              child: IconButton(
                icon: const Icon(Icons.tune, color: Colors.black, size: 20),
                onPressed: () {
                  // Trigger custom filter bottom sheet
                },
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Backend-Connected Horizontal Filter Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _apiFilters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final filter = _apiFilters[index];
                  final isSelected = _selectedFilter == filter;

                  return GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _selectedFilter = isSelected ? null : filter;
                      });
                      _fetchProducts();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF8B2E3E)
                            : const Color(0xFFFBF8F5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF8B2E3E)
                              : const Color(0xFFD3C7B8),
                        ),
                      ),
                      child: Text(
                        filter.label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Product Grid Area
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchProducts,
                      color: primaryColor,
                      child: _products.isEmpty
                          ? const Center(
                              child: Text(
                                "No products found",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            )
                          : GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _products.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.68,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 16,
                                  ),
                              itemBuilder: (context, index) {
                                final product = _products[index];
                                return _buildProductCard(product);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductDetail product) {
    final isWishlisted = _wishlistedProductIds.contains(product.id);
    final imageUrl = product.imageUrl ?? product.thumbnail ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFE0D8CD),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageUrl.startsWith('http')
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/clothes/4.jpg',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        imageUrl.isNotEmpty
                            ? imageUrl
                            : 'assets/images/clothes/4.jpg',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFD3C7B8),
                          child: const Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.black38,
                          ),
                        ),
                      ),
              ),

              // Wishlist Icon Container
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => _toggleWishlist(product),
                  child: Container(
                    height: 32,
                    width: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        isWishlisted
                            ? 'assets/icons/wishlist.png'
                            : 'assets/icons/wishlist1.png',
                        width: 18,
                        height: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 2),
                const Text(
                  "5.0",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
        Text(
          "₹${double.tryParse(product.price)?.toInt() ?? product.price}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
