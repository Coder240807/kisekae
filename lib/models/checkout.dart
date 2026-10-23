class CheckoutOrder {
  final int orderId;
  final String orderNumber;
  final int storeId;
  final String storeName;
  final String totalAmount;
  final String currency;
  final int itemsCount;
  final String status;

  CheckoutOrder({
    required this.orderId,
    required this.orderNumber,
    required this.storeId,
    required this.storeName,
    required this.totalAmount,
    required this.currency,
    required this.itemsCount,
    required this.status,
  });

  factory CheckoutOrder.fromJson(Map<String, dynamic> json) {
    return CheckoutOrder(
      orderId: json['order_id'] as int? ?? 0,
      orderNumber: json['order_number'] as String? ?? '',
      storeId: json['store_id'] as int? ?? 0,
      storeName: json['store_name'] as String? ?? '',
      totalAmount: json['total_amount']?.toString() ?? '0',
      currency: json['currency'] as String? ?? 'INR',
      itemsCount: json['items_count'] as int? ?? 0,
      status: json['status'] as String? ?? '',
    );
  }
}

class CheckoutResponse {
  final List<CheckoutOrder> orders;
  final int totalOrdersPlaced;
  final String totalAmount;
  final String currency;

  CheckoutResponse({
    required this.orders,
    required this.totalOrdersPlaced,
    required this.totalAmount,
    required this.currency,
  });

  factory CheckoutResponse.fromJson(Map<String, dynamic> json) {
    final rawOrders = json['orders'] as List<dynamic>? ?? [];

    return CheckoutResponse(
      orders: rawOrders
          .map(
            (e) => CheckoutOrder.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      totalOrdersPlaced: json['total_orders_placed'] as int? ?? 0,
      totalAmount: json['total_amount']?.toString() ?? '0',
      currency: json['currency'] as String? ?? 'INR',
    );
  }
}
