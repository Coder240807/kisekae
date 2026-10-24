import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kisekae/models/dashboard_model.dart';
import 'package:kisekae/models/revenue_analytics.dart';
import 'package:kisekae/services/analytics.dart';

class AnalyticsScreen extends StatefulWidget {
  final int storeId;

  const AnalyticsScreen({super.key, required this.storeId});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final Analytics _analyticsService = Analytics();

  DashboardMetrics? _metrics;
  RevenueAnalytics? _revenueData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
  }

  Future<void> _fetchAnalyticsData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _analyticsService.getStoreDashboardMetrics(storeId: widget.storeId),
        _analyticsService.getStoreRevenueAnalytics(
          storeId: widget.storeId,
          period: 'daily',
        ),
      ]);

      if (mounted) {
        setState(() {
          _metrics = results[0] as DashboardMetrics;
          _revenueData = results[1] as RevenueAnalytics;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load analytics: ${e.toString()}')),
      );
    }
  }

  String _formatCurrency(double amount, String currency) {
    final symbol = currency.toUpperCase() == 'INR'
        ? '₹'
        : currency.toUpperCase() == 'USD'
        ? '\$'
        : currency;

    if (amount >= 100000) {
      final lakhs = amount / 100000;
      return '$symbol${lakhs.toStringAsFixed(2)}L';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  String _formatDateLabel(String dateStr) {
    if (dateStr.isEmpty) return '';
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return dateStr;
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];
    return '${parsed.day} ${months[parsed.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFEFE8DF);
    const primaryColor = Color(0xFF8B2E3E);
    const cardBackgroundColor = Color(0xFFFFF8F0);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    final metrics = _metrics;
    final timeSeries = _revenueData?.timeSeries ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 16,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          "Analytics",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: _fetchAnalyticsData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5DDD2)),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: timeSeries.isEmpty
                          ? const Center(
                              child: Text(
                                "No revenue data points available",
                                style: TextStyle(
                                  color: Colors.black45,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : LineChart(
                              _buildChartData(timeSeries, primaryColor),
                            ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5DDD2)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.monetization_on_outlined,
                        color: primaryColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total sales",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatCurrency(
                              metrics?.totalRevenue ?? 0.0,
                              metrics?.currency ?? 'INR',
                            ),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _metricCard(
                      title: "Orders",
                      value: "${metrics?.totalOrders ?? 0}",
                      icon: Icons.inventory_2_outlined,
                      primaryColor: primaryColor,
                      cardBackgroundColor: cardBackgroundColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _metricCard(
                      title: "Avg Order Value",
                      value: _formatCurrency(
                        metrics?.averageOrderValue ?? 0.0,
                        metrics?.currency ?? 'INR',
                      ),
                      icon: Icons.groups_outlined,
                      primaryColor: primaryColor,
                      cardBackgroundColor: cardBackgroundColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _metricCard(
                      title: "Units Sold",
                      value: "${metrics?.totalUnitsSold ?? 0}",
                      icon: Icons.shopping_bag_outlined,
                      primaryColor: primaryColor,
                      cardBackgroundColor: cardBackgroundColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _metricCard(
                      title: "Cancellation",
                      value:
                          "${(metrics?.cancellationRate ?? 0.0).toStringAsFixed(1)}%",
                      icon: Icons.bar_chart_rounded,
                      primaryColor: primaryColor,
                      cardBackgroundColor: cardBackgroundColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color primaryColor,
    required Color cardBackgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5DDD2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
              Icon(icon, size: 20, color: primaryColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8B2E3E),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildChartData(
    List<RevenueTimeSeriesPoint> timeSeries,
    Color primaryColor,
  ) {
    final spots = timeSeries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.revenue);
    }).toList();

    double maxY = 100;
    if (spots.isNotEmpty) {
      final maxVal = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      maxY = maxVal > 0 ? maxVal * 1.2 : 100;
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxY / 4,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.black.withOpacity(0.06),
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: maxY / 4,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.black38, fontSize: 10),
              );
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx >= 0 && idx < timeSeries.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    _formatDateLabel(timeSeries[idx].date),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (timeSeries.length - 1).toDouble().clamp(0, double.infinity),
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35,
          color: primaryColor,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: const Color(0xFFFFF8F0),
                strokeWidth: 2,
                strokeColor: primaryColor,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryColor.withOpacity(0.4),
                primaryColor.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }
}