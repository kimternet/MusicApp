import 'package:client/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'features/auth/view/pages/signup_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//import 'features/auth/view/pages/login_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.darkThemeMode,
      home: const SignupPage(),
    );
  }
}
