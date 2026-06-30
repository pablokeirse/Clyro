import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const ClyroApp());
}

class ClyroApp extends StatelessWidget {
  const ClyroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CLYRO',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const LoginScreen(),
    );
  }
}
