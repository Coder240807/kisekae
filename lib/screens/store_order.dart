import 'package:flutter/material.dart';
import 'package:kisekae/models/api_exception.dart';
import 'package:kisekae/models/order_details.dart';
import 'package:kisekae/services/order_seller.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, required this.storeId});

  final int storeId;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const _pageSize = 20;

  static const _filters = <(String, String?)>[
    ('All', null),
    ('Pending', 'PENDING'),
    ('Delivered', 'DELIVERED'),
    ('Cancelled', 'CANCELLED'),
  ];

  static const _useSampleData = true;

  static final _sampleOrder = OrderItemSummary(
    id: 1,
    orderNumber: 'ORD123456',
    customerName: 'Aditi Sharma',
    customerEmail: 'aditi@example.com',
    customerPhone: '9876543210',
    status: 'DELIVERED',
    totalAmount: 291,
    currency: 'INR',
    itemsCount: 2,
    createdAt: DateTime(2026, 10, 20),
    updatedAt: DateTime(2026, 10, 20),
  );

  final _orderRepository = StoreOrderRepository();
  final _scrollController = ScrollController();
  final List<OrderItemSummary> _orders = [];

  int _page = 1;
  int _requestId = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  String? _status;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadOrders(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      _loadOrders();
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _loadOrders({bool reset = false}) async {
    if (!reset && (_isLoading || _isLoadingMore || !_hasMore)) return;

    if (_useSampleData) {
      setState(() {
        _orders
          ..clear()
          ..add(_sampleOrder);
        _error = null;
        _isLoading = false;
        _isLoadingMore = false;
        _hasMore = false;
      });
      return;
    }

    final requestId = ++_requestId;
    setState(() {
      if (reset) {
        _page = 1;
        _hasMore = true;
        _error = null;
        _orders.clear();
        _isLoading = true;
        _isLoadingMore = false;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final response = await _orderRepository.getStoreOrders(
        storeId: widget.storeId,
        page: _page,
        pageSize: _pageSize,
        status: _status,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _orders.addAll(response.results);
        _hasMore = response.next != null;
        _page++;
      });
    } on ApiException catch (e) {
      if (!mounted || requestId != _requestId) return;
      _handleError(e.message);
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      _handleError('Something went wrong. Please try again');
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _handleError(String message) {
    if (_orders.isEmpty) {
      setState(() => _error = message);
    } else {
      _showMessage(message);
    }
  }

  void _selectFilter(String? status) {
    if (status == _status) return;
    _status = status;
    _loadOrders(reset: true);
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
      color: selected ? cs.primary : cs.surfaceContainerHighest,
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
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: color ?? cs.onSurface),
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.receipt_long, size: 32, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order No. - ${order.orderNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                _infoRow(
                  cs,
                  Icons.calendar_today_outlined,
                  _formatDate(order.createdAt),
                ),
                _infoRow(cs, Icons.person_outline, order.customerName),
                _infoRow(
                  cs,
                  Icons.payments_outlined,
                  '${_formatAmount(order.totalAmount, order.currency)} · $items',
                ),
                _infoRow(
                  cs,
                  Icons.local_shipping_outlined,
                  'Status - ${_statusLabel(order.status)}',
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
                onPressed: () => _loadOrders(reset: true),
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
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      itemCount: _orders.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _orders.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: cs.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }
        return _orderCard(_orders[index], cs);
      },
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
              child: Text(
                'Recent orders',
                style: TextStyle(fontSize: 18, color: cs.onSurface),
              ),
            ),
            Expanded(child: _body(cs)),
          ],
        ),
      ),
    );
  }
}
