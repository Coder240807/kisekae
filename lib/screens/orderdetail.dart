import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kisekae/services/order_seller.dart';

import '../models/order_details.dart';

class OrderDetailScreen extends StatefulWidget {
  final int storeId;
  final int orderId;

  const OrderDetailScreen({
    super.key,
    required this.storeId,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final StoreOrderRepository _orderService = StoreOrderRepository();

  OrderDetail? _order;
  bool _isLoading = true;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    setState(() => _isLoading = true);

    try {
      final order = await _orderService.getOrderDetails(
        storeId: widget.storeId,
        orderId: widget.orderId,
      );

      if (mounted) {
        setState(() {
          _order = order;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && e is! DioException) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load order details: ${e.toString()}'),
          ),
        );
      }
    }
  }

  Future<void> _handleUpdateStatus({
    required String newStatus,
    String? notes,
    String? trackingNumber,
    String? trackingUrl,
  }) async {
    if (_order == null) return;

    setState(() => _isUpdatingStatus = true);

    try {
      final updatedOrder = await _orderService.updateOrderStatus(
        storeId: widget.storeId,
        orderId: widget.orderId,
        status: newStatus,
        notes: notes?.trim().isNotEmpty == true ? notes!.trim() : null,
        trackingNumber: trackingNumber?.trim().isNotEmpty == true
            ? trackingNumber!.trim()
            : null,
        trackingUrl: trackingUrl?.trim().isNotEmpty == true
            ? trackingUrl!.trim()
            : null,
      );

      if (mounted) {
        setState(() {
          _order = updatedOrder;
          _isUpdatingStatus = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Order status updated to $newStatus successfully!"),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  String _formatCurrency(String amount, String currency) {
    final parsed = double.tryParse(amount) ?? 0.0;
    final symbol = currency.toUpperCase() == 'INR'
        ? '₹'
        : currency.toUpperCase() == 'USD'
        ? '\$'
        : currency;
    return '$symbol${parsed.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> _getStatusStyle(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return {
          'label': 'DELIVERED',
          'color': const Color(0xFF2E7D32),
          'bgColor': const Color(0xE8E8F5E9),
          'icon': Icons.check_circle_outline,
        };
      case 'SHIPPED':
        return {
          'label': 'SHIPPED',
          'color': const Color(0xFF0288D1),
          'bgColor': const Color(0xFFE1F5FE),
          'icon': Icons.local_shipping_outlined,
        };
      case 'PROCESSING':
        return {
          'label': 'PROCESSING',
          'color': const Color(0xFFE65100),
          'bgColor': const Color(0xFFFFE0B2),
          'icon': Icons.sync,
        };
      case 'CANCELLED':
        return {
          'label': 'CANCELLED',
          'color': const Color(0xFFC62828),
          'bgColor': const Color(0xFFFFEBEE),
          'icon': Icons.cancel_outlined,
        };
      case 'PENDING':
      default:
        return {
          'label': 'PENDING',
          'color': const Color(0xFFF57F17),
          'bgColor': const Color(0xFFFFFDE7),
          'icon': Icons.schedule_outlined,
        };
    }
  }

  void _showUpdateStatusSheet(BuildContext context) {
    String selectedStatus = _order?.status.toUpperCase() ?? 'PROCESSING';
    if (selectedStatus == 'PENDING') selectedStatus = 'PROCESSING';

    final notesController = TextEditingController(text: _order?.notes ?? '');
    final trackingNumberController = TextEditingController(
      text: _order?.trackingNumber ?? '',
    );
    final trackingUrlController = TextEditingController(
      text: _order?.trackingUrl ?? '',
    );

    const primaryColor = Color(0xFF8B2E3E);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFF8F0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 20.0,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Update Order Status",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Status Option Segmented Selector
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _statusChip(
                          label: "PROCESSING",
                          color: const Color(0xFFE65100),
                          isSelected: selectedStatus == "PROCESSING",
                          onTap: () => setSheetState(
                            () => selectedStatus = "PROCESSING",
                          ),
                        ),
                        _statusChip(
                          label: "SHIPPED",
                          color: const Color(0xFF0288D1),
                          isSelected: selectedStatus == "SHIPPED",
                          onTap: () =>
                              setSheetState(() => selectedStatus = "SHIPPED"),
                        ),
                        _statusChip(
                          label: "DELIVERED",
                          color: const Color(0xFF2E7D32),
                          isSelected: selectedStatus == "DELIVERED",
                          onTap: () =>
                              setSheetState(() => selectedStatus = "DELIVERED"),
                        ),
                        _statusChip(
                          label: "CANCELLED",
                          color: const Color(0xFFC62828),
                          isSelected: selectedStatus == "CANCELLED",
                          onTap: () =>
                              setSheetState(() => selectedStatus = "CANCELLED"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Conditional Tracking Inputs for SHIPPED / DELIVERED
                    if (selectedStatus == "SHIPPED" ||
                        selectedStatus == "DELIVERED") ...[
                      TextFormField(
                        controller: trackingNumberController,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDecoration(
                          "Tracking Number (Optional)",
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: trackingUrlController,
                        style: const TextStyle(fontSize: 13),
                        decoration: _inputDecoration("Tracking URL (Optional)"),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Notes Input
                    TextFormField(
                      controller: notesController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 13),
                      decoration: _inputDecoration(
                        "Status Notes / Comments (Optional)",
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _handleUpdateStatus(
                            newStatus: selectedStatus,
                            notes: notesController.text,
                            trackingNumber: trackingNumberController.text,
                            trackingUrl: trackingUrlController.text,
                          );
                        },
                        child: Text(
                          "Update Status to $selectedStatus",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _statusChip({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : color,
        ),
      ),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: color.withOpacity(0.12),
      onSelected: (_) => onTap(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isSelected ? color : Colors.transparent),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: const Color(0xFFE5DDD2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
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

    if (_order == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Order details not available"),
              const SizedBox(height: 12),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: primaryColor),
                onPressed: _fetchOrderDetails,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    final order = _order!;
    final statusStyle = _getStatusStyle(order.status);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Order Details",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: primaryColor,
        onRefresh: _fetchOrderDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Order Status & Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5DDD2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Order #${order.orderNumber}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Placed on ${_formatDate(order.createdAt)}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusStyle['bgColor'] as Color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                statusStyle['icon'] as IconData,
                                size: 14,
                                color: statusStyle['color'] as Color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                statusStyle['label'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusStyle['color'] as Color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xFFE5DDD2)),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isUpdatingStatus
                            ? null
                            : () => _showUpdateStatusSheet(context),
                        icon: _isUpdatingStatus
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: primaryColor,
                                ),
                              )
                            : const Icon(
                                Icons.edit_road_outlined,
                                color: primaryColor,
                                size: 18,
                              ),
                        label: Text(
                          _isUpdatingStatus
                              ? "Updating Status..."
                              : "Update Order Status",
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Shipping & Customer Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5DDD2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Customer & Delivery Info",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Divider(height: 20, color: Color(0xFFE5DDD2)),
                    _infoRow(
                      Icons.person_outline,
                      "Customer",
                      order.customerName,
                    ),
                    const SizedBox(height: 10),
                    _infoRow(
                      Icons.phone_outlined,
                      "Phone",
                      order.customerPhone,
                    ),
                    const SizedBox(height: 10),
                    _infoRow(
                      Icons.email_outlined,
                      "Email",
                      order.customerEmail,
                    ),
                    if (order.shippingAddress != null &&
                        order.shippingAddress!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _infoRow(
                        Icons.location_on_outlined,
                        "Shipping Address",
                        order.shippingAddress!,
                      ),
                    ],
                    if (order.trackingNumber != null &&
                        order.trackingNumber!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _infoRow(
                        Icons.local_shipping_outlined,
                        "Tracking #",
                        order.trackingNumber!,
                      ),
                    ],
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Order Items",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "${order.items.length} item(s)",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFFE5DDD2)),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 20, color: Color(0xFFE5DDD2)),
                      itemBuilder: (context, index) {
                        final item = order.items[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5DDD2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.checkroom,
                                color: Colors.black54,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (item.size != null &&
                                          item.size!.isNotEmpty) ...[
                                        Text(
                                          "Size: ${item.size}",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      Text(
                                        "Qty: ${item.quantity}",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatCurrency(item.totalPrice, order.currency),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. Financial Total Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5DDD2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Order Amount",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      _formatCurrency(order.totalAmount, order.currency),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 10),
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
