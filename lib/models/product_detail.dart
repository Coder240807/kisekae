class ProductGalleryImage {
  final int id;
  final String imageUrl;
  final int order;
  final String createdAt;

  ProductGalleryImage({
    required this.id,
    required this.imageUrl,
    required this.order,
    required this.createdAt,
  });

  factory ProductGalleryImage.fromJson(Map<String, dynamic> json) {
    return ProductGalleryImage(
      id: json['id'] as int? ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class ProductSizeStock {
  final int id;
  final String size;
  final int stock;

  ProductSizeStock({required this.id, required this.size, required this.stock});

  factory ProductSizeStock.fromJson(Map<String, dynamic> json) {
    return ProductSizeStock(
      id: json['id'] as int? ?? 0,
      size: json['size'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
    );
  }
}

class ProductDetail {
  final int id;
  final int store;
  final String storeName;
  final String storeSlug;
  final String name;
  final String slug;
  final String? description;
  final String price;
  final String? compareAtPrice;
  final String currency;
  final String? sku;
  final String? thumbnail;
  final String? imageUrl;
  final String category;
  final String categoryDisplay;
  final String color;
  final int stock;
  final bool isInStock;
  final List<String> availableSizes;
  final double averageRating;
  final int reviewCount;
  final List<ProductGalleryImage> images;
  final List<ProductSizeStock> sizes;
  final String createdAt;
  final String? updatedAt;

  ProductDetail({
    required this.id,
    required this.store,
    required this.storeName,
    required this.storeSlug,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.compareAtPrice,
    required this.currency,
    this.sku,
    this.thumbnail,
    this.imageUrl,
    required this.category,
    required this.categoryDisplay,
    required this.color,
    required this.stock,
    required this.isInStock,
    required this.availableSizes,
    required this.averageRating,
    required this.reviewCount,
    this.images = const [],
    this.sizes = const [],
    required this.createdAt,
    this.updatedAt,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'] as int? ?? 0,
      store: json['store'] as int? ?? 0,
      storeName: json['store_name'] as String? ?? '',
      storeSlug: json['store_slug'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      price: json['price']?.toString() ?? '0',
      compareAtPrice: json['compare_at_price']?.toString(),
      currency: json['currency'] as String? ?? 'INR',
      sku: json['sku'] as String?,
      thumbnail: json['thumbnail'] as String?,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String? ?? '',
      categoryDisplay: json['category_display'] as String? ?? '',
      color: json['color'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      isInStock: json['is_in_stock'] as bool? ?? false,
      availableSizes:
          (json['available_sizes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      images:
          (json['images'] as List<dynamic>?)
              ?.map(
                (e) => ProductGalleryImage.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [],
      sizes:
          (json['sizes'] as List<dynamic>?)
              ?.map(
                (e) => ProductSizeStock.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [],
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String?,
    );
  }
}

class PaginatedProducts {
  final int count;
  final String? next;
  final String? previous;
  final List<ProductDetail> results;

  PaginatedProducts({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedProducts.fromJson(Map<String, dynamic> json) {
    final resultList = json['results'] as List<dynamic>? ?? [];

    return PaginatedProducts(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: resultList
          .map(
            (e) => ProductDetail.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
    );
  }
}
