import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kisekae/services/token_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleAuthService {
  final dio = Dio(BaseOptions(baseUrl: dotenv.get('BASE_URL')));
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final TokenStorage _tokenStorage = TokenStorage();

  Future<bool> signInAndAuthenticate() async {
    try {
      await _googleSignIn.initialize(
        serverClientId: dotenv.get('GOOGLE_CLIENT_ID'),
      );
      final GoogleSignInAccount account = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication auth = account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null) {
        return false;
      }

      Response response = await dio.post(
        "/accounts/oauth/google/",
        data: {"id_token": idToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        final String accessToken = data["tokens"]["access"];
        final String refreshToken = data["tokens"]["refresh"];

        _tokenStorage.write(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        return true;
      } else {
        print("Google Auth Error: ${response.statusCode} ${response.data}");
        return false;
      }
    } catch (e) {
      print("Google Auth Error: $e");
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _tokenStorage.deleteAll();
  }
}
