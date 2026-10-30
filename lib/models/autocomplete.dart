class AutocompleteResponse {
  final AutocompleteData? data;
  final bool success;
  final String message;

  AutocompleteResponse({
    this.data,
    required this.success,
    required this.message,
  });

  factory AutocompleteResponse.fromJson(Map<String, dynamic> json) {
    return AutocompleteResponse(
      data: json['data'] != null
          ? AutocompleteData.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
    );
  }
}

class AutocompleteData {
  final String query;
  final List<String> queries;
  final List<InstantProduct> instantProducts;

  AutocompleteData({
    required this.query,
    required this.queries,
    required this.instantProducts,
  });

  factory AutocompleteData.fromJson(Map<String, dynamic> json) {
    return AutocompleteData(
      query: json['query']?.toString() ?? '',
      queries:
          (json['queries'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      instantProducts:
          (json['instant_products'] as List<dynamic>?)
              ?.map(
                (e) => InstantProduct.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          [],
    );
  }
}

class InstantProduct {
  final int id;
  final int store;
  final String storeName;
  final String storeSlug;
  final String name;
  final String slug;
  final String price;
  final String? compareAtPrice;
  final String currency;
  final String? thumbnail;
  final String? imageUrl;
  final String productType;
  final String productTypeDisplay;
  final String category;
  final String categoryDisplay;
  final String? color;
  final int stock;
  final int totalStock;
  final bool isInStock;
  final List<String> availableSizes;
  final num averageRating;
  final int reviewCount;
  final String createdAt;

  InstantProduct({
    required this.id,
    required this.store,
    required this.storeName,
    required this.storeSlug,
    required this.name,
    required this.slug,
    required this.price,
    this.compareAtPrice,
    required this.currency,
    this.thumbnail,
    this.imageUrl,
    required this.productType,
    required this.productTypeDisplay,
    required this.category,
    required this.categoryDisplay,
    this.color,
    required this.stock,
    required this.totalStock,
    required this.isInStock,
    required this.availableSizes,
    required this.averageRating,
    required this.reviewCount,
    required this.createdAt,
  });

  factory InstantProduct.fromJson(Map<String, dynamic> json) {
    return InstantProduct(
      id: json['id'] ?? 0,
      store: json['store'] ?? 0,
      storeName: json['store_name']?.toString() ?? '',
      storeSlug: json['store_slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      compareAtPrice: json['compare_at_price']?.toString(),
      currency: json['currency']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString(),
      imageUrl: json['image_url']?.toString(),
      productType: json['product_type']?.toString() ?? '',
      productTypeDisplay: json['product_type_display']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      categoryDisplay: json['category_display']?.toString() ?? '',
      color: json['color']?.toString(),
      stock: json['stock'] ?? 0,
      totalStock: json['total_stock'] ?? 0,
      isInStock: json['is_in_stock'] ?? false,
      availableSizes:
          (json['available_sizes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      averageRating: json['average_rating'] ?? 0,
      reviewCount: json['review_count'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
