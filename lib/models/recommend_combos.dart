class RecommendedComboResponse {
  final List<ComboLook> data;
  final bool success;
  final String message;

  RecommendedComboResponse({
    required this.data,
    required this.success,
    required this.message,
  });

  factory RecommendedComboResponse.fromJson(Map<String, dynamic> json) {
    return RecommendedComboResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => ComboLook.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      success: json['success'] ?? false,
      message: json['message']?.toString() ?? '',
    );
  }
}

class ComboLook {
  final String id;
  final String title;
  final String lookType;
  final bool isLayered;
  final num score;
  final String totalPrice;
  final String currency;
  final bool isTryonReady;
  final List<int> productIds;
  final List<RecommendedComboItem> items; // Updated class reference

  ComboLook({
    required this.id,
    required this.title,
    required this.lookType,
    required this.isLayered,
    required this.score,
    required this.totalPrice,
    required this.currency,
    required this.isTryonReady,
    required this.productIds,
    required this.items,
  });

  factory ComboLook.fromJson(Map<String, dynamic> json) {
    return ComboLook(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      lookType: json['look_type']?.toString() ?? '',
      isLayered: json['is_layered'] ?? false,
      score: json['score'] ?? 0,
      totalPrice: json['total_price']?.toString() ?? '0.00',
      currency: json['currency']?.toString() ?? 'INR',
      isTryonReady: json['is_tryon_ready'] ?? false,
      productIds:
          (json['product_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (e) =>
                    RecommendedComboItem.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          [],
    );
  }
}

class RecommendedComboItem {
  // Renamed from ComboItem
  final String role;
  final String category;
  final String categoryDisplay;
  final ComboProduct product;

  RecommendedComboItem({
    required this.role,
    required this.category,
    required this.categoryDisplay,
    required this.product,
  });

  factory RecommendedComboItem.fromJson(Map<String, dynamic> json) {
    return RecommendedComboItem(
      role: json['role']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      categoryDisplay: json['category_display']?.toString() ?? '',
      product: ComboProduct.fromJson(
        Map<String, dynamic>.from(json['product'] ?? {}),
      ),
    );
  }
}

class ComboProduct {
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

  ComboProduct({
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

  factory ComboProduct.fromJson(Map<String, dynamic> json) {
    return ComboProduct(
      id: json['id'] ?? 0,
      store: json['store'] ?? 0,
      storeName: json['store_name']?.toString() ?? '',
      storeSlug: json['store_slug']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      price: json['price']?.toString() ?? '0.00',
      compareAtPrice: json['compare_at_price']?.toString(),
      currency: json['currency']?.toString() ?? 'INR',
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
