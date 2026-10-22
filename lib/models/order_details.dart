class PaginatedOrderResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<OrderItemSummary> results;

  PaginatedOrderResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedOrderResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedOrderResponse(
      count: json['count'] ?? 0,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results:
          (json['results'] as List<dynamic>?)
              ?.map(
                (item) =>
                    OrderItemSummary.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}

class OrderItemSummary {
  final int id;
  final String orderNumber;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String status;
  final double totalAmount;
  final String currency;
  final int itemsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderItemSummary({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.status,
    required this.totalAmount,
    required this.currency,
    required this.itemsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderItemSummary.fromJson(Map<String, dynamic> json) {
    return OrderItemSummary(
      id: json['id'] ?? 0,
      orderNumber: json['order_number'] ?? '',
      customerName: json['customer_name'] ?? '',
      customerEmail: json['customer_email'] ?? '',
      customerPhone: json['customer_phone'] ?? '',
      status: json['status'] ?? 'PENDING',
      totalAmount:
          double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] ?? '',
      itemsCount: json['items_count'] ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
