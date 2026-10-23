class CartStore {
  final int id;
  final String name;
  final String slug;
  final String status;

  CartStore({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
  });

  factory CartStore.fromJson(Map<String, dynamic> json) {
    return CartStore(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class CartProduct {
  final int id;
  final String name;
  final String slug;
  final String category;
  final String color;
  final String price;
  final String? compareAtPrice;
  final String currency;
  final String? thumbnail;
  final String? imageUrl;
  final int stock;
  final String status;
  final List<String> availableSizes;
  final CartStore? store;

  CartProduct({
    required this.id,
    required this.name,
    required this.slug,
    required this.category,
    required this.color,
    required this.price,
    this.compareAtPrice,
    required this.currency,
    this.thumbnail,
    this.imageUrl,
    required this.stock,
    required this.status,
    required this.availableSizes,
    this.store,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      category: json['category'] as String? ?? '',
      color: json['color'] as String? ?? '',
      price: json['price']?.toString() ?? '0',
      compareAtPrice: json['compare_at_price']?.toString(),
      currency: json['currency'] as String? ?? 'INR',
      thumbnail: json['thumbnail'] as String?,
      imageUrl: json['image_url'] as String?,
      stock: json['stock'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      availableSizes:
          (json['available_sizes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      store: json['store'] != null
          ? CartStore.fromJson(Map<String, dynamic>.from(json['store'] as Map))
          : null,
    );
  }
}

class CartItem {
  final int id;
  final CartProduct product;
  final String size;
  final int quantity;
  final String unitPrice;
  final String totalPrice;
  final bool isAvailable;
  final String createdAt;
  final String updatedAt;

  CartItem({
    required this.id,
    required this.product,
    required this.size,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int? ?? 0,
      product: CartProduct.fromJson(
        Map<String, dynamic>.from(json['product'] as Map),
      ),
      size: json['size'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: json['unit_price']?.toString() ?? '0',
      totalPrice: json['total_price']?.toString() ?? '0',
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}

class CartModel {
  final int id;
  final String cartToken;
  final int totalItems;
  final int totalUniqueItems;
  final String subtotal;
  final String currency;
  final List<CartItem> items;
  final String createdAt;
  final String updatedAt;

  CartModel({
    required this.id,
    required this.cartToken,
    required this.totalItems,
    required this.totalUniqueItems,
    required this.subtotal,
    required this.currency,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemList = json['items'] as List<dynamic>? ?? [];

    return CartModel(
      id: json['id'] as int? ?? 0,
      cartToken: json['cart_token'] as String? ?? '',
      totalItems: json['total_items'] as int? ?? 0,
      totalUniqueItems: json['total_unique_items'] as int? ?? 0,
      subtotal: json['subtotal']?.toString() ?? '0',
      currency: json['currency'] as String? ?? 'INR',
      items: itemList
          .map((e) => CartItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}

class CartValidationResult {
  final bool isValid;
  final int issuesCount;
  final List<String> issues;

  CartValidationResult({
    required this.isValid,
    required this.issuesCount,
    required this.issues,
  });

  factory CartValidationResult.fromJson(Map<String, dynamic> json) {
    return CartValidationResult(
      isValid: json['is_valid'] as bool? ?? false,
      issuesCount: json['issues_count'] as int? ?? 0,
      issues:
          (json['issues'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
