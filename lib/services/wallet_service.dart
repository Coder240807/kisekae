import 'package:dio/dio.dart';
import 'package:kisekae/models/model.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class WalletOperations extends BaseRepository {
  final Dio _dio;

  WalletOperations([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Map<String, dynamic> _unwrap(dynamic body) {
    final map = Map<String, dynamic>.from(body as Map);
    final data = map['data'];
    return data is Map ? Map<String, dynamic>.from(data) : map;
  }

  Future<Wallet> getWallet() {
    return execute(() async {
      final response = await _dio.get('/profile/wallet/');
      return Wallet.fromJson(_unwrap(response.data));
    });
  }

  Future<TransactionPage> getTransactions({int page = 1}) {
    return execute(() async {
      final response = await _dio.get(
        '/profile/wallet/transactions/',
        queryParameters: {'page': page},
      );
      // This endpoint is not wrapped in { data: ... }.
      return TransactionPage.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    });
  }

  Future<TopUpOrder> createTopUpOrder(double amount) {
    return execute(() async {
      final response = await _dio.post(
        '/profile/wallet/add-funds/',
        data: {'amount': amount.toStringAsFixed(2)},
      );
      return TopUpOrder.fromJson(_unwrap(response.data));
    });
  }

  Future<Wallet> verifyTopUp({
    required String paymentId,
    required String orderId,
    required String signature,
    required double amount,
  }) {
    return execute(() async {
      final response = await _dio.post(
        '/profile/wallet/add-funds/verify/',
        data: {
          'razorpay_payment_id': paymentId,
          'razorpay_order_id': orderId,
          'razorpay_signature': signature,
          'amount': amount.toStringAsFixed(2),
        },
      );
      return Wallet.fromJson(_unwrap(response.data));
    });
  }
}
