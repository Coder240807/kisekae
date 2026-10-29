import 'dart:math' as math;

double _toDouble(dynamic v, [double fallback = 0]) =>
    double.tryParse(v?.toString() ?? '') ?? fallback;

List<WalletTransaction> _parseTxns(dynamic raw) => raw is List
    ? raw
          .whereType<Map>()
          .map((e) => WalletTransaction.fromJson(Map<String, dynamic>.from(e)))
          .toList()
    : <WalletTransaction>[];

class WalletTransaction {
  final int id;
  final double amount;
  final String type;
  final String? orderNumber;
  final String? paymentId;
  final String description;
  final DateTime createdAt;

  const WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    this.orderNumber,
    this.paymentId,
    required this.description,
    required this.createdAt,
  });

  bool get isCredit => type == 'CREDIT' || type == 'REFUND';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    String? clean(dynamic v) {
      final s = v?.toString();
      return (s == null || s.isEmpty) ? null : s;
    }

    return WalletTransaction(
      id: (json['id'] as num?)?.toInt() ?? 0,
      amount: _toDouble(json['amount']),
      type: json['txn_type']?.toString() ?? 'CREDIT',
      orderNumber: clean(json['order_number']),
      paymentId: clean(json['razorpay_payment_id']),
      description: json['description']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class Wallet {
  final int id;
  final double balance;
  final double balanceLimit;
  final double remainingLimit;
  final List<WalletTransaction> recentTransactions;

  const Wallet({
    required this.id,
    required this.balance,
    required this.balanceLimit,
    required this.remainingLimit,
    required this.recentTransactions,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    final balance = _toDouble(json['balance']);
    final limit = _toDouble(json['balance_limit'], 10000);
    final remaining = _toDouble(
      json['remaining_limit'],
      math.max(0.0, limit - balance),
    );
    return Wallet(
      id: (json['id'] as num?)?.toInt() ?? 0,
      balance: balance,
      balanceLimit: limit,
      remainingLimit: remaining,
      recentTransactions: _parseTxns(json['recent_transactions']),
    );
  }
}

class TopUpOrder {
  final String orderId;
  final int amountInPaise;
  final String currency;
  final String keyId;

  const TopUpOrder({
    required this.orderId,
    required this.amountInPaise,
    required this.currency,
    required this.keyId,
  });

  factory TopUpOrder.fromJson(Map<String, dynamic> json) => TopUpOrder(
    orderId: json['razorpay_order_id']?.toString() ?? '',
    amountInPaise: (json['amount_in_paise'] as num?)?.toInt() ?? 0,
    currency: json['currency']?.toString() ?? 'INR',
    keyId: json['key_id']?.toString() ?? '',
  );
}

class TransactionPage {
  final List<WalletTransaction> results;
  final bool hasNext;

  const TransactionPage({required this.results, required this.hasNext});

  factory TransactionPage.fromJson(Map<String, dynamic> json) {
    final next = json['next']?.toString();
    return TransactionPage(
      results: _parseTxns(json['results']),
      hasNext: next != null && next.isNotEmpty,
    );
  }
}
