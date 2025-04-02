import 'package:client/core/models/user_model.dart';
import 'package:client/features/auth/repositories/auth_local_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_user_notifier.g.dart';

@Riverpod(keepAlive: true)
class CurrentUserNotifier extends _$CurrentUserNotifier {
  late AuthLocalRepository _authLocalRepository;
  
  @override
  UserModel? build() {
    _authLocalRepository = ref.watch(authLocalRepositoryProvider);
    return null;
  }

  void addUser(UserModel user) {
    state = user;
  }
  
  Future<void> logout() async {
    // 토큰 삭제
    try {
      await _authLocalRepository.removeToken();
      print("토큰이 SharedPreferences에서 삭제됨");
    } catch (e) {
      print("토큰 삭제 오류: $e");
    }
    
    // 상태 초기화
    state = null;
    print('Logout successful: User state set to null');
  }
}