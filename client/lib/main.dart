import 'package:client/core/provider/current_user_notifier.dart';
import 'package:client/core/theme/theme.dart';
import 'package:client/features/auth/viewmodel/auth_viewmodel.dart';
// import 'package:client/features/home/view/pages/home_page.dart';
import 'package:client/features/home/view/pages/upload_song_page.dart';
import 'package:flutter/material.dart';
import 'features/auth/view/pages/signup_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//import 'features/auth/view/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await container.read(authViewModelProvider.notifier).initSharedPreferences();
  final userModel = await container.read(authViewModelProvider.notifier).getData();
  print(userModel);
  
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
    final currentUser = ref.watch(currentUserNotifierProvider);
    return MaterialApp(
      title: 'Music App project',
      theme: AppTheme.darkThemeMode,
      home: currentUser == null ? const SignupPage() : const UploadSongPage(),
    );
  }
}
