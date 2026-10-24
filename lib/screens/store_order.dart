import 'package:flutter/material.dart';
import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/models/order_details.dart';
import 'package:kisekae/screens/myorder_detail.dart';
import 'package:kisekae/services/order_seller.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.storeId});

  final int storeId;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const _filters = <(String, String?)>[
    ('All', null),
    ('Pending', 'PENDING'),
    ('Delivered', 'DELIVERED'),
    ('Cancelled', 'CANCELLED'),
  ];

  final _orderRepository = StoreOrderRepository();
  List<OrderItemSummary> _orders = [];

  int _requestId = 0;
  bool _isLoading = true;
  String? _error;
  String? _status;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final requestId = ++_requestId;
    setState(() {
      _isLoading = true;
      _error = null;
      _orders = [];
    });

    try {
      final orders = await _orderRepository.getStoreOrders(
        storeId: widget.storeId,
        status: _status,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() => _orders = orders);
    } on ApiException catch (e) {
      if (!mounted || requestId != _requestId) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() => _error = 'Something went wrong. Please try again');
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectFilter(String? status) {
    if (status == _status) return;
    _status = status;
    _loadOrders();
  }

  String _formatDate(DateTime value) {
    final date = value.toLocal();
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  String _formatAmount(double amount, String currency) {
    final number = amount == amount.roundToDouble()
        ? amount.toInt().toString()
        : amount.toStringAsFixed(2);
    final symbol = currency.toUpperCase() == 'INR' ? '₹' : '$currency ';
    return '$symbol$number';
  }

  String _statusLabel(String status) {
    final text = status.toLowerCase().replaceAll('_', ' ');
    if (text.isEmpty) return '-';
    return text[0].toUpperCase() + text.substring(1);
  }

  Widget _filterChip(ColorScheme cs, String label, String? status) {
    final selected = _status == status;
    return Material(
      color: selected ? cs.primary : Colors.transparent,
      shape: StadiumBorder(side: BorderSide(color: cs.primary)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () => _selectFilter(status),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: selected ? cs.onPrimary : cs.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(ColorScheme cs, IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, color: color ?? cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderCard(OrderItemSummary order, ColorScheme cs) {
    final isCancelled = order.status.toUpperCase() == 'CANCELLED';
    final items = order.itemsCount == 1
        ? '1 item'
        : '${order.itemsCount} items';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 32,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                _infoRow(
                  cs,
                  Icons.calendar_today_outlined,
                  _formatDate(order.createdAt),
                ),
                _infoRow(
                  cs,
                  Icons.payments_outlined,
                  '${_formatAmount(order.totalAmount, order.currency)} · $items',
                ),
                _infoRow(
                  cs,
                  Icons.local_shipping_outlined,
                  'Delivery Status - ${_statusLabel(order.status)}',
                  color: isCancelled ? cs.error : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(ColorScheme cs) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: cs.primary));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: cs.onSurface),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: _loadOrders,
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.primary,
                  side: BorderSide(color: cs.primary),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Text(
          'No orders found',
          style: TextStyle(fontSize: 16, color: cs.onSurface),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      itemCount: _orders.length,
      itemBuilder: (context, index) => _orderCard(_orders[index], cs),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surface,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cs.onSurface, width: 2),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: cs.onSurface,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Orders',
          style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  for (final filter in _filters) ...[
                    _filterChip(cs, filter.$1, filter.$2),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent orders',
                    style: TextStyle(fontSize: 18, color: cs.onSurface),
                  ),
                  GestureDetector(
                    onTap: () => _selectFilter(null),
                    child: Text(
                      'View all',
                      style: TextStyle(fontSize: 14, color: cs.primary),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _body(cs)),
          ],
        ),
      ),
    );
  }
}
