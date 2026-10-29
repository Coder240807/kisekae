import 'package:dio/dio.dart';
import 'package:kisekae/models/auth_response.dart';
import 'package:kisekae/services/dio.dart';
import 'package:kisekae/services/storage.dart';

class AccountService {
  final Dio dio = DioClient.dio;
  final TokenStorage _tokenStorage = TokenStorage();

  Future<AuthResponse> becomeSeller() async {
    try {
      final response = await dio.post('/accounts/become-seller/');
      final data = response.data?["data"];
      final access = data is Map ? data["access"] : null;
      if (access is String && access.isNotEmpty) {
        await _tokenStorage.write(access);
      }
      await _tokenStorage.saveIsSeller(true);

      return AuthResponse(
        true,
        response.data["message"]?.toString() ?? "Successfully became a seller",
        Map<String, dynamic>.from(response.data["data"] ?? {}),
      );
    } on DioException catch (e) {
      final body = e.response?.data;

      String errorMessage = "Network error";
      if (body is Map) {
        errorMessage =
            body["message"]?.toString() ??
            body["error"]?["details"]?.toString() ??
            e.message ??
            "Failed to upgrade account";
      } else if (e.message != null && e.message!.isNotEmpty) {
        errorMessage = e.message!;
      }

      return AuthResponse(false, errorMessage);
    } catch (e) {
      return AuthResponse(false, "Unexpected error: $e");
    }
  }
}
