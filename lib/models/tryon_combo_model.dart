class ComboItem {
  final int id;
  final int productId;
  final String productName;
  final String productSlug;
  final String category;
  final String? categoryDisplay;
  final String price;
  final String currency;
  final String? thumbnail;
  final DateTime? createdAt;

  ComboItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSlug,
    required this.category,
    this.categoryDisplay,
    required this.price,
    required this.currency,
    this.thumbnail,
    this.createdAt,
  });

  factory ComboItem.fromJson(Map<String, dynamic> json) {
    return ComboItem(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      productSlug: json['product_slug'] as String? ?? '',
      category: json['category'] as String? ?? '',
      categoryDisplay: json['category_display'] as String?,
      price: json['price']?.toString() ?? '0',
      currency: json['currency'] as String? ?? '',
      thumbnail: json['thumbnail'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'product_slug': productSlug,
      'category': category,
      'category_display': categoryDisplay,
      'price': price,
      'currency': currency,
      'thumbnail': thumbnail,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class TryOnCombo {
  final int id;
  final String name;
  final String shareCode;
  final String deepLink;
  final String shareUrl;
  final int itemsCount;
  final List<ComboItem> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TryOnCombo({
    required this.id,
    required this.name,
    required this.shareCode,
    required this.deepLink,
    required this.shareUrl,
    required this.itemsCount,
    required this.items,
    this.createdAt,
    this.updatedAt,
  });

  factory TryOnCombo.fromJson(Map<String, dynamic> json) {
    return TryOnCombo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      shareCode: json['share_code'] as String? ?? '',
      deepLink: json['deep_link'] as String? ?? '',
      shareUrl: json['share_url'] as String? ?? '',
      itemsCount: json['items_count'] as int? ?? 0,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => ComboItem.fromJson(item as Map<String, dynamic>))
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'share_code': shareCode,
      'deep_link': deepLink,
      'share_url': shareUrl,
      'items_count': itemsCount,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
