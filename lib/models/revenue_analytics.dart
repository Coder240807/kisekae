class RevenueTimeSeriesPoint {
  final String date;
  final double revenue;
  final int ordersCount;

  RevenueTimeSeriesPoint({
    required this.date,
    required this.revenue,
    required this.ordersCount,
  });

  factory RevenueTimeSeriesPoint.fromJson(Map<String, dynamic> json) {
    return RevenueTimeSeriesPoint(
      date: json['date'] as String? ?? '',
      revenue: double.tryParse(json['revenue']?.toString() ?? '0') ?? 0.0,
      ordersCount: json['orders_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'revenue': revenue, 'orders_count': ordersCount};
  }
}

class RevenueAnalytics {
  final String period;
  final String currency;
  final double totalRevenue;
  final int totalOrders;
  final double averageRevenuePerOrder;
  final List<RevenueTimeSeriesPoint> timeSeries;

  RevenueAnalytics({
    required this.period,
    required this.currency,
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageRevenuePerOrder,
    required this.timeSeries,
  });

  factory RevenueAnalytics.fromJson(Map<String, dynamic> json) {
    return RevenueAnalytics(
      period: json['period'] as String? ?? 'daily',
      currency: json['currency'] as String? ?? 'INR',
      totalRevenue:
          double.tryParse(json['total_revenue']?.toString() ?? '0') ?? 0.0,
      totalOrders: json['total_orders'] as int? ?? 0,
      averageRevenuePerOrder:
          double.tryParse(
            json['average_revenue_per_order']?.toString() ?? '0',
          ) ??
          0.0,
      timeSeries:
          (json['time_series'] as List<dynamic>?)
              ?.map(
                (item) => RevenueTimeSeriesPoint.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'currency': currency,
      'total_revenue': totalRevenue,
      'total_orders': totalOrders,
      'average_revenue_per_order': averageRevenuePerOrder,
      'time_series': timeSeries.map((item) => item.toJson()).toList(),
    };
  }
}
