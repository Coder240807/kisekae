class SimilarProduct {
  final int id;
  final String name;
  final String storeName;
  final String currency;
  final String price;
  final String? compareAtPrice;
  final String? imageUrl;
  final double averageRating;
  final int reviewCount;

  const SimilarProduct({
    required this.id,
    required this.name,
    required this.storeName,
    required this.currency,
    required this.price,
    this.compareAtPrice,
    this.imageUrl,
    required this.averageRating,
    required this.reviewCount,
  });

  factory SimilarProduct.fromJson(Map<String, dynamic> json) {
    String? clean(dynamic v) {
      final s = v?.toString();
      return (s == null || s.isEmpty) ? null : s;
    }

    return SimilarProduct(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      storeName: json['store_name']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'INR',
      price: json['price']?.toString() ?? '',
      compareAtPrice: clean(json['compare_at_price']),
      imageUrl: clean(json['thumbnail']) ?? clean(json['image_url']),
      averageRating:
          double.tryParse(json['average_rating']?.toString() ?? '') ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
    );
  }
}
