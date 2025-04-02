import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod/riverpod.dart';

part 'auth_local_repository.g.dart';

class AuthLocalRepository {
  late SharedPreferences _sharedPreferences;
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      _sharedPreferences = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  Future<void> setToken(String? token) async {
    await init();
    
    if (token != null) {
      _sharedPreferences.setString('x-auth-token', token);
    }
  }

  Future<String?> getToken() async {
    await init();
    
    return _sharedPreferences.getString('x-auth-token');
  }

  Future<void> removeToken() async {
    await init();
    await _sharedPreferences.remove('x-auth-token');
  }
}

@riverpod
AuthLocalRepository authLocalRepository(Ref ref) {
  return AuthLocalRepository();
} 