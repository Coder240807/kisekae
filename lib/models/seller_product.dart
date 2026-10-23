class Product {
  final int id;
  final int storeId;
  final String storeName;
  final String name;
  final String slug;
  final String? description;
  final String? imageUrl;
  final String price;
  final String? compareAtPrice;
  final String currency;
  final String? sku;
  final int stock;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.name,
    required this.slug,
    this.description,
    this.imageUrl,
    required this.price,
    this.compareAtPrice,
    required this.currency,
    this.sku,
    required this.stock,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      storeId: json['store'] as int? ?? 0,
      storeName: json['store_name'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      price: json['price']?.toString() ?? '0',
      compareAtPrice: json['compare_at_price']?.toString(),
      currency: json['currency'] as String? ?? '',
      sku: json['sku'] as String?,
      stock: json['stock'] as int? ?? 0,
      status: json['status'] as String? ?? 'DRAFT',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}

class PaginatedProductResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<Product> results;

  PaginatedProductResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedProductResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedProductResponse(
      count: json['count'] as int? ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results:
          (json['results'] as List<dynamic>?)
              ?.map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ProductImage {
  final int id;
  final String imageUrl;
  final int order;
  final DateTime? createdAt;

  ProductImage({
    required this.id,
    required this.imageUrl,
    required this.order,
    this.createdAt,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: json['id'] as int? ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
