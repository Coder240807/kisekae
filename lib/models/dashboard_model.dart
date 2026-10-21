import 'dart:convert';

class DashboardMetrics {
  final double totalSales;
  final int totalOrders;
  final int totalVisitors;
  final int totalProducts;
  final double conversionRate;

  DashboardMetrics({
    required this.totalSales,
    required this.totalOrders,
    required this.totalVisitors,
    required this.totalProducts,
    required this.conversionRate,
  });

  factory DashboardMetrics.fromRawJson(String str) =>
      DashboardMetrics.fromJson(json.decode(str));

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      totalOrders: json['total_orders'] ?? 0,
      totalVisitors: json['total_visitors'] ?? 0,
      totalProducts: json['total_products'] ?? 0,
      conversionRate: (json['conversion_rate'] ?? 0).toDouble(),
    );
  }
}
