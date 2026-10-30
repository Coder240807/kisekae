double _d(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;

int _i(dynamic v) =>
    v is num ? v.toInt() : int.tryParse(v?.toString() ?? '') ?? 0;

class PromotedProduct {
  final int promotedProductId;
  final int productId;
  final String name;
  final double price;
  final bool isActive;
  final int clicks;
  final int orders;
  final int unitsSold;
  final double spend;
  final DateTime? createdAt;

  const PromotedProduct({
    required this.promotedProductId,
    required this.productId,
    required this.name,
    required this.price,
    required this.isActive,
    required this.clicks,
    required this.orders,
    required this.unitsSold,
    required this.spend,
    this.createdAt,
  });

  factory PromotedProduct.fromJson(Map<String, dynamic> j) => PromotedProduct(
    promotedProductId: _i(j['promoted_product_id']),
    productId: _i(j['product_id']),
    name: j['product_name']?.toString() ?? '',
    price: _d(j['product_price']),
    isActive: j['is_active'] == true,
    clicks: _i(j['clicks']),
    orders: _i(j['orders']),
    unitsSold: _i(j['units_sold']),
    spend: _d(j['spend']),
    createdAt: DateTime.tryParse(j['created_at']?.toString() ?? ''),
  );
}

class AdAnalytics {
  final double monthlyBudget;
  final double currentSpend;
  final double remainingBudget;
  final int totalClicks;
  final int totalOrders;
  final int totalUnitsSold;
  final double conversionRate;
  final List<PromotedProduct> products;

  const AdAnalytics({
    required this.monthlyBudget,
    required this.currentSpend,
    required this.remainingBudget,
    required this.totalClicks,
    required this.totalOrders,
    required this.totalUnitsSold,
    required this.conversionRate,
    required this.products,
  });

  factory AdAnalytics.fromJson(Map<String, dynamic> j) {
    final raw = j['products'];
    return AdAnalytics(
      monthlyBudget: _d(j['monthly_budget']),
      currentSpend: _d(j['current_spend']),
      remainingBudget: _d(j['remaining_budget']),
      totalClicks: _i(j['total_clicks']),
      totalOrders: _i(j['total_orders']),
      totalUnitsSold: _i(j['total_units_sold']),
      conversionRate: _d(j['conversion_rate']),
      products: raw is List
          ? raw
                .whereType<Map>()
                .map(
                  (e) => PromotedProduct.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList()
          : <PromotedProduct>[],
    );
  }
}

class AdBudget {
  final double amount;
  final DateTime? updatedAt;

  const AdBudget({required this.amount, this.updatedAt});

  factory AdBudget.fromJson(Map<String, dynamic> j) => AdBudget(
    amount: _d(j['monthly_advertising_budget']),
    updatedAt: DateTime.tryParse(j['updated_at']?.toString() ?? ''),
  );
}

class PromotableProduct {
  final int id;
  final String name;
  final double price;

  const PromotableProduct({
    required this.id,
    required this.name,
    required this.price,
  });
}
