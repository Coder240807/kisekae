class ProductDetail {
  final int id;
  final int store;
  final String storeName;
  final String storeSlug;
  final String name;
  final String slug;
  final String description;
  final String imageUrl;
  final double price;
  final double? compareAtPrice;
  final String currency;
  final String sku;
  final int stock;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductDetail({
    required this.id,
    required this.store,
    required this.storeName,
    required this.storeSlug,
    required this.name,
    required this.slug,
    required this.description,
    required this.imageUrl,
    required this.price,
    this.compareAtPrice,
    required this.currency,
    required this.sku,
    required this.stock,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      id: json['id'] ?? 0,
      store: json['store'] ?? 0,
      storeName: json['store_name'] ?? '',
      storeSlug: json['store_slug'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      compareAtPrice: json['compare_at_price'] != null
          ? double.tryParse(json['compare_at_price'].toString())
          : null,
      currency: json['currency'] ?? '',
      sku: json['sku'] ?? '',
      stock: json['stock'] ?? 0,
      status: json['status'] ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
