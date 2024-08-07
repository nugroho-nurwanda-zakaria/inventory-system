import 'package:flutter/material.dart';
import 'package:flutter_application_3/providers/auth_provider.dart';
import 'package:flutter_application_3/providers/category_provider.dart';
import 'package:flutter_application_3/login_page.dart';
// import 'package:flutter_application_3/providers/product_provider.dart';
import 'package:flutter_application_3/register_page.dart';
import 'package:flutter_application_3/main_menu_page.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
       // ChangeNotifierProvider(create: (_) => ProductProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login', // Initial route set to login
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main_menu': (context) => const MainMenuPage(),
      },
    );
  }
}