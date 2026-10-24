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

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final String? productSku;
  final String? size;
  final String unitPrice;
  final int quantity;
  final String totalPrice;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    this.productSku,
    this.size,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int? ?? 0,
      productId: json['product'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      productSku: json['product_sku'] as String?,
      size: json['size'] as String?,
      unitPrice: json['unit_price']?.toString() ?? '0',
      quantity: json['quantity'] as int? ?? 0,
      totalPrice: json['total_price']?.toString() ?? '0',
    );
  }
}

class OrderStatusHistory {
  final int id;
  final String? fromStatus;
  final String toStatus;
  final String? notes;
  final int? changedBy;
  final String? changedByName;
  final DateTime? createdAt;

  OrderStatusHistory({
    required this.id,
    this.fromStatus,
    required this.toStatus,
    this.notes,
    this.changedBy,
    this.changedByName,
    this.createdAt,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      id: json['id'] as int? ?? 0,
      fromStatus: json['from_status'] as String?,
      toStatus: json['to_status'] as String? ?? 'PENDING',
      notes: json['notes'] as String?,
      changedBy: json['changed_by'] as int?,
      changedByName: json['changed_by_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class OrderDetail {
  final int id;
  final int? userId;
  final String orderNumber;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String? shippingAddress;
  final String status;
  final String totalAmount;
  final String currency;
  final String? trackingNumber;
  final String? trackingUrl;
  final String? notes;
  final DateTime? deliveredAt;
  final List<OrderItem> items;
  final List<OrderStatusHistory> statusHistory;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderDetail({
    required this.id,
    this.userId,
    required this.orderNumber,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.shippingAddress,
    required this.status,
    required this.totalAmount,
    required this.currency,
    this.trackingNumber,
    this.trackingUrl,
    this.notes,
    this.deliveredAt,
    required this.items,
    required this.statusHistory,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int?,
      orderNumber: json['order_number'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      customerEmail: json['customer_email'] as String? ?? '',
      customerPhone: json['customer_phone'] as String? ?? '',
      shippingAddress: json['shipping_address'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      totalAmount: json['total_amount']?.toString() ?? '0',
      currency: json['currency'] as String? ?? '',
      trackingNumber: json['tracking_number'] as String?,
      trackingUrl: json['tracking_url'] as String?,
      notes: json['notes'] as String?,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.tryParse(json['delivered_at'].toString())
          : null,
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      statusHistory:
          (json['status_history'] as List<dynamic>?)
              ?.map(
                (hist) =>
                    OrderStatusHistory.fromJson(hist as Map<String, dynamic>),
              )
              .toList() ??
          [],
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
