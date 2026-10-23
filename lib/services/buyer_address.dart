import 'package:dio/dio.dart';
import 'package:kisekae/models/user_address.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/helper.dart';

class AddressService extends BaseRepository {
  final Dio _dio;

  AddressService([Dio? dio]) : _dio = dio ?? DioClient.dio;

  Future<List<CustomerAddress>> getAddresses({CancelToken? cancelToken}) async {
    return execute(() async {
      final response = await _dio.get(
        '/accounts/addresses/',
        cancelToken: cancelToken,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final list = body['data'] as List<dynamic>;

      return list
          .map(
            (item) => CustomerAddress.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    });
  }

  Future<CustomerAddress> addAddress({
    required String addressLine1,
    required String state,
    required String postalCode,
    String title = 'Home',
    String recipientName = '',
    String phone = '',
    String addressLine2 = '',
    String city = '',
    String country = 'India',
    String? latitude,
    String? longitude,
    bool isDefault = false,
  }) async {
    return execute(() async {
      final payload = {
        'title': title,
        'recipient_name': recipientName,
        'phone': phone,
        'address_line_1': addressLine1,
        'address_line_2': addressLine2,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'pin_code': postalCode,
        'country': country,
        if (latitude != null && latitude.isNotEmpty) 'latitude': latitude,
        if (longitude != null && longitude.isNotEmpty) 'longitude': longitude,
        'is_default': isDefault,
      };

      final response = await _dio.post('/accounts/addresses/', data: payload);

      final body = Map<String, dynamic>.from(response.data as Map);
      final addressData = Map<String, dynamic>.from(body['data'] as Map);

      return CustomerAddress.fromJson(addressData);
    });
  }

  Future<CustomerAddress> updateAddress({
    required int addressId,
    required String addressLine1,
    required String state,
    required String postalCode,
    String title = 'Home',
    String recipientName = '',
    String phone = '',
    String addressLine2 = '',
    String city = '',
    String country = 'India',
    String? latitude,
    String? longitude,
    bool isDefault = false,
  }) async {
    return execute(() async {
      final payload = {
        'title': title,
        'recipient_name': recipientName,
        'phone': phone,
        'address_line_1': addressLine1,
        'address_line_2': addressLine2,
        'city': city,
        'state': state,
        'postal_code': postalCode,
        'pin_code': postalCode,
        'country': country,
        if (latitude != null && latitude.isNotEmpty) 'latitude': latitude,
        if (longitude != null && longitude.isNotEmpty) 'longitude': longitude,
        'is_default': isDefault,
      };

      final response = await _dio.put(
        '/accounts/addresses/$addressId/',
        data: payload,
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final addressData = Map<String, dynamic>.from(body['data'] as Map);

      return CustomerAddress.fromJson(addressData);
    });
  }

  Future<String> deleteAddress(int addressId) async {
    return execute(() async {
      final response = await _dio.delete('/accounts/addresses/$addressId/');

      final body = Map<String, dynamic>.from(response.data as Map);
      final message =
          body['message']?.toString() ?? 'Address deleted successfully.';

      return message;
    });
  }

  Future<CustomerAddress> setDefaultAddress(int addressId) async {
    return execute(() async {
      final response = await _dio.post(
        '/accounts/addresses/$addressId/default/',
      );

      final body = Map<String, dynamic>.from(response.data as Map);
      final addressData = Map<String, dynamic>.from(body['data'] as Map);

      return CustomerAddress.fromJson(addressData);
    });
  }
}
