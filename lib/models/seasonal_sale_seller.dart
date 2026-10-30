double parseDecimal(dynamic value) =>
    double.tryParse(value?.toString() ?? '') ?? 0;

String formatNumber(double value) {
  return value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
}

String formatPrice(double value) => '₹${formatNumber(value)}';

enum SalePhase { live, upcoming, ended }

class EnrolledProduct {
  final int id;
  final int productId;
  final String productName;
  final String productSlug;
  final String? thumbnail;
  final double originalPrice;
  final double discountPercentage;
  final double discountedPrice;
  final bool isActive;
  final int stock;
  final DateTime? createdAt;

  EnrolledProduct({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSlug,
    this.thumbnail,
    required this.originalPrice,
    required this.discountPercentage,
    required this.discountedPrice,
    required this.isActive,
    required this.stock,
    this.createdAt,
  });

  factory EnrolledProduct.fromJson(Map<String, dynamic> json) {
    final thumbnail = json['thumbnail'] as String?;

    return EnrolledProduct(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      productSlug: json['product_slug'] as String? ?? '',
      thumbnail: (thumbnail == null || thumbnail.isEmpty) ? null : thumbnail,
      originalPrice: parseDecimal(json['original_price']),
      discountPercentage: parseDecimal(json['discount_percentage']),
      discountedPrice: parseDecimal(json['discounted_price']),
      isActive: json['is_active'] as bool? ?? false,
      stock: json['stock'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }
}

class SeasonalSale {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final int id;
  final String title;
  final String slug;
  final String description;
  final String? bannerImage;
  final double discountPercentage;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool isLive;
  final String status;
  final bool isParticipating;
  final int enrolledProductsCount;
  final List<EnrolledProduct> enrolledProducts;

  SeasonalSale({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    this.bannerImage,
    required this.discountPercentage,
    this.startTime,
    this.endTime,
    required this.isLive,
    required this.status,
    required this.isParticipating,
    required this.enrolledProductsCount,
    this.enrolledProducts = const [],
  });

  factory SeasonalSale.fromJson(Map<String, dynamic> json) {
    final banner = json['banner_image'] as String?;
    final products = json['enrolled_products'] as List<dynamic>? ?? [];

    return SeasonalSale(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      bannerImage: (banner == null || banner.isEmpty) ? null : banner,
      discountPercentage: parseDecimal(json['discount_percentage']),
      startTime: DateTime.tryParse(json['start_time']?.toString() ?? ''),
      endTime: DateTime.tryParse(json['end_time']?.toString() ?? ''),
      isLive: json['is_live'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      isParticipating: json['is_participating'] as bool? ?? false,
      enrolledProductsCount: json['enrolled_products_count'] as int? ?? 0,
      enrolledProducts: products
          .map(
            (item) => EnrolledProduct.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }

  SalePhase get phase {
    final now = DateTime.now();
    final end = endTime?.toLocal();
    final start = startTime?.toLocal();
    if (end != null && end.isBefore(now)) return SalePhase.ended;
    if (start != null && start.isAfter(now)) return SalePhase.upcoming;
    return SalePhase.live;
  }

  bool get hasEnded => phase == SalePhase.ended;

  String get discountLabel => '${formatNumber(discountPercentage)}% off';

  String get subtitle {
    if (description.trim().isNotEmpty) return description.trim();
    return 'Flat $discountLabel';
  }

  String _formatDay(DateTime date, {required bool withYear}) {
    final d = date.toLocal();
    final base = '${d.day} ${_months[d.month - 1]}';
    return withYear ? '$base ${d.year}' : base;
  }

  String get dateRange {
    final start = startTime;
    final end = endTime;
    if (start == null || end == null) return '';
    final sameYear = start.toLocal().year == end.toLocal().year;
    return '${_formatDay(start, withYear: !sameYear)} - ${_formatDay(end, withYear: true)}';
  }

  String _duration(Duration d) {
    if (d.inDays >= 1) return '${d.inDays}d ${d.inHours % 24}h';
    if (d.inHours >= 1) return '${d.inHours}h ${d.inMinutes % 60}m';
    return '${d.inMinutes < 1 ? 1 : d.inMinutes}m';
  }

  String get timingText {
    final now = DateTime.now();
    final start = startTime?.toLocal();
    final end = endTime?.toLocal();
    switch (phase) {
      case SalePhase.ended:
        return 'Ended';
      case SalePhase.upcoming:
        return start == null
            ? ''
            : 'Starts in ${_duration(start.difference(now))}';
      case SalePhase.live:
        return end == null ? '' : 'Ends in ${_duration(end.difference(now))}';
    }
  }

  String get participationText {
    if (!isParticipating || enrolledProductsCount == 0) {
      return 'Not participating yet';
    }
    final noun = enrolledProductsCount == 1 ? 'product' : 'products';
    return '$enrolledProductsCount $noun enrolled';
  }
}
