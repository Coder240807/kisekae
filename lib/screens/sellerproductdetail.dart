import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kisekae/models/seller_product.dart';
import 'package:kisekae/screens/edit_product.dart';
import 'package:kisekae/screens/productgallery.dart';
import 'package:kisekae/services/seller_product.dart';

class _ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final VoidCallback? onEdit;
  const _ImageCarousel({required this.imageUrls, this.onEdit});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: urls.isEmpty
                    ? Container(
                        color: const Color(0xFFE5DDD2),
                        child: const Icon(
                          Icons.checkroom,
                          size: 48,
                          color: Colors.grey,
                        ),
                      )
                    : PageView.builder(
                        controller: _pageCtrl,
                        itemCount: urls.length,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemBuilder: (context, index) => Image.network(
                          urls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFE5DDD2),
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            if (widget.onEdit != null)
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: widget.onEdit,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.photo_library_outlined,
                            size: 14,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Edit Photos",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (urls.length > 1)
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${_currentPage + 1}/${urls.length}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (urls.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              urls.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == i ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? const Color(0xFF8B2E3E)
                      : const Color(0xFFE5DDD2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SellerProductDetailScreen extends StatefulWidget {
  final int storeId;
  final int productId;

  const SellerProductDetailScreen({
    super.key,
    required this.storeId,
    required this.productId,
  });

  @override
  State<SellerProductDetailScreen> createState() =>
      _SellerProductDetailScreenState();
}

class _SellerProductDetailScreenState extends State<SellerProductDetailScreen> {
  final HandleProduct _productService = HandleProduct();

  Product? _product;
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
  }

  Future<void> _fetchProductDetails() async {
    setState(() => _isLoading = true);

    try {
      final product = await _productService.getProductDetails(
        storeId: widget.storeId,
        productId: widget.productId,
      );

      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && e is! DioException) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load product details: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteProduct() async {
    if (_product == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFF8F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Delete Product?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to permanently delete '${_product!.name}'? This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "CANCEL",
              style: TextStyle(color: Colors.black54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "DELETE",
              style: TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      await _productService.deleteProduct(
        storeId: widget.storeId,
        productId: widget.productId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Product deleted successfully."),
            backgroundColor: Colors.black87,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete product: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _openManagePhotos([ProductVariant? targetVariant]) async {
    if (_product == null) return;
    final variants = _product!.variants;
    if (variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No variants available to attach photos.'),
        ),
      );
      return;
    }

    ProductVariant? selectedVariant = targetVariant;
    if (selectedVariant == null) {
      if (variants.length == 1) {
        selectedVariant = variants.first;
      } else {
        selectedVariant = await showModalBottomSheet<ProductVariant>(
          context: context,
          backgroundColor: const Color(0xFFFFF8F0),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      child: Text(
                        "Select Variant to Edit Photos",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(color: Color(0xFFE5DDD2)),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: variants.length,
                        itemBuilder: (ctx, i) {
                          final v = variants[i];
                          return ListTile(
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _tryParseHex(v.colorHex) ?? Colors.grey,
                                border: Border.all(color: Colors.black26),
                              ),
                            ),
                            title: Text(v.colorName),
                            subtitle: Text("${v.images.length} photo(s)"),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.pop(ctx, v),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    }

    if (selectedVariant != null && mounted) {
      final refreshed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => ProductGalleryScreen(
            storeId: widget.storeId,
            productId: widget.productId,
            variantId: selectedVariant!.id,
            variantName: selectedVariant.colorName,
            initialPrimaryImageUrl: selectedVariant.thumbnail,
          ),
        ),
      );
      if (refreshed == true && mounted) {
        _fetchProductDetails();
      }
    }
  }

  String _formatCurrency(String amount, String currency) {
    final parsed = double.tryParse(amount) ?? 0.0;
    final symbol = currency.toUpperCase() == 'INR'
        ? '₹'
        : currency.toUpperCase() == 'USD'
        ? '\$'
        : currency;
    return '$symbol${parsed.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _getStatusStyle(String status, int totalStock) {
    if (totalStock == 0 || status.toUpperCase() == 'OUT_OF_STOCK') {
      return {
        'label': 'OUT OF STOCK',
        'color': const Color(0xFFE53935),
        'bgColor': const Color(0xFFFFEBEE),
      };
    } else if (totalStock < 50 || status.toUpperCase() == 'LOW_STOCK') {
      return {
        'label': 'LOW STOCK',
        'color': const Color(0xFFE65100),
        'bgColor': const Color(0xFFFFE0B2),
      };
    } else if (status.toUpperCase() == 'ACTIVE') {
      return {
        'label': 'ACTIVE',
        'color': const Color(0xFF2E7D32),
        'bgColor': const Color(0xE8E8F5E9),
      };
    } else {
      return {
        'label': status.toUpperCase(),
        'color': const Color(0xFF616161),
        'bgColor': const Color(0xFFEEEEEE),
      };
    }
  }

  Color? _tryParseHex(String hex) {
    try {
      final clean = hex.replaceFirst('#', '');
      if (clean.length == 6) {
        return Color(int.parse('FF$clean', radix: 16));
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFEFE8DF);
    const primaryColor = Color(0xFF8B2E3E);
    const cardBackgroundColor = Color(0xFFFFF8F0);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (_product == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Product details not available"),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: primaryColor),
                onPressed: _fetchProductDetails,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final product = _product!;
    final statusStyle = _getStatusStyle(product.status, product.totalStock);

    final allImages = <String>[
      for (final v in product.variants)
        for (final img in v.images)
          if (img.imageUrl.isNotEmpty) img.imageUrl,
    ];
    if (allImages.isEmpty) {
      if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
        allImages.add(product.imageUrl!);
      } else if (product.thumbnail != null && product.thumbnail!.isNotEmpty) {
        allImages.add(product.thumbnail!);
      }
    }

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
          "Product Details",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_note,
              color: Color(0xFF8B2E3E),
              size: 26,
            ),
            onPressed: () async {
              final updatedProduct = await Navigator.push<Product>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProductScreen(product: product),
                ),
              );

              if (updatedProduct != null) {
                setState(() {
                  _product = updatedProduct;
                });
              }
            },
          ),
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFE53935),
                    ),
                  )
                : const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE53935),
                    size: 24,
                  ),
            onPressed: _isDeleting ? null : _handleDeleteProduct,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: _fetchProductDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5DDD2)),
                ),
                child: Column(
                  children: [
                    _ImageCarousel(
                      imageUrls: allImages,
                      onEdit: () => _openManagePhotos(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusStyle['bgColor'] as Color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusStyle['label'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusStyle['color'] as Color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5DDD2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pricing & Stock Overview",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Divider(height: 20, color: Color(0xFFE5DDD2)),
                    Row(
                      children: [
                        Expanded(
                          child: _metricTile(
                            label: "Selling Price",
                            value: _formatCurrency(
                              product.price,
                              product.currency,
                            ),
                            isPrimary: true,
                          ),
                        ),
                        if (product.compareAtPrice != null &&
                            product.compareAtPrice!.isNotEmpty)
                          Expanded(
                            child: _metricTile(
                              label: "Compare Price",
                              value: _formatCurrency(
                                product.compareAtPrice!,
                                product.currency,
                              ),
                              isStrikethrough: true,
                            ),
                          ),
                        Expanded(
                          child: _metricTile(
                            label: "Total Stock",
                            value: "${product.totalStock} units",
                            isHighlight: product.totalStock < 50,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5DDD2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Product Information",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Divider(height: 20, color: Color(0xFFE5DDD2)),
                    _infoRow("SKU", product.sku ?? "N/A"),
                    const SizedBox(height: 10),
                    _infoRow("Store Name", product.storeName),
                    const SizedBox(height: 10),
                    _infoRow("Store ID", product.storeId.toString()),
                    const SizedBox(height: 10),
                    _infoRow("Slug", product.slug),
                    const SizedBox(height: 10),
                    _infoRow("Created Date", _formatDate(product.createdAt)),
                    const SizedBox(height: 10),
                    _infoRow("Last Updated", _formatDate(product.updatedAt)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (product.variants.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5DDD2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Variants (${product.variants.length})",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Divider(height: 20, color: Color(0xFFE5DDD2)),
                      for (final variant in product.variants) ...[
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    _tryParseHex(variant.colorHex) ??
                                    Colors.grey,
                                border: Border.all(color: Colors.black26),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                variant.colorName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Text(
                              "${variant.totalStock} units",
                              style: TextStyle(
                                fontSize: 12,
                                color: variant.totalStock < 10
                                    ? const Color(0xFFE65100)
                                    : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (variant.sizes.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              for (final sz in variant.sizes)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEEEEE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "${sz.size}: ${sz.stock}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: () => _openManagePhotos(variant),
                            icon: const Icon(
                              Icons.photo_library_outlined,
                              size: 16,
                              color: Color(0xFF8B2E3E),
                            ),
                            label: Text(
                              "Manage Photos"
                              "${variant.images.isNotEmpty ? ' (${variant.images.length})' : ''}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF8B2E3E),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              side: const BorderSide(
                                color: Color(0xFF8B2E3E),
                                width: 1,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              if (product.description != null &&
                  product.description!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5DDD2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Description",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Divider(height: 20, color: Color(0xFFE5DDD2)),
                      Text(
                        product.description!,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricTile({
    required String label,
    required String value,
    bool isPrimary = false,
    bool isStrikethrough = false,
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            decoration: isStrikethrough
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: isHighlight
                ? const Color(0xFFE65100)
                : isPrimary
                ? const Color(0xFF8B2E3E)
                : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
