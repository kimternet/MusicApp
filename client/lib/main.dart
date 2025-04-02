import 'package:client/core/provider/current_user_notifier.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/features/auth/view/pages/login_page.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:client/features/home/view/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';

// 앱 전역에서 MyApp에 접근 가능하게 함
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  final dir = await getApplicationDocumentsDirectory();
  Hive.defaultDirectory = dir.path;
  final container = ProviderContainer();
  await container.read(authViewModelProvider.notifier).initSharedPreferences();
  await container.read(authViewModelProvider.notifier).getData();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 사용자 상태 확인 (null 여부에 따라 화면 전환)
    final currentUser = ref.watch(currentUserNotifierProvider);
    
    // 디버그 로그
    print('현재 로그인 상태: ${currentUser == null ? "로그아웃됨" : "로그인됨 (${currentUser.name})"}');

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   print('로그인 상태가 업데이트됨: ${currentUser == null ? "로그아웃" : "로그인"}');
    // });

    // 더 직접적인 경로로 앱 생성
    return MaterialApp(
      title: 'Music App',
      theme: AppTheme.darkThemeMode,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // 전역 네비게이터 키 (필요시 사용)
      routes: {
        '/': (context) => currentUser == null ? const LoginPage() : const HomePage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
      initialRoute: '/',
    );
  }
}