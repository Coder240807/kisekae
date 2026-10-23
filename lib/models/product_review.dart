class ProductReview {
  final int id;
  final int product;
  final String productName;
  final int user;
  final String userName;
  final int rating;
  final String title;
  final String description;
  final bool isVerifiedBuyer;
  final String createdAt;
  final String updatedAt;

  ProductReview({
    required this.id,
    required this.product,
    required this.productName,
    required this.user,
    required this.userName,
    required this.rating,
    required this.title,
    required this.description,
    required this.isVerifiedBuyer,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    return ProductReview(
      id: json['id'] as int? ?? 0,
      product: json['product'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      user: json['user'] as int? ?? 0,
      userName: json['user_name'] as String? ?? 'Anonymous',
      rating: json['rating'] as int? ?? 5,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isVerifiedBuyer: json['is_verified_buyer'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}

class RatingSummary {
  final double averageRating;
  final int totalReviews;
  final Map<String, int> ratingBreakdown;

  RatingSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingBreakdown,
  });

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    final rawBreakdown =
        json['rating_breakdown'] as Map<String, dynamic>? ?? {};
    final breakdown = rawBreakdown.map(
      (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
    );

    return RatingSummary(
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['total_reviews'] as int? ?? 0,
      ratingBreakdown: breakdown,
    );
  }
}

class PaginatedReviewsResponse {
  final RatingSummary ratingSummary;
  final int count;
  final int totalPages;
  final int currentPage;
  final String? next;
  final String? previous;
  final List<ProductReview> results;

  PaginatedReviewsResponse({
    required this.ratingSummary,
    required this.count,
    required this.totalPages,
    required this.currentPage,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedReviewsResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List<dynamic>? ?? [];

    return PaginatedReviewsResponse(
      ratingSummary: RatingSummary.fromJson(
        Map<String, dynamic>.from(json['rating_summary'] as Map? ?? {}),
      ),
      count: json['count'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 0,
      currentPage: json['current_page'] as int? ?? 1,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: rawResults
          .map(
            (e) => ProductReview.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
    );
  }
}
