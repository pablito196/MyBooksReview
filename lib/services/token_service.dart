import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class TokenService {
  static const _tokenKey = 'auth_token';
  static final _uuid = Uuid();

  /// Recupera el token de SharedPreferences, o lo genera si no existe
  static Future<String> getOrCreateToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);

    if (token == null) {
      token = _uuid.v4(); // genera un token aleatorio
      await prefs.setString(_tokenKey, token);
    }

    return token;
  }
}