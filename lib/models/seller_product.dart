class ProductVariantSize {
  final int id;
  final String size;
  final int stock;

  ProductVariantSize({required this.id, required this.size, required this.stock});

  factory ProductVariantSize.fromJson(Map<String, dynamic> json) {
    return ProductVariantSize(
      id: json['id'] as int? ?? 0,
      size: json['size'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
    );
  }
}

class ProductVariantImage {
  final int id;
  final String imageUrl;
  final int order;
  final DateTime? createdAt;

  ProductVariantImage({
    required this.id,
    required this.imageUrl,
    required this.order,
    this.createdAt,
  });

  factory ProductVariantImage.fromJson(Map<String, dynamic> json) {
    return ProductVariantImage(
      id: json['id'] as int? ?? 0,
      imageUrl: json['image_url'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class ProductVariant {
  final int id;
  final String colorName;
  final String colorHex;
  final String? sku;
  final bool isActive;
  final int totalStock;
  final String? thumbnail;
  final List<ProductVariantSize> sizes;
  final List<ProductVariantImage> images;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductVariant({
    required this.id,
    required this.colorName,
    required this.colorHex,
    this.sku,
    required this.isActive,
    required this.totalStock,
    this.thumbnail,
    required this.sizes,
    required this.images,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] as int? ?? 0,
      colorName: json['color_name'] as String? ?? '',
      colorHex: json['color_hex'] as String? ?? '#000000',
      sku: json['sku'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      totalStock: json['total_stock'] as int? ?? 0,
      thumbnail: json['thumbnail'] as String?,
      sizes: (json['sizes'] as List<dynamic>?)
              ?.map((e) => ProductVariantSize.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => ProductVariantImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }
}

class Product {
  final int id;
  final int storeId;
  final String storeName;
  final String name;
  final String slug;
  final String? productType;
  final String? category;
  final String? description;
  final String price;
  final String? compareAtPrice;
  final String currency;
  final String? sku;
  final int stock;
  final int totalStock;
  final String? thumbnail;
  final String? imageUrl;
  final List<ProductVariant> variants;
  final List<String> availableSizes;
  final String status;
  final bool? isRefundable;
  final double? averageRating;
  final int? reviewCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.name,
    required this.slug,
    this.productType,
    this.category,
    this.description,
    required this.price,
    this.compareAtPrice,
    required this.currency,
    this.sku,
    required this.stock,
    required this.totalStock,
    this.thumbnail,
    this.imageUrl,
    required this.variants,
    required this.availableSizes,
    required this.status,
    this.isRefundable,
    this.averageRating,
    this.reviewCount,
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
      productType: json['product_type'] as String?,
      category: json['category'] as String?,
      description: json['description'] as String?,
      price: json['price']?.toString() ?? '0',
      compareAtPrice: json['compare_at_price']?.toString(),
      currency: json['currency'] as String? ?? 'INR',
      sku: json['sku'] as String?,
      stock: json['stock'] as int? ?? 0,
      totalStock: json['total_stock'] as int? ?? 0,
      thumbnail: json['thumbnail'] as String?,
      imageUrl: json['image_url'] as String?,
      variants: (json['variants'] as List<dynamic>?)
              ?.map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      availableSizes: (json['available_sizes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      status: json['status'] as String? ?? 'DRAFT',
      isRefundable: json['is_refundable'] as bool?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      reviewCount: json['review_count'] as int?,
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
      results: (json['results'] as List<dynamic>?)
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

class ProductSizeInput {
  final String size;
  final int stock;

  ProductSizeInput({required this.size, required this.stock});

  Map<String, dynamic> toJson() {
    return {'size': size, 'stock': stock};
  }
}

class VariantInput {
  final String colorName;
  final String colorHex;
  final String? sku;
  final bool isActive;
  final List<ProductSizeInput> sizes;

  VariantInput({
    required this.colorName,
    required this.colorHex,
    this.sku,
    this.isActive = true,
    required this.sizes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'color_name': colorName,
      'color_hex': colorHex,
      'is_active': isActive,
      'sizes': sizes.map((s) => s.toJson()).toList(),
    };
    if (sku != null && sku!.isNotEmpty) map['sku'] = sku;
    return map;
  }
}

class CreateProductRequest {
  final String name;
  final String category;
  final String? productType;
  final String? description;
  final String price;
  final String? compareAtPrice;
  final String currency;
  final String? sku;
  final String status;
  final List<VariantInput> variants;

  CreateProductRequest({
    required this.name,
    required this.category,
    this.productType,
    this.description,
    required this.price,
    this.compareAtPrice,
    this.currency = 'INR',
    this.sku,
    this.status = 'DRAFT',
    this.variants = const [],
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'name': name,
      'category': category,
      'description': description ?? '',
      'price': price,
      'currency': currency,
      'status': status,
      'variants': variants.map((v) => v.toJson()).toList(),
    };
    if (productType != null) map['product_type'] = productType;
    if (compareAtPrice != null && compareAtPrice!.isNotEmpty) {
      map['compare_at_price'] = compareAtPrice;
    }
    if (sku != null && sku!.isNotEmpty) map['sku'] = sku;
    return map;
  }
}

class UpdateProductRequest {
  final String? name;
  final String? category;
  final String? productType;
  final String? description;
  final String? price;
  final String? compareAtPrice;
  final String? currency;
  final String? sku;
  final String? status;
  final List<VariantInput>? variants;

  UpdateProductRequest({
    this.name,
    this.category,
    this.productType,
    this.description,
    this.price,
    this.compareAtPrice,
    this.currency,
    this.sku,
    this.status,
    this.variants,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (category != null) map['category'] = category;
    if (productType != null) map['product_type'] = productType;
    if (description != null) map['description'] = description;
    if (price != null) map['price'] = price;
    if (compareAtPrice != null) map['compare_at_price'] = compareAtPrice;
    if (currency != null) map['currency'] = currency;
    if (sku != null) map['sku'] = sku;
    if (status != null) map['status'] = status;
    if (variants != null) map['variants'] = variants!.map((v) => v.toJson()).toList();
    return map;
  }
}
