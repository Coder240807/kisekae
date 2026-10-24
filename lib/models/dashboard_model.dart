class DashboardMetrics {
  final double totalRevenue;
  final String currency;
  final int totalOrders;
  final int deliveredOrders;
  final int pendingOrders;
  final int shippedOrders;
  final int cancelledOrders;
  final int totalUnitsSold;
  final double averageOrderValue;
  final double cancellationRate;
  final int lowStockProductsCount;

  DashboardMetrics({
    required this.totalRevenue,
    required this.currency,
    required this.totalOrders,
    required this.deliveredOrders,
    required this.pendingOrders,
    required this.shippedOrders,
    required this.cancelledOrders,
    required this.totalUnitsSold,
    required this.averageOrderValue,
    required this.cancellationRate,
    required this.lowStockProductsCount,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalRevenue:
          double.tryParse(json['total_revenue']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      totalOrders: json['total_orders'] as int? ?? 0,
      deliveredOrders: json['delivered_orders'] as int? ?? 0,
      pendingOrders: json['pending_orders'] as int? ?? 0,
      shippedOrders: json['shipped_orders'] as int? ?? 0,
      cancelledOrders: json['cancelled_orders'] as int? ?? 0,
      totalUnitsSold: json['total_units_sold'] as int? ?? 0,
      averageOrderValue:
          double.tryParse(json['average_order_value']?.toString() ?? '0') ??
          0.0,
      cancellationRate:
          double.tryParse(json['cancellation_rate']?.toString() ?? '0') ?? 0.0,
      lowStockProductsCount: json['low_stock_products_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_revenue': totalRevenue,
      'currency': currency,
      'total_orders': totalOrders,
      'delivered_orders': deliveredOrders,
      'pending_orders': pendingOrders,
      'shipped_orders': shippedOrders,
      'cancelled_orders': cancelledOrders,
      'total_units_sold': totalUnitsSold,
      'average_order_value': averageOrderValue,
      'cancellation_rate': cancellationRate,
      'low_stock_products_count': lowStockProductsCount,
    };
  }
}
